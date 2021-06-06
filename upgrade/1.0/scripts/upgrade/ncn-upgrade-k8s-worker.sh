#!/bin/bash
#
# Copyright 2021 Hewlett Packard Enterprise Development LP
#
set -e
BASEDIR=$(dirname $0)
. ${BASEDIR}/upgrade-state.sh

upgrade_ncn=$1

. ${BASEDIR}/ncn-upgrade-common.sh ${upgrade_ncn}

cat <<EOF
NOTE: 
    In upgrade/1.0/resource_material/stage3/k8s-worker-node-upgrade.md
    step 1 and 2 are not automated
EOF
read -p "Read and act on above steps. Press any key to continue ..."

state_name="ENSURE_NEXUS_CAN_START_ON_ANY_NODE"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "${state_name} ..."
    
    workers="$(kubectl get node --selector='!node-role.kubernetes.io/master' -o name | sed -e 's,^node/,,' | paste -sd,)"
    export PDSH_SSH_ARGS_APPEND="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    yq r ./${CSM_RELEASE}/manifests/platform.yaml 'spec.charts(name==cray-precache-images).values.cacheImages[*]' | while read image; do echo >&2 "+ caching $image"; pdsh -w "$workers" "crictl pull $image"; done

    record_state "${state_name}" ${upgrade_ncn}
    echo
else
    echo "${state_name} has beed completed"
fi

# TODO: automate this by a while loop
cat <<EOF
NOTE: 
    Ensure that the previously rebuilt worker node (if applicable) has started any etcd pods (if necessary). We don't want to begin rebuilding the next worker node until etcd pods have reached quorum. Run the following command, and pause on this step until all pods are in a Running state:

    kubectl get po -A -l 'app=etcd' | grep -v "Running"

EOF
read -p "Read and act on above steps. Press any key to continue ..."

# TODO: duplicate code
state_name="DRAIN_NODE"
state_recorded=$(is_state_recorded "${state_name}" ${upgrade_ncn})
if [[ $state_recorded == "0" ]]; then
    echo "${state_name} ..."
    rpm -Uvh https://storage.googleapis.com/csm-release-public/shasta-1.5/docs-csm-install/docs-csm-install-latest.noarch.rpm || true
    /usr/share/doc/csm/upgrade/1.0/scripts/k8s/remove-k8s-node.sh $UPGRADE_NCN
    
    record_state "${state_name}" ${upgrade_ncn}
    echo
else
    echo "${state_name} has beed completed"
fi

${BASEDIR}/ncn-upgrade-k8s-nodes.sh $upgrade_ncn

ssh $upgrade_ncn 'GOSS_BASE=/opt/cray/tests/install goss -g /opt/cray/tests/install/ncn/suites/ncn-upgrade-tests-worker.yaml --vars=/opt/cray/tests/install/ncn/vars/variables-ncn.yaml validate'

cat <<EOF
Make sure above goss test passed before continue. 

NOTE: if BGP failure is detected above, following the steps in the 'Check BGP Status and Reset Sessions' section in the admin guide for steps to verify and fix BGP if needed
EOF
read -p "Read above steps and press any key to continue ..."