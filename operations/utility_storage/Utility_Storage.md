# Utility Storage

Utility storage is designed to support Kubernetes and the System Management Services \(SMS\) it orchestrates. Utility storage is a cost-effective solution for storing the large amounts of telemetry and log data collected.

Ceph is the utility storage platform that is used to enable pods to store persistent data. It is deployed to provide block, object, and file storage to the management services running on Kubernetes, as well as for telemetry data coming from the compute nodes.

***IMPORTANT NOTES***
>
> - When running commands for Ceph health you must run those from either ncn-m or ncn-s001/2/3.
> - Unless otherwise specified to run on the host in question, you can run the commands on either masters or ncn-s00(1/2/3)
> - Those are the only servers with the credentials.
> - The document will specify when to run a command from a node other than those

## Table of Contents

- [Cephadm Reference Material](Cephadm_Reference_Material.md)
- [Collect Information about the Ceph Cluster](Collect_Information_About_the_Ceph_Cluster.md)
- [Ceph Storage Types](Ceph_Storage_Types.md)
- [Manage Ceph Services](Manage_Ceph_Services.md)
- [Adjust Ceph Pool Quotas](Adjust_Ceph_Pool_Quotas.md)
- [Add Ceph OSDs](Add_Ceph_OSDs.md)
- [Shrink Ceph OSDs](Shrink_Ceph_OSDs.md)
- [Ceph Health States](Ceph_Health_States.md)
- [Dump Ceph Crash Data](Dump_Ceph_Crash_Data.md)
- [Identify Ceph Latency Issues](Identify_Ceph_Latency_Issues.md)
- [Restore Nexus Data After Data Corruption](Restore_Corrupt_Nexus.md)
- [Troubleshoot Failure to Get Ceph Health](Troubleshoot_Failure_to_Get_Ceph_Health.md)
- [Troubleshoot a Down OSD](Troubleshoot_a_Down_OSD.md)
- [Troubleshoot Ceph OSDs Reporting Full](Troubleshoot_Ceph_OSDs_Reporting_Full.md)
- [Troubleshoot System Clock Skew](Troubleshoot_System_Clock_Skew.md)
- [Troubleshoot an Unresponsive S3 Endpoint](Troubleshoot_an_Unresponsive_S3_Endpoint.md)
- [Troubleshoot Ceph-Mon Processes Stopping and Exceeding Max Restarts](Troubleshoot_Ceph-Mon_Processes_Stopping_and_Exceeding_Max_Restarts.md)
- [Troubleshoot Pods Failing to Restart on Other Worker Nodes](Troubleshoot_Pods_Failing_to_Restart_on_Other_Worker_Nodes.md)
- [Troubleshoot Large Object Map Objects in Ceph Health](Troubleshoot_Large_Object_Map_Objects_in_Ceph_Health.md)
- [Troubleshoot Failure of RGW Health Check](Troubleshoot_RGW_Health_Check_Fail.md)
- [Troubleshoot Ceph MDS reporting slow requests](Ceph_MDS_reporting_slow_requests_and_failure_on_client.md)
- [Ceph Service Check Script Usage](Ceph_Service_Check_Script_Usage.md)
