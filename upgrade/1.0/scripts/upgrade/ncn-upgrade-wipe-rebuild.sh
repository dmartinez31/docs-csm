#!/bin/bash
#
# Copyright 2021 Hewlett Packard Enterprise Development LP
#
set -e
BASEDIR=$(dirname $0)
. ${BASEDIR}/upgrade-state.sh
trap 'err_report' ERR
upgrade_ncn=$1

. ${BASEDIR}/ncn-upgrade-common.sh ${upgrade_ncn}

state_name="CSI_HANDOFF_BSS_UPDATE_PARAM"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."
    if [[ $upgrade_ncn == ncn-s* ]];then 
        csi handoff bss-update-param \
        --set metal.server=http://rgw-vip.nmn/ncn-images/ceph/${CEPH_VERSION} \
        --set rd.live.squashimg=filesystem.squashfs \
        --set metal.no-wipe=1 \
        --kernel s3://ncn-images/ceph/${CEPH_VERSION}/kernel \
        --initrd s3://ncn-images/ceph/${CEPH_VERSION}/initrd \
        --limit $UPGRADE_XNAME
     else 
        csi handoff bss-update-param \
        --set metal.server=http://rgw-vip.nmn/ncn-images/k8s/${KUBERNETES_VERSION} \
        --set rd.live.squashimg=filesystem.squashfs \
        --set metal.no-wipe=0 \
        --kernel s3://ncn-images/k8s/${KUBERNETES_VERSION}/kernel \
        --initrd s3://ncn-images/k8s/${KUBERNETES_VERSION}/initrd \
        --limit $UPGRADE_XNAME
     fi
    
    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

state_name="WIPE_NODE_DISK"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."
    if [[ $upgrade_ncn == ncn-s* ]]; then
    cat <<'EOF' > wipe_disk.sh
    set -e
    for d in $(lsblk | grep -B2 -F md1  | grep ^s | awk '{print $1}'); do wipefs -af "/dev/$d"; done
EOF
    elif [[ $upgrade_ncn == ncn-m* ]]; then
    cat <<'EOF' > wipe_disk.sh
    set -e
    umount /var/lib/etcd /var/lib/sdu || true
    for md in /dev/md/*; do mdadm -S $md || echo nope ; done
    vgremove -f --select 'vg_name=~metal*' || true
    pvremove /dev/md124 || true
    wipefs --all --force /dev/sd* /dev/disk/by-label/* || true
    sgdisk --zap-all /dev/sd* 
EOF
    else
    cat <<'EOF' > wipe_disk.sh
    set -e
    umount /var/lib/containerd /var/lib/kubelet /var/lib/sdu || true
    for md in /dev/md/*; do mdadm -S $md || echo nope ; done
    vgremove -f --select 'vg_name=~metal*'
    pvremove /dev/md124 || true
    wipefs --all --force /dev/sd* /dev/disk/by-label/* || true
    sgdisk --zap-all /dev/sd* 
EOF
    fi
    chmod +x wipe_disk.sh
    scp wipe_disk.sh $UPGRADE_NCN:/tmp/wipe_disk.sh
    ssh $UPGRADE_NCN '/tmp/wipe_disk.sh'
    
    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

upgrade_ncn_mgmt_host="$UPGRADE_NCN-mgmt"
if [[ ${upgrade_ncn} == "ncn-m001" ]]; then
    echo ""
    read -p "Enter the IP or hostname of the BMC for ncn-m001:" upgrade_ncn_mgmt_host
    echo ""
else 
    echo "mgmt IP/Host: ${upgrade_ncn_mgmt_host}"
fi

# retrieve IPMI username/password from vault
VAULT_TOKEN=$(kubectl get secrets cray-vault-unseal-keys -n vault -o jsonpath={.data.vault-root} | base64 -d)
IPMI_USERNAME=$(kubectl exec -it -n vault -c vault cray-vault-1 -- sh -c "export VAULT_ADDR=http://localhost:8200; export VAULT_TOKEN=`echo $VAULT_TOKEN`; vault kv get -format=json secret/hms-creds/$UPGRADE_MGMT_XNAME" | jq -r '.data.Username')
export IPMI_PASSWORD=$(kubectl exec -it -n vault -c vault cray-vault-1 -- sh -c "export VAULT_ADDR=http://localhost:8200; export VAULT_TOKEN=`echo $VAULT_TOKEN`; vault kv get -format=json secret/hms-creds/$UPGRADE_MGMT_XNAME" | jq -r '.data.Password')
# during worker upgrade, one vault pod might be offline, so we just try another one
if [[ -z ${IPMI_USERNAME} ]]; then
    IPMI_USERNAME=$(kubectl exec -it -n vault -c vault cray-vault-0 -- sh -c "export VAULT_ADDR=http://localhost:8200; export VAULT_TOKEN=`echo $VAULT_TOKEN`; vault kv get -format=json secret/hms-creds/$UPGRADE_MGMT_XNAME" | jq -r '.data.Username')
    export IPMI_PASSWORD=$(kubectl exec -it -n vault -c vault cray-vault-0 -- sh -c "export VAULT_ADDR=http://localhost:8200; export VAULT_TOKEN=`echo $VAULT_TOKEN`; vault kv get -format=json secret/hms-creds/$UPGRADE_MGMT_XNAME" | jq -r '.data.Password')
fi

state_name="SET_PXE_BOOT"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."

    ipmitool -I lanplus -U ${IPMI_USERNAME} -E -H $upgrade_ncn_mgmt_host chassis bootdev pxe options=efiboot

    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

# polling console logs in background
kill $(ps -ef | grep kubectl | grep -v "grep" | awk '{print $2}') || true
CON_POD=$(kubectl get pods -n services -o wide|grep cray-console-operator|awk '{print $1}')
CON_NODE=$(kubectl -n services exec $CON_POD -- sh -c "/app/get-node $UPGRADE_XNAME" | jq .podname | sed 's/"//g')
kubectl -n services exec pod/$CON_NODE -c cray-console-node -- sh -c "tail -f /var/log/conman/console.$UPGRADE_XNAME" >> $upgrade_ncn.boot.log &


state_name="POWER_CYCLE_NCN"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."

    # power cycle node
    ipmitool -I lanplus -U ${IPMI_USERNAME} -E -H $upgrade_ncn_mgmt_host chassis power off
    sleep 20
    ipmitool -I lanplus -U ${IPMI_USERNAME} -E -H $upgrade_ncn_mgmt_host chassis power status
    ipmitool -I lanplus -U ${IPMI_USERNAME} -E -H $upgrade_ncn_mgmt_host chassis power on

    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

state_name="WAIT_FOR_NCN_BOOT"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."
    # inline tips for watching boot logs
    cat <<EOF
TIPS:
    Watch the console for the node being rebuilt by:

    tail -f $upgrade_ncn.boot.log
EOF
    # wait for boot
    counter=0
    printf "%s" "waiting for boot: $upgrade_ncn  ..."
    while ! ping -c 1 -n -w 1 $upgrade_ncn &> /dev/null
    do
        printf "%c" "."
        counter=$((counter+1))
        if [ $counter -gt 30 ]; then
            counter=0
            ipmitool -I lanplus -U ${IPMI_USERNAME} -E -H $upgrade_ncn_mgmt_host chassis power cycle
            echo "Boot timeout, power cycle again"
        fi
        sleep 20
    done
    printf "\n%s\n" "$upgrade_ncn is booted and online"

    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

state_name="WAIT_FOR_CLOUD_INIT"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."
    # tips for watching cloud-init logs
    cat <<EOF
TIPS:
    Watch the cloud-init logs for the node being rebuilt on another terminal from stable ncn:

    ssh $upgrade_ncn 'tail -f /var/log/cloud-init-output.log'
EOF
    sleep 60
    # wait for cloud-init
    ssh-keygen -R $upgrade_ncn -f /root/.ssh/known_hosts || true
    ssh-keyscan -H $upgrade_ncn >> ~/.ssh/known_hosts || true
    printf "%s" "waiting for cloud-init: $upgrade_ncn  ..."
    while ! ssh $upgrade_ncn -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 'cat /var/log/messages  | grep "Cloud-init" | grep "finished"' &> /dev/null
    do
        printf "%c" "."
        sleep 20
    done
    printf "\n%s\n"  "$upgrade_ncn finished cloud-init"

    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

state_name="SET_BSS_NO_WIPE"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "====> ${state_name} ..."

    csi handoff bss-update-param --set metal.no-wipe=1 --limit $UPGRADE_XNAME
    
    record_state "${state_name}" ${upgrade_ncn}
else
    echo "====> ${state_name} has been completed"
fi

if [[ ${upgrade_ncn} == "ncn-m001" ]]; then
   state_name="RESTORE_M001_NET_CONFIG"
   state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
   if [[ $state_recorded == "0" ]]; then
      echo "====> ${state_name} ..."
      
      ssh-keygen -R ncn-m001 -f /root/.ssh/known_hosts
      ssh-keyscan -H ncn-m001 >> ~/.ssh/known_hosts
      scp ifcfg-lan0 root@ncn-m001:/etc/sysconfig/network/ifcfg-lan0
      scp ifroute-lan0 root@ncn-m001:/etc/sysconfig/network/ifroute-lan0
      ssh root@ncn-m001 'wicked ifreload lan0'
      record_state "${state_name}" ${upgrade_ncn}
   else
      echo "====> ${state_name} has been completed"
   fi
fi

if [[ ${upgrade_ncn} != ncn-s* ]]; then
   state_name="CRAY_INIT"
   state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
   if [[ $state_recorded == "0" ]]; then
      echo "====> ${state_name} ..."
      
      ssh-keygen -R $UPGRADE_NCN -f /root/.ssh/known_hosts
      ssh-keyscan -H $UPGRADE_NCN >> ~/.ssh/known_hosts
      ssh $UPGRADE_NCN 'cray init --no-auth --overwrite --hostname https://api-gw-service-nmn.local'
      
      record_state "${state_name}" ${upgrade_ncn}
   else
      echo "====> ${state_name} has been completed"
   fi
fi

if [[ ${upgrade_ncn} != ncn-s* ]]; then
   state_name="NTP_SETUP"
   state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
   if [[ $state_recorded == "0" ]]; then
      echo "====> ${state_name} ..."
      
      ssh-keygen -R $UPGRADE_NCN -f /root/.ssh/known_hosts
      ssh-keyscan -H $UPGRADE_NCN >> ~/.ssh/known_hosts

      echo "Ensuring cloud-init on $UPGRADE_NCN is healthy"
      ssh $UPGRADE_NCN 'cloud-init query -a > /dev/null 2>&1'
      rc=$?
      if [[ "$rc" -ne 0 ]]; then
        echo "cloud-init on $UPGRADE_NCN isn't healthy -- re-running 'cloud-init init' to repair cached data"
        ssh $UPGRADE_NCN 'cloud-init init > /dev/null 2>&1'
      fi

      ssh $UPGRADE_NCN '/srv/cray/scripts/metal/ntp-upgrade-config.sh'
      
      record_state "${state_name}" ${upgrade_ncn}
   else
      echo "====> ${state_name} has been completed"
   fi
fi