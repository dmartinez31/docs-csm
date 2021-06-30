## Rebuild NCNs

Rebuild or re-image a master, worker, or storage non-compute node \(NCN\). Use this procedure in the event that a node has a hardware failure, or some other issue with the node has occurred that warrants rebuilding the node.

### Prerequisites

The system is fully installed and has transitioned off of the LiveCD.

### Procedure

#### Prepare Nodes

Only follow the step in this section for the node type being rebuilt:

-   NCN worker node: step [1](#step1)
-   NCN master node: step [2](#step2)
-   NCN storage node: step [3](#step3)

<a name="step1"></a>

1.  Prepare an NCN worker node before rebuilding it.

    Skip this step if rebuilding an NCN master or storage node. The examples in this step assume `ncn-w002` is being rebuilt.

    1.  Determine if the worker being rebuilt is running the cray-cps-cm-pm pod.

        If the cray-cps-cm-pm pod is running, there will be an extra step to redeploy this pod after the node is rebuilt.

        ```bash
        ncn-m001# cray cps deployment list --format json | grep -C1 podname
            "node": "ncn-w002",
            "podname": "cray-cps-cm-pm-j7td7"
          },
        --
            "node": "ncn-w001",
            "podname": "cray-cps-cm-pm-lzbhm"
          },
        --
            "node": "ncn-w003",
            "podname": "NA"
          },
        --
            "node": "ncn-w004",
            "podname": "NA"
          },
        --
            "node": "ncn-w005",
            "podname": "NA"
          }
        ```

        In this case, the `ncn-w001` and `ncn-w002` nodes have the pod.

    2.  Confirm what the Configuration Framework Service \(CFS\) setting is for the desired state before shutting down the node.

        The following command will indicate if a CFS job is currently in progress.

        ```bash
        ncn-m001# cray cfs components describe XNAME --format json
        {
          "configurationStatus": "configured",
          "desiredConfig": "ncn-personalization-full",
          "enabled": true,
          "errorCount": 0,
          "id": "x3000c0s7b0n0",
          "retryPolicy": 3,
        ```

        If the state is pending, tail the logs of the cray-cps-cm-pm pod to see the job finish before rebooting this node. If the state is failed for this node, this means the failed CFS job state preceded this worker rebuild, and that can be addressed independent of rebuilding this worker.

    3.  Drain the node to clear any pods running on the node.

        The following command will both cordon and drain the node. If there are messages indicating that the pods cannot be evicted because of a pod distribution budget, note those pod names and manually delete them.

        ```bash
        ncn-m001# kubectl drain --ignore-daemonsets --delete-local-data ncn-w002
        ```

    4.  Remove the node from the cluster after the node is drained.

        ```bash
        ncn-m001# kubectl delete node ncn-w002
        ```

<a name="step2"></a>

2.  Prepare an NCN master node before rebuilding it.

    Skip this step if rebuilding an NCN worker or storage node. The examples in this step assume `ncn-m002` is being rebuilt. The commands should be run on a master node that is remaining in the cluster.

    1.  Determine if the master node being rebuilt is the first master node.

        The first master node is the node others contact to join the Kubernetes cluster. If this is the node being rebuilt, promote another master node to the initial node before proceeding. Run the following command from any master node:

        ```bash
        ncn-m# craysys metadata get first-master-hostname
        ncn-m002
        ```

        If the node returned isn't the one being rebuilt, proceed to step [2.8](#stop-etcd).

    2.  Reconfigure the Boot Script Service \(BSS\) to point to a new first master node.

        Run this step on a master or worker node that is not being rebuilt.

        ```bash
        ncn# cray bss bootparameters list --name Global --format=json | jq '.[]' > Global.json
        ```

    3.  Edit the Global.json file and edit the indicated line.

        Change the following another node that will be promoted to the first master node. In this case, the first node is changing from `ncn-m002` to `ncn-m001`, and the reverse can be done when rebuilding `ncn-m001`:

        ```bash
        "first-master-hostname": "ncn-m002",
        ```

    4.  Get a token to interact with BSS via the REST API.

        ```bash
        ncn# curl -i -s -k -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        "https://api_gw_service.local/apis/bss/boot/v1/bootparameters" \
        -X PUT -d @./Global.json
        ```

        Ensure a good response, such as `HTTP CODE 200`, is returned in the curl output.

    5.  Configure the newly promoted first master node so it is able to have other nodes join the cluster.

        SSH to the existing master node chosen in the previous steps \(`ncn-m001` in this case\), and copy/paste the following script:

        ```bash
        #!/bin/bash
        
        source /srv/cray/scripts/metal/lib.sh
        export KUBERNETES_VERSION="v$(cat /etc/cray/kubernetes/version)"
        echo $(kubeadm init phase upload-certs --upload-certs 2>&1 | tail -1) > /etc/cray/kubernetes/certificate-key
        export CERTIFICATE_KEY=$(cat /etc/cray/kubernetes/certificate-key)
        export MAX_PODS_PER_NODE=$(craysys metadata get kubernetes-max-pods-per-node)
        export PODS_CIDR=$(craysys metadata get kubernetes-pods-cidr)
        export SERVICES_CIDR=$(craysys metadata get kubernetes-services-cidr)
        envsubst < /srv/cray/resources/common/kubeadm.yaml > /etc/cray/kubernetes/kubeadm.yaml
        
        kubeadm token create --print-join-command > /etc/cray/kubernetes/join-command 2>/dev/null
        echo "$(cat /etc/cray/kubernetes/join-command) --control-plane --certificate-key $(cat /etc/cray/kubernetes/certificate-key)" > /etc/cray/kubernetes/join-command-control-plane
        
        mkdir -p /srv/cray/scripts/kubernetes
        cat > /srv/cray/scripts/kubernetes/token-certs-refresh.sh <<'EOF'
        #!/bin/bash
        
        if [[ "$1" != "skip-upload-certs" ]]; then
          kubeadm init phase upload-certs --upload-certs --config /etc/cray/kubernetes/kubeadm.yaml
        fi
        kubeadm token create --print-join-command > /etc/cray/kubernetes/join-command 2>/dev/null
        echo "$(cat /etc/cray/kubernetes/join-command) --control-plane --certificate-key $(cat /etc/cray/kubernetes/certificate-key)" \
          > /etc/cray/kubernetes/join-command-control-plane
        
        EOF
        chmod +x /srv/cray/scripts/kubernetes/token-certs-refresh.sh
        /srv/cray/scripts/kubernetes/token-certs-refresh.sh skip-upload-certs
        echo "0 */1 * * * root /srv/cray/scripts/kubernetes/token-certs-refresh.sh >> /var/log/cray/cron.log 2>&1" > /etc/cron.d/cray-k8s-token-certs-refresh
        ```

    6.  Find the member ID of the master node being removed.

        ```bash
        ncn-m001# etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        --cert=/etc/kubernetes/pki/etcd/ca.crt  \
        --key=/etc/kubernetes/pki/etcd/ca.key --endpoints=localhost:2379 member list
        ```

        Note the returned member ID for use in subsequent steps.

    7.  Remove the master node from the etcd cluster backing Kubernetes.

        Replace the MEMBER\_ID value with the value returned in the previous sub-step.

        ```bash
        ncn-m001# etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        --cert=/etc/kubernetes/pki/etcd/ca.crt --key=/etc/kubernetes/pki/etcd/ca.key \
        --endpoints=localhost:2379 member remove MEMBER_ID
        ```
    
    <a name="stop-etcd"></a>

    8.  Stop the etcd service on the master node being removed.

        ```bash
        ncn-m001# systemctl stop etcd.service
        ```

    9.  Remove the node from the Kubernetes cluster.

        ```bash
        ncn-m001# kubectl delete node ncn-m002
        ```

<a name="step3"></a>

3.  Prepare an NCN storage node before rebuilding it.

    Skip this step if rebuilding an NCN master or worker node. The examples in this step assume `ncn-s003` is being rebuilt.

    1.  Check the status of Ceph.

        Check the OSD status, weight, and location:

        ```bash
        ncn-s001# ceph osd tree
        ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF
        -1       20.95917 root default
        -3        6.98639     host ncn-s001
         2   ssd  1.74660         osd.2         up  1.00000 1.00000
         5   ssd  1.74660         osd.5         up  1.00000 1.00000
         8   ssd  1.74660         osd.8         up  1.00000 1.00000
        11   ssd  1.74660         osd.11        up  1.00000 1.00000
        -7        6.98639     host ncn-s002
         0   ssd  1.74660         osd.0         up  1.00000 1.00000
         4   ssd  1.74660         osd.4         up  1.00000 1.00000
         7   ssd  1.74660         osd.7         up  1.00000 1.00000
        10   ssd  1.74660         osd.10        up  1.00000 1.00000
        -5        6.98639     host ncn-s003
         1   ssd  1.74660         osd.1       down        0 1.00000
         3   ssd  1.74660         osd.3       down        0 1.00000
         6   ssd  1.74660         osd.6       down        0 1.00000
         9   ssd  1.74660         osd.9       down        0 1.00000
        ```

        Check the status of the Ceph cluster:

        ```bash
        ncn-s001# ceph -s
          cluster:
            id:     22d01fcd-a75b-4bfc-b286-2ed8645be2b5
            health: HEALTH_WARN
                    4 osds down
                    1 host (8 osds) down
                    Degraded data redundancy: 923/2768 objects degraded (33.345%), 94 pgs degraded
                    1/3 mons down, quorum ncn-s001,ncn-s002
         
          services:
            mon: 3 daemons, quorum ncn-s001,ncn-s002 (age 43s), out of quorum: ncn-s003
            mgr: ncn-s001(active, since 18h), standbys: ncn-s002
            mds: cephfs:1 {0=ncn-s001=up:active} 1 up:standby
            osd: 16 osds: 8 up (since 34s), 12 in (since 34m)
            rgw: 2 daemons active (ncn-s001.rgw0, ncn-s002.rgw0)
         
          task status:
            scrub status:
                mds.ncn-s001: idle
         
          data:
            pools:   10 pools, 480 pgs
            objects: 923 objects, 29 KiB
            usage:   12 GiB used, 21 TiB / 21 TiB avail
            pgs:     923/2768 objects degraded (33.345%)
                     369 active+undersized
                     94  active+undersized+degraded
                     17  active+clean
        ```

    2.  If the node is a ceph-mon node, remove it from the mon map.

        Skip this step if the node is not a ceph-mon node.

        The output in the previous sub-step indicated `out of quorum: ncn-s003`.

        ```bash
        ncn-s001# ceph mon dump
        dumped monmap epoch 5
        epoch 5
        fsid 22d01fcd-a75b-4bfc-b286-2ed8645be2b5
        last_changed 2021-03-05 15:14:09.142113
        created 2021-03-04 20:50:38.141908
        min_mon_release 14 (nautilus)
        0: [v2:10.252.1.9:3300/0,v1:10.252.1.9:6789/0] mon.ncn-s001
        1: [v2:10.252.1.10:3300/0,v1:10.252.1.10:6789/0] mon.ncn-s002
        2: [v2:10.252.1.11:3300/0,v1:10.252.1.11:6789/0] mon.ncn-s003
        
        ```

        Remove the out of quorum node from the mon map. Replace the NODE\_NAME value with the name of the known down ceph-mon node.

        ```bash
        ncn-s001# cd /etc/ansible/ceph-ansible
        ncn-s001# ceph mon rm NODE_NAME
        removing mon.ncn-s003 at [v2:10.252.1.11:3300/0,v1:10.252.1.11:6789/0], there will be 2 monitors
        ```

        The Ceph cluster will now show as healthy. However, there will now only be two monitors, which is not an ideal situation because if there is another Ceph mon outage then the cluster will go read-only.

        ```bash
        ncn-s001# ceph -s
          cluster:
            id:     22d01fcd-a75b-4bfc-b286-2ed8645be2b5
            health: HEALTH_WARN
                    Degraded data redundancy: 588/2771 objects degraded (21.220%), 60 pgs degraded, 268 pgs undersized
         
          services:
            mon: 2 daemons, quorum ncn-s001,ncn-s002 (age 4m)
            mgr: ncn-s001(active, since 18h), standbys: ncn-s002
            mds: cephfs:1 {0=ncn-s001=up:active} 1 up:standby
            osd: 12 osds: 8 up (since 9m), 8 in (since 42m); 148 remapped pgs
            rgw: 2 daemons active (ncn-s001.rgw0, ncn-s002.rgw0)
         
          task status:
            scrub status:
                mds.ncn-s001: idle
         
          data:
            pools:   10 pools, 480 pgs
            objects: 924 objects, 30 KiB
            usage:   8.0 GiB used, 14 TiB / 14 TiB avail
            pgs:     588/2771 objects degraded (21.220%)
                     307/2771 objects misplaced (11.079%)
                     208 active+undersized
                     138 active+clean+remapped
                     74  active+clean
                     60  active+undersized+degraded
        ```

    3.  Remove Ceph OSDs.

        The ceph osd tree capture indicated that there are down OSDs on `ncn-s003`.

        ```bash
        -5        6.98639     host ncn-s003
         1   ssd  1.74660         osd.1       down        0 1.00000
         3   ssd  1.74660         osd.3       down        0 1.00000
         6   ssd  1.74660         osd.6       down        0 1.00000
         9   ssd  1.74660         osd.9       down        0 1.00000
        ```

        Remove the OSDs to prevent the install from creating new OSDs on the drives, but there is still a reference to them in the crush map. It will time out trying to restart the old OSDs because of that reference.

        Replace NODE\_NAME with the host you are removing

        ```bash
        # for osd in $(ceph osd ls-tree NODE_NAME); do ceph osd destroy osd.$osd \
        --force;  ceph osd purge osd.$osd --force; done
        destroyed osd.1
        purged osd.1
        destroyed osd.3
        purged osd.3
        destroyed osd.6
        purged osd.6
        destroyed osd.9
        purged osd.9
        ```

#### Identify Nodes and Update Metadata

<a name="step4"></a>

4. Retrieve the xname for the node being removed.

   This xname is available on the node being rebuilt in the following file:

   ```bash
   ncn# cat /etc/cray/xname
   ```

   Note the xname for use in subsequent steps.

5. Generate the Boot Script Service \(BSS\) boot parameters JSON file for modification and review.

   Replace the XNAME value with the value retrieved in the previous step.

   ```bash
   ncn# cray bss bootparameters list --name XNAME --format=json > XNAME.json
   ```

<a name="step6"></a>

6. Inspect and modify the JSON file.
   1. Remove the outer array brackets.

      Remove the first and last line of the XNAME.json file, indicated with the '\[' and '\]' brackets.

   2. Ensure the current boot parameters are appropriate for PXE booting.

      Inspect the `"params": "kernel..."` line. If the line begins with `BOOT_IMAGE` and/or doesn't contain `metal.server`, the following steps are needed:

      1.  Remove everything before `kernel` on the `"params": "kernel"` line.
      2.  Re-run steps [4-5](#step4) for another node/xname. Look for an example that doesn't contain `BOOT_IMAGE`.

          Once an example is found, copy a portion of the `"params"` line for everything including and after `'biosdevname'`, and use that in the XNAME.json file.

      3.  After copying the content after `'biosdevname'`, change the `"hostname=<hostname>"` to the correct host.
7. Set the kernel parameters to wipe the disk.

   Locate the portion of the line that contains `"metal.no-wipe"` and ensure it is set to zero `"metal.no-wipe=0"`.

1. Re-apply the boot parameters list for the node using the XNAME.json file.

   1.  Get a token to interact with BSS using the REST API.

       ```bash
       ncn# export TOKEN=$(curl -s -k -S -d grant_type=client_credentials \
       -d client_id=admin-client -d client_secret=`kubectl get secrets admin-client-auth \
       -o jsonpath='{.data.client-secret}' | base64 -d` \
       https://api-gw-service-nmn.local/keycloak/realms/shasta/protocol/openid-connect/token \
       | jq -r '.access_token')
       ```

   2.  Do a PUT action for the new JSON file.

       Replace the XNAME value before running the following command.

       ```bash
       ncn# curl -i -s -k -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" \
       "https://api_gw_service.local/apis/bss/boot/v1/bootparameters" -X PUT -d @./XNAME.json
       ```

       Ensure a good response \(`HTTP CODE 200`\) is returned in the output.

2. Verify the `bss bootparameters list` command returns the expected information.

   1.  Export the list from BSS to a file with a different name.

       Replace the XNAME value before running the following command.

       ```bash
       ncn# cray bss bootparameters list --name XNAME --format=json > XNAME.check.json
       ```

   2.  Compare the new JSON file with what was PUT to BSS.

       Replace the XNAME value before running the following command. The only difference between the files should be the square brackets that were removed from the XNAME.json file.

       ```bash
       ncn# diff XNAME.json XNAME.check.json
       ```

3. Watch the console for the node being rebuilt.

   1.  Get the ConMan pod name.

       ```bash
       ncn# kubectl get po -n services| grep conman
       cray-conman-76df958b6-24jh9     3/3     Running      2          139m
       ```

   2.  Exec into the pod returned in the previous sub-step.

       ```bash
       ncn# kubectl exec -it -n services cray-conman-76df958b6-24jh9 -- /bin/sh
       ```

   3.  Connect to the console.

       ```bash
       sh-4.4# conman -j XNAME
       ```

       Enter **&** and then **.** to exit.

#### Rebuild Master and Worker NCNs

This section applies to NCN master and worker nodes. If rebuilding a storage node, proceed to step [18](#step18). All commands in this section must be run on any master or worker node that is already in the cluster and is not being rebuilt \(unless otherwise indicated\).

10. Wipe the disks on the node being rebuilt.

    This can be done from the ConMan console window.

    **Warning:** This is the point of no return. Once the disks are wiped,the node must be rebuilt.	

    ```
    ncn# wipefs --all --force /dev/sd* /dev/disk/by-label/*
    ```

11. Set the PXE boot option and power cycle the node.

    1.  Set the PXE/efiboot option.

        ```bash
        ncn# ipmitool -I lanplus -U root -P <BMC root password> \
        -H XNAME chassis bootdev pxe options=efiboot
        ```

    2.  Power off the server.

        ```bash
        ncn# ipmitool -I lanplus -U root -P <BMC root password> \
        -H XNAME chassis power off
        ```

    3.  Verify that the server is off.

        Wait a couple seconds after powering off the server before running the following command.

        ```bash
        ncn# ipmitool -I lanplus -U root -P <BMC root password> \
        -H XNAME chassis power status
        ```

    4.  Power on the server.

        ```bash
        ncn#  ipmitool -I lanplus -U root -P <BMC root password> \
        -H XNAME chassis power on
        ```

12. Observe the boot.

    After a bit, the server should begin to boot. This can be viewed from the ConMan console window. Eventually, there will be a `NBP file...` message in the console output. When this message is displayed, exit the console \(**&** then **.**\), and then SSH to the node to complete the remaining validation steps.

    **Troubleshooting:** If the `NBP file...` output never appears, or something else goes wrong, go back to the steps for modifying XNAME.json file \(see step [6](#step6)\) and make sure these instructions were completed correctly.

13. Confirm vlan004 is up with the correct IP address.

    The following examples assume the NCN/hostname is `ncn-w005`.

    1.  Find the desired IP address.

        ```bash
        ncn# dig +short ncn-w005.hmn
        10.254.1.16
        ```

    2.  Confirm the output from the dig command matches the interface.

        If the IP addresses match, proceed to the next step. If they do not match, continue with the following sub-steps.

        ```bash
        ncn# ip addr show vlan004
        14: vlan004@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
            link/ether b8:59:9f:2b:2f:9e brd ff:ff:ff:ff:ff:ff
            inet 10.254.1.16/17 brd 10.254.127.255 scope global vlan004
               valid_lft forever preferred_lft forever
            inet6 fe80::ba59:9fff:fe2b:2f9e/64 scope link
               valid_lft forever preferred_lft forever
        ```

    3.  Change the IP for vlan004 if necessary.

        ```bash
        ncn# vim /etc/sysconfig/network/ifcfg-vlan004
        ```

        Set the IPADDR line to the correct IP address with a `/17` mask.

        ```bash
        IPADDR='10.254.1.16/17'
        ```

    4.  Restart the vlan004 network interface.

        ```bash
        ncn# wicked ifreload vlan004
        ```

    5.  Confirm the output from the dig command matches the interface.

        ```bash
        ncn# ip addr show vlan004
        ```

14. Confirm that vlan007 is up with the correct IP address.

    The following examples assume the NCN/hostname is `ncn-w005`.

    1.  Find the desired IP address.

        ```bash
        ncn# dig +short ncn-w005.can
        10.103.8.11
        ```

    2.  Confirm the output from the dig command matches the interface.

        If the IP addresses match, proceed to the next step. If they do not match, continue with the following sub-steps.

        ```bash
        ncn# ip addr show vlan007
        15: vlan007@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
            link/ether b8:59:9f:2b:2f:9e brd ff:ff:ff:ff:ff:ff
            inet 10.103.8.11/24 brd 10.103.8.255 scope global vlan007
               valid_lft forever preferred_lft forever
            inet6 fe80::ba59:9fff:fe2b:2f9e/64 scope link
               valid_lft forever preferred_lft forever
        ```

    3.  Change the IP for vlan007 if necessary.

        ```bash
        ncn# vim /etc/sysconfig/network/ifcfg-vlan007
        ```

        Set the IPADDR line to the correct IP address with a `/24` mask.

        ```bash
        IPADDR='10.103.8.11/24'
        ```

    4.  Restart the vlan007 network interface.

        ```bash
        ncn# wicked ifreload vlan007
        ```

    5.  Confirm the output from the dig command matches the interface.

        ```bash
        ncn# ip addr show vlan007
        ```

15. Verify the new node is in the cluster.

    Run the following command several times to watch for the newly rebuilt node to join the cluster. This should occur within 10 to 20 minutes.

    ```bash
    ncn# kubectl get nodes
    NAME       STATUS   ROLES    AGE    VERSION
    ncn-m001   Ready    master   113m   v1.18.6
    ncn-m002   Ready    master   113m   v1.18.6
    ncn-m003   Ready    master   112m   v1.18.6
    ncn-w001   Ready    <none>   112m   v1.18.6
    ncn-w002   Ready    <none>   112m   v1.18.6
    ncn-w003   Ready    <none>   112m   v1.18.6
    ```

16. Set the wipe flag back so it will not wipe the disk when the node is rebooted.

    1.  Edit the XNAME.json file and set the `metal.no-wipe=1` value.

    2.  Do a PUT action for the edited JSON file.

        ```bash
        ncn# curl -i -s -k -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        "https://api_gw_service.local/apis/bss/boot/v1/bootparameters" \
        -X PUT -d @./XNAME.json
        ```

    The output from the ncnHealthChecks.sh script \(run later in the "Validation" steps\) can be used to verify what `metal.no-wipe` value has been set on every NCN.

17. Ensure there is proper routing set up for liquid-cooled hardware.

    SSH to the node after it is up and run the following script:

    ```bash
    ncn# /opt/cray/csm/workarounds/livecd-post-reboot/CASMINST-1570/CASMINST-1570.sh
    ```

#### Rebuild Storage NCNs

This section applies to NCN storage nodes. Proceed to step [25](#step25) if a master or worker node was rebuilt. All commands in this section must be run on any storage node that is already in the cluster and is not being rebuilt \(unless otherwise indicated\).

<a name="step18"></a>

18. SSH into the node where Ansible will run.

-   If rebuilding `ncn-s001`, SSH to either `ncn-s002` or `ncn-s003`.

    In the following storage node example steps, `ncn-s001` is being rebuilt, so `ncn-s002` is the node being used.

-   If rebuilding any other NCN storage node, SSH to `ncn-s001` and proceed to the next step.

19. Update the Ansible inventory.

    1.  Update the number of the last storage node.

        There will be no output returned from the following commands. This step changes LASTNODE into the number of the last storage node. In this example, LASTNODE is changed to `ncn-s003`.

        ```bash
        ncn-s002# source /srv/cray/scripts/commmon/fix_ansible_inv.sh
        ncn-s002# fix_inventory
        ```

    2.  Verify the Ansible inventory was changed.

        Verify that LASTNODE no longer exists in the inventory file \(/etc/ansible/hosts\).

        ```bash
        [all]
        ncn-s[001:LASTNODE].nmn
         
        [ceph_all]
        ncn-s[001:LASTNODE].nmn
         
        to:
          
        [all]
        ncn-s[001:003].nmn
         
        [ceph_all]
        ncn-s[001:003].nmn
        ```

20. Set the environment variable for the rados gateway vip.

    ```bash
    ncn-s002# cd /etc/ansible/group_vars
    ncn-s002# export RGW_VIRTUAL_IP=$(craysys metadata get rgw-virtual-ip)
    ncn-s002# echo $RGW_VIRTUAL_IP
    10.252.1.3
    ```

21. Run the ceph-ansible playbook to reinstall the node and bring it back into the cluster.

    The following example shows it running for `ncn-s001`, but where Ansible is running from is dependent on which storage NCN needs to be rebuilt.

    ```bash
    ncn-s001# cd /etc/ansible/ceph-ansible
    ncn-s001# ansible-playbook /etc/ansible/ceph-ansible/site.yml
    ```

22. Open another SSH session to a storage node that is not currently being rebuilt, and then monitor the build.	

    ```bash
    ncn-s002# watch ceph -s
    ```

23. Run the radosgw-sts-setup.yml Ansible play on `ncn-s001`.

    Ensure Ceph is healthy and the ceph-ansible playbook has finished before running the following Ansible play.

    ```bash
    ncn-s001# ansible-playbook /etc/ansible/ceph-rgw-users/radosgw-sts-setup.yml
    ```

    On the node that has been rebuilt, verify the sts values are in the ceph.conf file.

    ```bash
    ncn-s001# grep sts /etc/ceph/ceph.conf
    rgw_s3_auth_use_sts = True
    rgw_sts_key = <REDACTED_KEY>
    ```

24. Set the wipe flag back so it will not wipe the disk when the node is rebooted.
    1. Edit the XNAME.json file and set the `metal.no-wipe=1` value.

    2. Do a PUT action for the edited JSON file.

        ```bash
        ncn# curl -i -s -k -H "Content-Type: application/json" \
        -H "Authorization: Bearer $\{TOKEN\}" \
        "https://api_gw_service.local/apis/bss/boot/v1/bootparameters" \
        -X PUT -d @./XNAME.json
        ```

    The output from the ncnHealthChecks.sh script \(run later in the "Validation" steps\) can be used to verify what `metal.no-wipe` value has been set on every NCN.

#### Validation

Only follow the step in this section for the node type that was rebuilt:

-   NCN worker node: step [25](#step25)
-   NCN master node: step [26](#step26)
-   NCN storage node: step [27](#step27)

<a name="step25"></a>

25. Validate the worker node rebuilt successfully.

    Skip this step if a master node was rebuilt. The examples in this step assume `ncn-w002` was rebuilt.

    1.  Verify the new node is in the cluster.

        Run the following command from any master or worker node that is already in the cluster. It is helpful to run this command several times to watch for the newly rebuilt node to join the cluster. This should occur within 10 to 20 minutes.

        ```bash
        ncn-m001# kubectl get nodes
        NAME       STATUS   ROLES    AGE    VERSION
        ncn-m001   Ready    master   113m   v1.18.6
        ncn-m002   Ready    master   113m   v1.18.6
        ncn-m003   Ready    master   112m   v1.18.6
        ncn-w001   Ready    <none>   112m   v1.18.6
        ncn-w002   Ready    <none>   112m   v1.18.6
        ncn-w003   Ready    <none>   112m   v1.18.6
        ```

    2.  Confirm /var/lib/containerd is on overlay.

        ```bash
        ncn-m001# df -h /var/lib/containerd
        Filesystem            Size  Used Avail Use% Mounted on
        containerd_overlayfs  378G  245G  133G  65% /var/lib/containerd
        ```

        After several minutes of the node joining the cluster, pods should be in a Running state for the worker node.

    3.  Confirm the pods are beginning to get scheduled and reach a Running state on the worker node.

        ```bash
        ncn-m001# kubectl get po -A -o wide | grep ncn-w002
        ```

    4.  Confirm BGP is healthy.

        Follow the steps in the [Check BGP Status and Reset Sessions](../network/metallb_bgp/Check_BGP_Status_and_Reset_Sessions.md) to verify and fix BGP if needed.

    5.  Redeploy the cray-cps-cm-pm pod.

        This step is only required if the cray-cps-cm-pm pod was running on the node before it was rebuilt.

        ```bash
        ncn-m001# cray cps deployment update --nodes "ncn-w001,ncn-w002"
        ```

    6.  Collect data about the system management platform health \(can be run from a master or worker NCN\).

        ```bash
        ncn-m001# sh /opt/cray/platform-utils/ncnHealthChecks.sh
        ncn-m001# sh /opt/cray/platform-utils/ncnPostgresHealthChecks.sh
        ```

    <a name="step26"></a>

26. Validate the master node rebuilt successfully.

    1.  Add the newly rebuilt node to the etcd cluster.

        Manually add the node to the cluster from a healthy/existing master node. The IP and hostname of the rebuilt node is needed for the following command. Replace the NCN-M\_HOSTNAME and IP\_ADDRESS address values.

        ```bash
        ncn# etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/ca.crt \
        --key=/etc/kubernetes/pki/etcd/ca.key --endpoints=localhost:2379 member add NCN-M_HOSTNAME \
        --peer-urls=https://IP_ADDRESS:2380
        ```

        Once the new node is up, SSH to it, reconfigure the etcd service, and restart the cloud init:

        ```bash
        ncn# systemctl stop etcd.service; sed -i 's/new/existing/' \
        /etc/systemd/system/etcd.service /srv/cray/resources/common/etcd/etcd.service; \
        systemctl daemon-reload ; rm -rf /var/lib/etcd/member; \
        systemctl start etcd.service; /srv/cray/scripts/common/kubernetes-cloudinit.sh
        ```

    2.  Verify the new node is in the cluster.

        Run the following command from any master or worker node that is already in the cluster. It is helpful to run this command several times to watch for the newly rebuilt node to join the cluster. This should occur within 10 to 20 minutes.

        ```bash
        ncn-m001# kubectl get nodes
        NAME       STATUS   ROLES    AGE    VERSION
        ncn-m001   Ready    master   113m   v1.18.6
        ncn-m002   Ready    master   113m   v1.18.6
        ncn-m003   Ready    master   112m   v1.18.6
        ncn-w001   Ready    <none>   112m   v1.18.6
        ncn-w002   Ready    <none>   112m   v1.18.6
        ncn-w003   Ready    <none>   112m   v1.18.6
        ```

    3.  Confirm the `sdc` disk has the correct lvm.

        ```bash
        ncn-m001# lsblk | grep -A2 ^sdc
          sdc                   8:32   0 447.1G  0 disk
          └─ETCDLVM           254:0    0 447.1G  0 crypt
            └─etcdvg0-ETCDK8S 254:1    0    32G  0 lvm   /run/lib-etcd
        ```

    4.  Confirm etcd is running and shows the node as a member once again.

        The newly built master node should be in the returned list.

        ```bash
        ncn-m001# etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/ca.crt \
        --key=/etc/kubernetes/pki/etcd/ca.key --endpoints=localhost:2379 member list
        ```

    5.  Collect data about the system management platform health \(can be run from a master or worker NCN\).

        ```bash
        ncn-m001# sh /opt/cray/platform-utils/ncnHealthChecks.sh
        ncn-m001# sh /opt/cray/platform-utils/ncnPostgresHealthChecks.sh
        ```

    <a name="step27"></a>

27. Validate the storage node rebuilt successfully.

    1.  Verify there are 3 mons, 3 mds, 3 mgr processes, and rgw.s

        The radosgw processes determined by the /etc/ansible/hosts inventory file.

        ```bash
        ncn-m001# ceph -s
          cluster:
            id:     22d01fcd-a75b-4bfc-b286-2ed8645be2b5
            health: HEALTH_OK
         
          services:
            mon: 3 daemons, quorum ncn-s001,ncn-s002,ncn-s003 (age 4m)
            mgr: ncn-s001(active, since 19h), standbys: ncn-s002, ncn-s003
            mds: cephfs:1 {0=ncn-s001=up:active} 2 up:standby
            osd: 12 osds: 12 up (since 2m), 12 in (since 2m)
            rgw: 3 daemons active (ncn-s001.rgw0, ncn-s002.rgw0, ncn-s003.rgw0)
         
          task status:
            scrub status:
                mds.ncn-s001: idle
         
          data:
            pools:   10 pools, 480 pgs
            objects: 926 objects, 31 KiB
            usage:   12 GiB used, 21 TiB / 21 TiB avail
            pgs:     480 active+clean
        ```

    2.  Verify the OSDs are back in the cluster.

        ```bash
        ncn-m001# ceph osd tree
        ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF
        -1       20.95917 root default
        -3        6.98639     host ncn-s001
         2   ssd  1.74660         osd.2         up  1.00000 1.00000
         5   ssd  1.74660         osd.5         up  1.00000 1.00000
         8   ssd  1.74660         osd.8         up  1.00000 1.00000
        11   ssd  1.74660         osd.11        up  1.00000 1.00000
        -7        6.98639     host ncn-s002
         0   ssd  1.74660         osd.0         up  1.00000 1.00000
         4   ssd  1.74660         osd.4         up  1.00000 1.00000
         7   ssd  1.74660         osd.7         up  1.00000 1.00000
        10   ssd  1.74660         osd.10        up  1.00000 1.00000
        -5        6.98639     host ncn-s003
         1   ssd  1.74660         osd.1         up  1.00000 1.00000
         3   ssd  1.74660         osd.3         up  1.00000 1.00000
         6   ssd  1.74660         osd.6         up  1.00000 1.00000
         9   ssd  1.74660         osd.9         up  1.00000 1.00000
        ```

    3.  Verify the radosgw and haproxy are correct.

        There will be an output \(without an error\) returned if radosgw and haproxy are correct.

        ```bash
        ncn# curl -k https://rgw-vip.nmn
        <?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult
        ```

    4.  Collect data about the system management platform health \(can be run from a master or worker NCN\).

        ```bash
        ncn-m001# sh /opt/cray/platform-utils/ncnHealthChecks.sh
        ncn-m001# sh /opt/cray/platform-utils/ncnPostgresHealthChecks.sh
        ```
