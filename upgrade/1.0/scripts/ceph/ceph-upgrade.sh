###
# Part 1.  Prep work
###

file="/etc/cray/ceph/_upgraded"
pre_pull_images_file="/etc/cray/ceph/images_pre_pulled"
scale_down_cephfs_clients_file="/etc/cray/ceph/cephfs_scaled_down"
scale_up_cephfs_clients_file="/etc/cray/ceph/cephfs_scaled_up"
convert_rgw_file="/etc/cray/ceph/radosgw_converted"
upgrade_init_file="/etc/cray/ceph/upgrade_initialized"
upgrade_mons_file="/etc/cray/ceph/mons_upgraded"
upgrade_mgrs_file="/etc/cray/ceph/mgrs_upgraded"
distribute_keys_file="/etc/cray/ceph/keys_distributed"
setup_orch_file="/etc/cray/ceph/converted_to_orch"
upgrade_osds_file="/etc/cray/ceph/osds_upgraded"
upgrade_mds_file="/etc/cray/ceph/mds_upgraded"
upgrade_rgws_file="/etc/cray/ceph/rgws_upgraded"
num_storage_nodes=$(craysys metadata get num-storage-nodes)
registry="${1:-registry.local}"

. ./lib/ceph-health.sh
. ./lib/mark_step_complete.sh
. ./lib/k8s-scale-utils.sh
. ./lib/ceph-image-pull.sh
. ./lib/convert-radosgw.sh
. ./lib/ceph-upgrade-init.sh
. ./lib/ceph-upgrade-mons.sh
. ./lib/ceph-upgrade-mgrs.sh
. ./lib/cephadm-keys.sh
. ./lib/ceph-orch-tasks.sh
. ./lib/ceph-upgrade-osds.sh
. ./lib/update_container_images.sh
. ./lib/ceph-upgrade-mdss.sh
. ./lib/ceph-upgrade-rgws.sh

if [ ! -d "/etc/cray" ]; then
  mkdir /etc/cray
fi

if [ ! -d "/etc/cray/ceph" ]; then
 mkdir /etc/cray/ceph
fi

for node in $(seq 1 $num_storage_nodes); do
 nodename=$(printf "ncn-s%03d" $node)
 ssh-keyscan -H $nodename >> ~/.ssh/known_hosts
done

for node in $(seq 1 $num_storage_nodes); do
 nodename=$(printf "ncn-s%03d.nmn" $node)
 ssh-keyscan -H $nodename >> ~/.ssh/known_hosts
done

if [ -f "$pre_pull_images_file" ]; then
  echo "Images have already been pre-pulled"
else
  echo "Pre-pulling ceph images"
  pre_pull_ceph_images
  mark_initialized $pre_pull_images_file
fi

if [ -f "$scale_down_cephfs_clients_file" ]; then
  echo "cephfs clients have been scaled down"
else
  echo "Scaling down cephfs clients"
  scale_down_cephfs_clients
  mark_initialized $scale_down_cephfs_clients_file
fi

if [ -f "$convert_rgw_file" ]; then
  echo "Radosgw has already been converted"
else
  echo "Converting radosgw to a cephadm compatible config"
  convert_radosgw
  echo "restarting radosgw daemons"
  restart_radosgw_daemons
  mark_initialized $convert_rgw_file
fi

if [ -f "$upgrade_init_file" ]; then
  echo "This cephadm preparation has already been completed"
else
  echo "Preparing cephadm to upgrade ceph"
  ceph_upgrade_init
  echo "Sleeping 10 second"
  mark_initialized $upgrade_init_file
fi

### Begin run on each mon/mgr

if [ -f "$upgrade_mons_file" ]; then
  echo "The ceph mon daemons have been upgraded"
else
  echo "upgrading ceph mons"
  upgrade_ceph_mons
  ## Check if everything was coverted
  ## FIXME - ceph orch is not available yet.  
  #echo "Validating ceph-mon has been converted"
  #ceph -f json-pretty orch ps|jq -r '.[]|select(.daemon_type|test("mon"))|.hostname'
  #ceph -f json-pretty orch ps|jq -r '.[]|select(.hostname|test("ncn-s001"))|.daemon_type'
  mark_initialized $upgrade_mons_file
fi


if [ -f "$upgrade_mgrs_file" ]; then
  echo "The ceph mgr daemons have been upgraded"
else
  echo "upgrading ceph"
  upgrade_ceph_mgrs
  #Add check for mgrs here (find else repeat)
  mark_initialized $upgrade_mgrs_file
fi


### End run on each mon/mgr

if [ -f "$distribute_keys_file" ]; then
  echo "This ceph cluster keys have already been distributed"
else
  echo "Creating and distributing keys for cephadm"
  create_cephadm_keys
  mark_initialized $distribute_keys_file
fi

if [ -f "$setup_orch_file" ]; then
  echo "This ceph cluster has been converted to ceph-orchestrator"
else
  echo "upgrading ceph"
  ceph_orch_tasks
  wait_for_orch_hosts
  mark_initialized $setup_orch_file
fi

ceph -s

if [ -f "$upgrade_osds_file" ]; then
  echo "The osds daemons have been upgraded"
else
  echo "Upgrading ceph OSDs..."
  upgrade_osds
  wait_for_osds
  mark_initialized $upgrade_osds_file
fi

update_image_values

echo "disable stray host/daemon warnings"
ceph config set mgr mgr/cephadm/warn_on_stray_hosts false
ceph config set mgr mgr/cephadm/warn_on_stray_daemons false

echo "Sleeping 30 seconds to allow daemons to being launching..."
sleep 30

wait_for_running_daemons mon 3
wait_for_running_daemons mgr 3

if [ -f "$upgrade_mds_file" ]; then
  echo "The MDS daemons have been upgraded"
else
  echo "Upgrading MDS(s)..."
  upgrade_mds
  mark_initialized $upgrade_mds_file
fi

if [ -f "$upgrade_rgws_file" ]; then
  echo "The radosgw daemons have been upgraded"
else
  echo "Upgrading radosgw to 15.2.8"
  upgrade_rgws
  wait_for_running_daemons rgw 3
  echo "Enabling STS"
  enable_sts
  mark_initialized $upgrade_rgws_file
fi

echo "enable ceph orch to manage all services"
ceph orch apply mon --placement="3 $(ceph node ls|jq -r '.mon|keys| join(" ")')"
ceph orch apply mgr --placement="3 $(ceph node ls|jq -r '.mon|keys| join(" ")')"

echo "enable stray host warnings"
ceph config set mgr mgr/cephadm/warn_on_stray_hosts true
ceph config set mgr mgr/cephadm/warn_on_stray_daemons true

wait_for_health_ok

if [ -f "$scale_up_cephfs_clients_file" ]; then
  echo "cephfs clients have been scaled up"
else
  echo "Scaling up cephfs clients"
  scale_up_cephfs_clients
  mark_initialized $scale_up_cephfs_clients_file
fi
