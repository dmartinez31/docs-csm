# Resiliency Testing Procedure

This document and the procedure contained within it is for the purposes of communicating the kind of testing done by the internal Cray System Management team to ensure a basic level of system resiliency in the event of the loss of a single NCN. It is assumed that some procedures are already known by admins and thus does not go into great detail or attempt to encompass every command necessary for execution. It is intended to be higher level guidance (with some command examples) to inform internal users and customers about our process.

## High Level Procedure Summary:
* [Preparation for Resiliency Testing](#preparation)
* [Establish System Health Before Beginning](#establish-system-health)
* [Monitoring for Changes](#monitoring-for-changes)
* [Launch a Non-Interactive Batch Job](#launch-batch-job)
* [Shut Down an NCN](#shut-down-ncn)
* [Conduct Testing](#conduct-testing)
* [Power On the Downed NCN](#power-on-ncn)
* [Execute Post-Boot Health Checks](#post-boot-health-check)

<a name="preparation"></a>
### Preparation for Resiliency Testing

* xname mapping for each node on the system - this get dumped out by execution of the `/opt/cray/platform-utils/ncnGetXnames.sh` script.
* also note that `metal.no-wipe=1` is set for each of the NCNs - via ouptput from running the ncnGetXnames.sh script
* ensure that you can run as an authorized user on the Cray CLI - login as a user account you have access to
   ```bash
   ncn# export CRAY_CONFIG_DIR=$(mktemp -d); echo $CRAY_CONFIG_DIR; cray init --configuration default --hostname https://api-gw-service-nmn.local
   /tmp/tmp.ShkBrUfhsJ
   Username: username
   Password:
   Success!
   ```
   Then validate the authorization by executing the 'cray uas list' command, for example. For more information see the `Validate UAI Creation` section of [Validate CSM Health](../validate_csm_health.md).
* Verify that `kubectl get nodes` reports all Master and worker nodes are `Ready`.
   ```bash
   ncn# kubectl get nodes -o wide
   ```
* Get a current list of pods that have a status of anything other than `Running` or `Completed`. Investigate any of concern. Save the list of pods for comparison once resiliency testing is completed and the system has been restored.
   ```bash
   ncn# kubectl get pods -o wide -A | grep -Ev 'Running|Completed'
   ```
* Note which pods are running on an NCN that will be taken down (as well as the total number of pods running). Here is an example that shows the listing of pods running on `ncn-w001`:
   ```bash
   ncn# kubectl get pods -o wide -A | grep ncn-w001 | awk '{print $2}'
   ```
   Note that the above would only apply to kubernetes nodes like master and worker nodes (ncn-m00x and ncn-w00x)
* Verify ipmitool can report power status for the NCN node to be shutdown
   ```bash
   ncn# ipmitool -I lanplus -U root -P <password> -H <ncn-node-name> chassis power status
   ```
   If `ncn-m001` is the node to be brought down, note that it has the external connection so it will be important to establish that ipmitool commands will be able to be run from a node external to the system, in order to get the ipmitool power staus of `ncn-m001`.
* If `ncn-m001` is the node to take down, establish CAN links to bypass `ncn-m001` (since it will be down) in order to enable an external connection to one of the other master ncn nodes before, during, and after `ncn-m001` is brought down.
* Verify BOS templates and create a new one(s) if needed (to be set-up for booting a specific compute node(s) after the targeted NCN node has been shutdown
   Ahead of shutting down the NCN and beginning resiliency testing, we want to verify that compute nodes identified for reboot validation can be successfully rebooted and configured.
   To see a listing of bos templates that exist on the system, run:
   ```bash
   ncn# cray bos v1 sessiontemplate list
   ```
   For more information regarding management of bos session templates, refer to [Manage a Session Template](../boot_orchestration/Manage_a_Session_Template.md).
* If a UAN is present on the system, log onto it and verify that the WLM (work load manager) is configured by running a command (example for slurm):
   ```bash
   uan# srun -N 4 hostname | sort
   ```

<a name="establish-system-health"></a>
### Establish System Health Before Beginning

In order to ensure that the system is healthy before taking an NCN node down, run the `Platform Health Checks` section of [Validate CSM Health](../validate_csm_health.md).

If health issues are noted, it is best to address those before proceeding with the resiliency testing procedure. If it is believed (in the case of an internal Cray-HPE testing environment) that the issue is known/understood and will not impact the testing to be performed, then those health issues just need to be noted (so that it does not appear that they were caused by inducing the fault, in this case, powering off the NCN). There is an optional section of the platform health validation that deals with using the System Management monitoring tools to survey system health. If that optional validation is included, please note that the prometheus alert manager may show various alerts that would not prevent or block moving forward with this testing. For more information about prometheus alerts (and some that can be safely ignored), reference [Troubleshooting Prometheus Alerts](../system_management_health/Troubleshoot_Prometheus_Alerts.md).

Part of the data being returned via execution of the `Platform Health Checks` includes patronictl info for each postgres cluster. Each of the postgres clusters has a leader pod, and in the case of a resiliency test that involves bringing an NCN worker node down, it may be useful to take note of the postgres clusters that have their leader pods running on the NCN worker targeted for shutdown. The postgres-operator should handle re-establishment of a leader on another pod running in the cluster, but it is worth taking note of where leader re-elections are expected to occur so special attention can be given to those postgres clusters. The postgres health check is included in [Validate CSM Health](../validate_csm_health.md), but the script for dumping postgres data can be run at any time:
   ```bash
   ncn# /opt/cray/platform-utils/ncnPostgresHealthChecks.sh
   ```
<a name="monitoring-for-changes"></a>
### Monitoring for Changes

In order to keep watch on various items during and after the fault has been introduced (in this case, the shutdown of a single NCN node), the steps listed below can help give insight into changing health conditions. It is an eventual goal to strive for a monitoring dashboard which would help track these sort of things in a single or few automated views. Until that can be incorporated, these kinds of command prompt sessions can be useful.

* It is important to ensure that critical services can ride through a fault, and as such, it is recommended to set up a 'watch' command which will repeatedly run via the Cray CLI (that will hit the service API) and note that there is not more than a window of 5-10 minutes where a service that we are polling would, intermittently, fail to respond. In the examples below, the CLI commands are checking the bos and cps APIs. It may be desired to choose additional Cray CLI commands to run in this manner. The ultimate proof of system resiliency lies in the ability to perform system level use cases and to, further, prove that can be done at scale. If there are errors being returned, consistently (and without recovery), with respect to these commands, it is likely that business critical use cases (that utilize the same APIs) will also fail.

   It may be useful to reference instructions for [Configuring the Cray CLI](../configure_cray_cli.md).

   ```bash
   ncn# watch -n 5 "date; cray cps contents"
   ```
   ```bash
   ncn# watch -n 5 "date; cray bos v1 session list"
   ```
* Monitor ceph health, in a window, during the and after a single NCN node is taken down:
   ```bash
   ncn# watch -n 5 "date; ceph -s"
   ```
* The following commands (run in separate windows) can also help identify when pods (on a downed master or worker NCN) are no longer responding. This takes around 5 -6 minutes, and kubernetes will begin terminating pods so that new pods to replace them can start-up on another NCN. Pods that had been running on the downed NCN will remain in Terminated state until the NCN is back up. Pods that need to start-up on other nodes will be Pending until they start-up. Some pods that have anti-affinity configurations or that run as daemonsets will not be able to start up on another NCN. Those pods will remain in Pending state until the NCN is back up. Finally, it is helpful to have a window tracking the list of pods that are not in Completed or Running state to be able to determine how that list is changing once the NCN is downed and pods begin shifting around. This step offers a view of what is going on at the time that the NCN is brought down and once kubernetes detects an issue and begins remediation. It is not so important to capture everything that is happening during this step. It may be helpful for debugging. The output of these windows/commands becomes more interesting once you have brought the NCN down for a period of time and then bring it back up. At that point, the expectation is that everything can recover. 
   ```bash
   ncn# watch -n 5 "date; kubectl get pods -o wide -A | grep Termin"
   ```
   ```bash
   ncn# watch -n 10 "date; kubectl get pods -o wide -A | grep Pending"
   ```
   ```bash
   ncn# watch -n 5 "date; kubectl get pods -o wide -A | grep -v Completed | grep -v Running"
   ```
* This command run in a window can also help detect the change in state of the various postgres instances running. Should there be a case of postgres status that deviates from `Running`, that would require further investigation and possibly remediation via [Troubleshooting the Postgres Database](../kubernetes/Troubleshoot_Postgres_Database.md).
   ```bash
   ncn# watch -n 30 "date; kubectl get postgresql -A"
   ```

<a name="launch-batch-job"></a>
### Launch a Non-Interactive Batch Job

The purpose of this procedure is to launch a non-interactive, long-running batch job across computes via a UAI (or the UAN, if present) in order to ensure that even though the UAI pod used to launch the job is running on the NCN worker node being taken down, it will start up on another NCN worker (once kubernetes begins terminating pods). Additionally, it is important to verify that the batch job continued to run, uninterrupted through that process. If the target NCN for shutdown is not a worker node (where a uai would be running), then there is no need to pay attention to the steps, below, that discuss ensuring the uai can only be created on the NCN worker node that is targeted for shutdown. If executing a shut down of a master or storage NCN, the procedure can begin at creating a uai. It is still good to ensure that non-interactive batch jobs are uninterrupted, even with the uai they are launched from is not being disrupted.
#### Launching on a UAI
* Create a UAI. If target node for shutdown is a worker NCN, force the UAI to be created on target worker NCN.
   The following steps will create labels to ensure that uai pods will only be able to start-up on the target worker NCN - in this example `ncn-w002` is the target node for shutdown (on a system with only 3 NCN worker nodes).
   ```bash
   ncn# kubectl label node ncn-w001 uas=False --overwrite
   node/ncn-w001 labeled
   ncn# kubectl label node ncn-w003 uas=False --overwrite
   node/ncn-w003 labeled
   ```
   ```bash
   ncn# kubectl get nodes -l uas=False
   NAME       STATUS   ROLES    AGE     VERSION
   ncn-w001   Ready    <none>   4d19h   v1.18.2
   ncn-w003   Ready    <none>   4d19h   v1.18.2
   ```
   It is **EXTREMELY IMPORTANT** to note that after a uai has been created, that we clear out these labels or else when kubernetes terminates the running uai on the NCN being shut down, it will not be able to reschedule the uai on another pod.
   To create a uai, see the `Validate UAI Creation` section of [Validate CSM Health](../validate_csm_health.md) and/or [Create a UAI](../UAS_user_and_admin_topics/Create_a_UAI.md).
   To remove the labels set above after the uai has been created, run the following:
   ```bash
   ncn# kubectl label node ncn-w001 uas-
   ncn# kubectl label node ncn-w003 uas-
   ```
* Within the created uai, verify that WLM is configured with the appropriate workload manager.
   Verify the connection string of the created uai:
   ```bash
   ncn# jolt1-ncn-w001:~ # cray uas list
   [[results]]
   username =  "uastest"
   uai_host =  "ncn-w001"
   uai_status =  "Running: Ready"
   uai_connect_string = "ssh uastest@172.30.48.49 -p 31137 -i ~/.ssh/id_rsa"
   uai_img =  "bis.local:5000/cray/cray-uas-sles15sp1-slurm:latest"
   uai_age =  "1m"
   uai_name =  "uai-uastest-5653e9b9"
   ```
   Login to the created uai (example):
   ```bash
   ncn# ssh uastest@172.30.48.49 -p 31137 -i ~/.ssh/id_rsa
   ```
   To verify the configuration of slurm, for example, within the uai:
   ```bash
   uastest@uai-uastest-5653e9b9:/lus/uastest> srun -N 4 hostname | sort
   nid000001
   nid000002
   nid000003
   nid000004
   ```
* Copy an MPI application source and WLM (workload manager) batch job files to the uai
* Within UAI compile an MPI application. Launch application as batch job (not interactive) on compute node(s) that have not been designated, already, for reboots once an NCN is shut down.
   * Verify that batch job is running and that application output is streaming to a file. Streaming output will be used to verify that the batch job is still running during resiliency testing. A batch job, when submitted, will designate a log file location. This log file can be accessed to be able to verify that the batch job is continuing to run after an NCN is brought down and once it is back online. Additionally, the `squeue` command can be used to verify that the job continues to run (for slurm).
   * When all testing has been completed, a uai session can be deleted with:
   ```bash
   ncn# cray uas delete --uai-list uai-uastest-5653e9b9
   ```
#### Launching on a UAN
* Login to the UAN and verify that a WLM (workload manager) has been properly configured (in this case, slurm will be used)
   ```bash
   uan01# srun -N 4 hostname | sort
   nid000001
   nid000002
   nid000003
   nid000004
   ```
* Copy an MPI application source and WLM batch job files to UAN
* Within the UAN, compile an MPI application. Launch the application as interactive on compute node(s)that have not been designated, already, for either reboots (once an NCN is shut down) or that are not already running an MPI job via a uai.
* Verify that the job launched on the UAN is running and that application output is streaming to a file. Streaming output will be used to verify that the batch job is still running during resiliency testing. A batch job, when submitted, will designate a log file location. This log file can be accessed to be able to verify that the batch job is continuing to run after an NCN is brought down and once it is back online. Additionally, the `squeue` command can be used to verify that the job continues to run (for slurm).

<a name="shut-down-ncn"></a>
### Shut Down an NCN
* Establish a console session to the NCN targeted for shutdown by executing the steps in [Establish a Serial Connection to NCNs](../conman/Establish_a_Serial_Connection_to_NCNs.md).
* Log onto target node and execute `/sbin/shutdown -h 0`
   * Note in target node's console output the timestamp of the power off
   * Once the target node is reported as being powered off, verify that the node's power status with the `ipmitool` is reported as off
   ```bash
   ncn# ipmitool -I lanplus -U root -P <password> -H <ncn-node-name> chassis power status
   ```
   * Note that at times in the past, an `ipmitool` command has been used to simply yank the power to an NCN. There have been times where this resulted in a longer recovery procedure under Shasta 1.5 (mostly due to issues with getting nodes physically booted up again), so the preference has been to simply use the shutdown command.
* If the NCN shutdown is a master or worker node, within 5-6 minutes of the node being shut down, kubernetes will begin reporting "Terminating" pods on the target node and start rescheduling pods to other NCN nodes. New pending pods will be created for pods that can not be relocated off of the NCN shut down. Pods reported as "Terminating" will remain in that state until the NCN node has been powered back up.
* Take note of changes in the data being reported out of the many monitoring windows that were set-up in a previous step.

<a name="conduct-testing"></a>
### Conduct Testing
* After the target NCN was shut down, assuming the command line windows that were set-up for ensuring API responsiveness are not encountering persistent failures, the next step will be to use a bos template to boot a pre-designated set of compute nodes. The timing of this test is recommended to be around 10 minutes after the NCN has gone down. That should give ample time for kubernetes to have terminated pods on the downed node (in the case of a master or worker NCN) and for them to have been rescheduled and in a healthy state on another NCN. Going too much earlier than 10 minutes runs the risk that there are still some critical pods that are settling out to reach a healthy state.
   ```bash
   ncn# cray bos v1 session create --template-uuid boot-nids-1-4 --operation reboot
   ```
   Issuing this reboot command will spit out a boa "jobId", which can be used to find the new boa pod that has been created for the boot. And then the logs can be tailed to watch the compute boot proceed. The command `kubectl get pods -o wide -A | grep <boa-job-id>` can be used to find the boa job pod name. Then, the command `kubectl logs -n services <boa-job-pod-name> -c boa -f` can be used to watch the progress of the reboot of the compute(s). Failures or a timeout being reached in either the boot or cfs (post-boot configuration) phase will need investigation. For more information around accessing logs for the bos operations, see [Check the Progress of BOS Session Operations](../boot_orchestration/Check_the_Progress_of_BOS_Session_Operations.md).
* If the target node for shutdown was a worker NCN, verify that the uai launched on that node still exists. It should be running on another worker NCN.
   * Any prior ssh session established with the uai while it was running on the downed NCN worker node will be unresponsive. A new ssh session will need to be established once the uai pods has been successfully relocated to another worker NCN.
   * Log back into the uai and verify that the WLM (workload manager) batch job is still running and streaming output. The log file created with the kick-off of the batch job should still be accessible and the `squeue` command can be used to verify that the job continues to run (for slurm).
* If the workload manager batch job was launched on a UAN, log back into it and verify that the WLM (workload manager) batch job is still running and streaming output via the log file created with the batch job and/or the `squeue` command (if slurm is used as the WLM).
* Verify that new WLM jobs can be started on a compute node after the NCN is down (either via a uai or the UAN node). 
* Look at any pods that, are at this point, in a state other than Running, Completed, Pending, or Terminating:
   ```bash
   ncn# kubectl get pods -o wide -A | grep -Ev "Running|Completed|Pending|Termin"
   ```
   * Compare what comes up in this list to the pod list that you collected before. If there are new pods that are in status `ImagePullBackOff` or `CrashLoopBackOff`, a `kubectl describe` as well as `kubectl logs` command should be run against them to collect additional data about what happened. Obviously, if there were pods in a bad state before the procedure started, then it should not be expected that bringing one of the NCNs down is going to fix that. Ignore anything that was already in a bad state before (that was deemed to be ok). It is also worth taking note of any pods in a bad state at this stage as this should be checked again after bringing the NCN back up - to see if those pods remain in a bad state or if they are cleared. Noting behaviors, collecting logs, and opening tickets throughout this process is recommended when behavior occurs that is not expected. When we see an issue that has not been encountered before, it may not be immediately clear if code changes/regressions are at fault or if it is simply an intermittent/timing kind of issue that has not previously surfaced. The recommendation at that point, given time/resources is to repeat the test to gain a sense of the repeatability of the behavior (in the case that the issue is not directly tied to a code-change). Additionally, it is as important to understand (and document) any work-around procedures needed to fix issues encountered. In addition to filing a bug for a permanent fix, work-around documentation can be very useful when written up - for both internal and external customers to access.

<a name="power-on-ncn"></a>
### Power On the Downed NCN
* Use the ipmitool command to power up the NCN. It will take several minutes for the NCN to reboot. Progress can be monitored over the connected serial console session. Wait to begin execution of the next steps until after it can be determined that the NCN has booted up and is back at the login prompt (when viewing the serial console log).
   ```bash
   ncn# ipmitool -I lanplus -U root -P <password> -H <hostname> chassis power on   #example hostname is ncn-w003-mgmt
   ```
* If the NCN being powered on is a master or worker, verify that "Terminating" pods on that NCN clear up. It may take several minutes. Watch the command prompt, previously set-up, that is displaying the `Terminating` pod list.
* If the NCN being powered on is a storage node, wait for Ceph to recover and again report a "HEALTH_OK" status. It may take several minutes for Ceph to resolve clock skew. This can be noted in the previously set-u window to watch ceph status.
* Finally, check that pod statuses have returned to the state that they were in at the beginning of this procedure, paying particular attention to any pods that were previously noted to be in a bad state while the NCN was down. Additionally, there is no concern if pods that were in a bad state at the beginning of the procedure, are still in a bad state. What is important to note is anything that is different from either the beginning of the test or from the time that the NCN was down.

<a name="post-boot-health-check"></a>
### Execute Post-Boot Health Checks
* Re-run the `Platform Health Checks` section of [Validate CSM Health](../validate_csm_health.md) noting any output that indicates output is not as expected. Note that in a future version of CSM, these checks will be further automated for better efficiency and pass/fail clarity.
* Ensure that after a downed NCN worker node (can ignore if not a worker node) has been powered up, a new uai can be created on that NCN. It may be necessary to label the nodes again, to ensure the uai gets created on the worker node that was just powered on. Refer to the section above for `Launch a Non-Interactive Batch Job` for the procedure. Do not forget to remove the labels after the uai has been created. Once the uai has been created, log into it and ensure a new workload manager job can be launched.
* Ensure tickets have been opened for any unexpected behavior along with associated logs and notes on work-arounds, if any were executed.
