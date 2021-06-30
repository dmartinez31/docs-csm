# CSM Operational Activities

The Cray System Management (CSM) operational activities are administrative procedures required to operate an HPE Cray EX system with CSM software installed. 

The following administrative topics can be found in this guide:

- [CSM Operational Activities](#csm-operational-activities)
    - [CSM **TBD: topics need to be re-organized**](#csm-tbd-topics-need-to-be-re-organized)
    - [Image Management](#image-management)
    - [Boot Orchestration](#boot-orchestration)
    - [System Power Off Procedures](#system-power-off-procedures)
    - [System Power On Procedures](#system-power-on-procedures)
    - [Power Management](#power-management)
    - [Artifact Management](#artifact-management)
    - [Compute Rolling Upgrades](#compute-rolling-upgrades)
    - [Configuration Management](#configuration-management)
    - [Kubernetes](#kubernetes)
    - [Package Repository Management](#package-repository-management)
    - [Security and Authentication](#security-and-authentication)
    - [Resiliency](#resiliency)
    - [ConMan](#conman)
    - [Utility Storage](#utility-storage)
    - [System Management Health](#system-management-health)
    - [System Layout Service (SLS)](#system-layout-service-sls)
    - [System Configuration Service](#system-configuration-service)
    - [Hardware State Manager (HSM)](#hardware-state-manager-hsm)
    - [Node Management](#node-management)
    - [River Endpoint Discovery Service (REDS)](#river-endpoint-discovery-service-reds)
    - [Network](#network)
      - [Customer Access Network (CAN)](#customer-access-network-can)
      - [Dynamic Host Configuration Protocol (DHCP)](#dynamic-host-configuration-protocol-dhcp)
      - [Domain Name Service (DNS)](#domain-name-service-dns)
      - [External DNS](#external-dns)
      - [MetalLB in BGP-Mode](#metallb-in-bgp-mode)
  

### CSM **TBD: topics need to be re-organized**

   * [Lock and Unlock Nodes](lock_and_unlock_nodes.md)
   * [Validate CSM Health](validate_csm_health.md)
   * [Configure Keycloak Account](configure_keycloak_account.md)
   * [Configure the Cray Command Line Interface (cray CLI)](configure_cray_cli.md)
   * [Configure BMC and Controller Parameters with SCSD](configure_with_scsd.md)
   * [Update BGP Neighbors](update_bgp_neighbors.md)
   * [Update Firmware with FAS](update_firmware_with_fas.md)
   * [Manage Node Consoles](manage_node_consoles.md)
   * [Changing Passwords and Credentials](changing_passwords_and_credentials.md)
   * [Managing Configuration with CFS](managing_configuration_with_CFS.md)
   * [UAS/UAI Admin and User Guide](500-UAS-UAI-ADMIN-AND-USER-GUIDE.md)
   * [Accessing LiveCD USB Device After Reboot](accessing_livecd_usb_device_after_reboot.md)
   * [Update SLS with UAN Aliases](update_sls_with_uan_aliases.md)
   * [Configure NTP on NCNs](configure_ntp_on_ncns.md)
   * [Change NCN Image Root Password and SSH Keys](change_ncn_image_root_password_and_ssh_keys.md)
   * [Post-Install Customizations](Post_Install_Customizations.md)


<a name="image-management"></a>

### Image Management

Build and customize image recipes with the Image Management Service (IMS).

   * [Image Management](image_management/Image_Management.md)
   * [Image Management Workflows](image_management/Image_Management_Workflows.md)
   * [Upload and Register an Image Recipe](image_management/Upload_and_Register_an_Image_Recipe.md)
   * [Build a New UAN Image Using the Default Recipe](image_management/Build_a_New_UAN_Image_Using_the_Default_Recipe.md)
   * [Build an Image Using IMS REST Service](image_management/Build_an_Image_Using_IMS_REST_Service.md)
   * [Customize an Image Root Using IMS](image_management/Customize_an_Image_Root_Using_IMS.md)
     * [Create UAN Boot Images](image_management/Create_UAN_Boot_Images.md)
     * [Convert TGZ Archives to SquashFS Images](image_management/Convert_TGZ_Archives_to_SquashFS_Images.md)
     * [Customize an Image Root to Install Singularity](/operations/image_management/Customize_an_Image_Root_to_Install_Singularity.md)
     * [Customize an Image Root to Install Compute Kubernetes](image_management/Customize_an_Image_Root_to_Install_Compute_Kubernetes.md)
   * [Delete or Recover Deleted IMS Content](image_management/Delete_or_Recover_Deleted_IMS_Content.md)

<a name="boot-orchestration"></a>

### Boot Orchestration

Use the Boot Orchestration Service \(BOS\) to boot, configure, and shutdown collections of nodes.

   * [Boot Orchestration Service (BOS)](boot_orchestration/Boot_Orchestration.md)
   * [BOS Workflows](boot_orchestration/BOS_Workflows.md)
   * [BOS Session Templates](boot_orchestration/Session_Templates.md)
     * [Manage a Session Template](boot_orchestration/Manage_a_Session_Template.md)
     * [Create a Session Template to Boot Compute Nodes with CPS](boot_orchestration/Create_a_Session_Template_to_Boot_Compute_Nodes_with_CPS.md)
     * [Boot UANs](boot_orchestration/Boot_UANs.md)
   * [BOS Sessions](boot_orchestration/Sessions.md)
     * [Manage a BOS Session](boot_orchestration/Manage_a_BOS_Session.md)
     * [View the Status of a BOS Session](boot_orchestration/View_the_Status_of_a_BOS_Session.md)
     * [Boot Compute Nodes with a Kubernetes Customized Image](boot_orchestration/Boot_Compute_Nodes_with_a_Kubernetes_Customized_Image.md)
     * [Limit the Scope of a BOS Session](boot_orchestration/Limit_the_Scope_of_a_BOS_Session.md)
     * [Configure the BOS Timeout When Booting Compute Nodes](boot_orchestration/Configure_the_BOS_Timeout_When_Booting_Nodes.md)
     * [Check the Progress of BOS Session Operations](boot_orchestration/Check_the_Progress_of_BOS_Session_Operations.md)
     * [Clean Up Logs After a BOA Kubernetes Job](boot_orchestration/Clean_Up_Logs_After_a_BOA_Kubernetes_Job.md)
     * [Clean Up After a BOS/BOA Job is Completed or Cancelled](boot_orchestration/Clean_Up_After_a_BOS-BOA_Job_is_Completed_or_Cancelled.md)
     * [Troubleshoot UAN Boot Issues](boot_orchestration/Troubleshoot_UAN_Boot_Issues.md)
     * [Troubleshoot Compute Node Boot Issues Related to Slow Boot Times](boot_orchestration/Troubleshoot_Compute_Node_Boot_Issues_Related_to_Slow_Boot_Times.md)
     * [Troubleshoot Booting Nodes with Hardware Issues](boot_orchestration/Troubleshoot_Booting_Nodes_with_Hardware_Issues.md)
   * [BOS Limitations for Gigabyte BMC Hardware](boot_orchestration/Limitations_for_Gigabyte_BMC_Hardware.md)

<a name="system-power-off-procedures"></a>

### System Power Off Procedures

Procedures required to fully power off an HPE Cray EX system.

  * [System Power Off Procedures](power_management/System_Power_Off_Procedures.md)
  * [Prepare the System for Power Off](power_management/Prepare_the_System_for_Power_Off.md)
  * [Shut Down and Power Off Compute and User Access Nodes](power_management/Shut_Down_and_Power_Off_Compute_and_User_Access_Nodes.md)
  * [Save Management Network Switch Configuration Settings](power_management/Save_Management_Network_Switch_Configurations.md)
  * [Power Off Compute and IO Cabinets](power_management/Power_Off_Compute_and_IO_Cabinets.md)
  * [Shut Down and Power Off the Management Kubernetes Cluster](power_management/Shut_Down_and_Power_Off_the_Management_Kubernetes_Cluster.md)
  * [Power Off the External Lustre File System](power_management/Power_Off_the_External_Lustre_File_System.md)


<a name="system-power-on-procedures"></a>

### System Power On Procedures

Procedures required to fully power on an HPE Cray EX system.

  * [System Power On Procedures](power_management/System_Power_On_Procedures.md)
  * [Power On and Start the Management Kubernetes Cluster](power_management/Power_On_and_Start_the_Management_Kubernetes_Cluster.md)
  * [Power On the External Lustre File System](power_management/Power_On_the_External_Lustre_File_System.md)
  * [Power On Compute and IO Cabinets](power_management/Power_On_Compute_and_IO_Cabinets.md)
  * [Bring Up the Slingshot Fabric](power_management/Bring_up_the_Slingshot_Fabric.md)
  * [Power On and Boot Compute and User Access Nodes](power_management/Power_On_and_Boot_Compute_Nodes_and_User_Access_Nodes.md)
  * [Recover from a Liquid Cooled Cabinet EPO Event](power_management/Recover_from_a_Liquid_Cooled_Cabinet_EPO_Event.md)

<a name="power-management"></a>

### Power Management

HPE Cray System Management (CSM) software manages and controls power out-of-band through Redfish APIs.

  * [Power Management](power_management/power_management.md)
  * [Cray Advanced Platform Monitoring and Control (CAPMC)](power_management/Cray_Advanced_Platform_Monitoring_and_Control_CAPMC.md)
  * [Liquid Cooled Node Power Management](power_management/Liquid_Cooled_Node_Card_Power_Management.md)
    * [User Access to Compute Node Power Data](power_management/User_Access_to_Compute_Node_Power_Data.md)
  * [Standard Rack Node Power Management](power_management/Standard_Rack_Node_Power_Management.md)
  * [Ignore Nodes with CAPMC](power_management/Ignore_Nodes_with_CAPMC.md)
  * [Set the Turbo Boost Limit](power_management/Set_the_Turbo_Boost_Limit.md)


<a name="artifact-Management"></a>

### Artifact Management

Use the Ceph Object Gateway Simple Storage Service \(S3\) API to manage artifacts on the system.

   * [Artifact Management](artifact_management/Artifact_Management.md)
   * [Manage Artifacts with the Cray CLI](artifact_management/Manage_Artifacts_with_the_Cray_CLI.md)
   * [Use S3 Libraries and Clients](artifact_management/Use_S3_Libraries_and_Clients.md)
   * [Generate Temporary S3 Credentials](artifact_management/Generate_Temporary_S3_Credentials.md)

<a name="compute-rolling-upgrades"></a>

### Compute Rolling Upgrades

Upgrade sets of compute nodes with the Compute Rolling Upgrade Service \(CRUS\) without requiring an entire set of nodes to be out of service at once. CRUS enables administrators to limit the impact on production caused from upgrading compute nodes by working through one step of the upgrade process at a time.

   * [Compute Rolling Upgrade Service (CRUS)](compute_rolling_upgrade/Compute_Rolling_Upgrade_Service_CRUS.md)
   * [CRUS Workflow](compute_rolling_upgrade/CRUS_Workflow.md)
   * [Upgrade Compute Nodes with CRUS](compute_rolling_upgrade/Upgrade_Compute_Nodes_with_CRUS.md)
   * [Troubleshoot Nodes Failing to UPgrade in a CRUS Session](compute_rolling_upgrade/Troubleshoot_Nodes_Failing_to_Upgrade_in_a_CRUS_Session.md)
   * [Troubleshoot a Failed CRUS Session Due to Unmet Conditions](compute_rolling_upgrade/Troubleshoot_a_Failed_CRUS_Session_Due_to_Unmet_Conditions.md)
   * [Troubleshoot a Failed CRUS Session Due to Bad Parameters](compute_rolling_upgrade/Troubleshoot_a_Failed_CRUS_Session_Due_to_Bad_Parameters.md)

<a name="configuration-management"></a>

### Configuration Management

The Configuration Framework Service \(CFS\) is available on systems for remote execution and configuration management of nodes and boot images.

   *   [Configuration Management](configuration_management/Configuration_Management.md)
   *   [Configuration Layers](configuration_management/Configuration_Layers.md)
       *   [Create a CFS Configuration](configuration_management/Create_a_CFS_Configuration.md)
       *   [Update a CFS Configuration](configuration_management/Update_a_CFS_Configuration.md)
   *   [Ansible Inventory](configuration_management/Ansible_Inventory.md)
       *   [Manage Multiple Inventories in a Single Location](configuration_management/Manage_Multiple_Inventories_in_a_Single_Location.md)
   *   [Configuration Sessions](configuration_management/Configuration_Sessions.md)
       *   [Create a CFS Session with Dynamic Inventory](configuration_management/Create_a_CFS_Session_with_Dynamic_Inventory.md)
       *   [Create an Image Customization CFS Session](configuration_management/Create_an_Image_Customization_CFS_Session.md)
       *   [Set Limits for a Configuration Session](configuration_management/Set_Limits_for_a_Configuration_Session.md)
       *   [Change the Ansible Verbosity Logs](configuration_management/Change_the_Ansible_Verbosity_Logs.md)
       *   [Set the ansible.cfg for a Session](configuration_management/Set_the_ansible-cfg_for_a_Session.md)
       *   [Delete CFS Sessions](configuration_management/Delete_CFS_Sessions.md)
       *   [Automatic Session Deletion with sessionTTL](configuration_management/Automaitc_Session_Deletion_with_sessionTTL.md)
       *   [Track the Status of a Session](configuration_management/Track_the_Status_of_a_Session.md)
       *   [View Configuration Session Logs](configuration_management/View_Configuration_Session_Logs.md)
       *   [Troubleshoot Ansible Play Failures in CFS Sessions](configuration_management/Troubleshoot_Ansible_Play_Failures_in_CFS_Sessions.md)
       *   [Troubleshoot CFS Session Failing to Complete](configuration_management/Troubleshoot_CFS_Session_Failing_to_Complete.md)
   *   [Configuration Management with the CFS Batcher](configuration_management/Configuration_Management_with_the_CFS_Batcher.md)
   *   [Configuration Management of System Components](configuration_management/Configuration_Management_of_System_Components.md)
   *   [Ansible Execution Environments](configuration_management/Ansible_Execution_Environments.md)
       *   [Use a Custom ansible-cfg File](configuration_management/Use_a_Custom_ansible-cfg_File.md)
       *   [Enable Ansible Profiling](configuration_management/Enable_Ansible_Profiling.md)
   *   [CFS Global Options](configuration_management/CFS_Global_Options.md)
   *   [Version Control Service \(VCS\)](configuration_management/Version_Control_Service_VCS.md)
       *   [Git Operations](configuration_management/Git_Operations.md)
       *   [VCS Branching Strategy](configuration_management/VCS_Branching_Strategy.md)
       *   [Customize Configuration Values](configuration_management/Customize_Configuration_Values.md)
       *   [Update the Privacy Settings for Gitea Configuration Content Repositories](configuration_management/Update_the_Privacy_Settings_for_Gitea_Configuration_Content_Repositories.md)
       *   [Create and Populate a VCS Configuration Repository](configuration_management/Create_and_Populate_a_VCS_Configuration_Repository.md)
   *   [Write Ansible Code for CFS](configuration_management/Write_Ansible_Code_for_CFS.md)
       *   [Target Ansible Tasks for Image Customization](configuration_management/Target_Ansible_Tasks_for_Image_Customization.md)
   *   [Ansible Inventory](configuration_management/Ansible_Inventory.md)
       *   [Manage Multiple Inventories in a Single Location](configuration_management/Manage_Multiple_Inventories_in_a_Single_Location.md)
   *   [Configuration Sessions](configuration_management/Configuration_Sessions.md)
       *   [Create a CFS Session with Dynamic Inventory](configuration_management/Create_a_CFS_Session_with_Dynamic_Inventory.md)
       *   [Create an Image Customization CFS Session](configuration_management/Create_an_Image_Customization_CFS_Session.md)
       *   [Set Limits for a Configuration Session](configuration_management/Set_Limits_for_a_Configuration_Session.md)
       *   [Change the Ansible Verbosity Logs](configuration_management/Change_the_Ansible_Verbosity_Logs.md)
       *   [Set the ansible.cfg for a Session](configuration_management/Set_the_ansible-cfg_for_a_Session.md)
       *   [Delete CFS Sessions](configuration_management/Delete_CFS_Sessions.md)
       *   [Automatic Session Deletion with sessionTTL](configuration_management/Automaitc_Session_Deletion_with_sessionTTL.md)
       *   [Track the Status of a Session](configuration_management/Track_the_Status_of_a_Session.md)
       *   [View Configuration Session Logs](configuration_management/View_Configuration_Session_Logs.md)
       *   [Troubleshoot Ansible Play Failures in CFS Sessions](configuration_management/Troubleshoot_Ansible_Play_Failures_in_CFS_Sessions.md)
       *   [Troubleshoot CFS Session Failing to Complete](configuration_management/Troubleshoot_CFS_Session_Failing_to_Complete.md)
   *   [Configuration Management with the CFS Batcher](configuration_management/Configuration_Management_with_the_CFS_Batcher.md)
   *   [Configuration Management of System Components](configuration_management/Configuration_Management_of_System_Components.md)
   *   [Ansible Execution Environments](configuration_management/Ansible_Execution_Environments.md)
       *   [Use a Custom ansible-cfg File](configuration_management/Use_a_Custom_ansible-cfg_File.md)
       *   [Enable Ansible Profiling](configuration_management/Enable_Ansible_Profiling.md)
   *   [CFS Global Options](configuration_management/CFS_Global_Options.md)
   *   [Version Control Service \(VCS\)](configuration_management/Version_Control_Service_VCS.md)
       *   [Git Operations](configuration_management/Git_Operations.md)
       *   [VCS Branching Strategy](configuration_management/VCS_Branching_Strategy.md)
       *   [Customize Configuration Values](configuration_management/Customize_Configuration_Values.md)
       *   [Update the Privacy Settings for Gitea Configuration Content Repositories](configuration_management/Update_the_Privacy_Settings_for_Gitea_Configuration_Content_Repositories.md)
       *   [Create and Populate a VCS Configuration Repository](configuration_management/Create_and_Populate_a_VCS_Configuration_Repository.md)
   *   [Write Ansible Code for CFS](configuration_management/Write_Ansible_Code_for_CFS.md)
      *   [Target Ansible Tasks for Image Customization](configuration_management/Target_Ansible_Tasks_for_Image_Customization.md)


<a name="kubernetes"></a>

### Kubernetes

The system management components are broken down into a series of microservices. Each service is independently deployable, fine-grained, and uses lightweight protocols. As a result, the system's microservices are modular, resilient, and can be updated independently. Services within the Kubernetes architecture communicate via REST APIs.

   *   [Kubernetes Architecture](kubernetes/Kubernetes_Architecture.md)
   *   [About kubectl](kubernetes/About_kubectl.md)
       *   [Configure kubectl Credentials to Access the Kubernetes APIs](kubernetes/Configure_kubectl_Credentials_to_Access_the_Kubernetes_APIs.md)
   *   [About Kubernetes Taints and Labels](kubernetes/About_Kubernetes_Taints_and_Labels.md)
   *   [Kubernetes Storage](kubernetes/Kubernetes_Storage.md)
   *   [Kubernetes Networking](kubernetes/Kubernetes_Networking.md)
   *   [Retrieve Cluster Health Information Using Kubernetes](kubernetes/Retrieve_Cluster_Health_Information_Using_Kubernetes.md)
   *   [Pod Resource Limits](kubernetes/Pod_Resource_Limits.md)
       *   [Determine if Pods are Hitting Resource Limits](kubernetes/Determine_if_Pods_are_Hitting_Resource_Limits.md)
       *   [Increase Pod Resource Limits](kubernetes/Increase_Pod_Resource_Limits.md)
       *   [Increase Kafka Pod Resource Limits](kubernetes/Increase_Kafka_Pod_Resource_Limits.md)
   *   [About etcd](kubernetes/About_etcd.md)
       *   [Check the Health and Balance of etcd Clusters](kubernetes/Check_the_Health_and_Balance_of_etcd_Clusters.md)
       *   [Rebuild Unhealthy etcd Clusters](kubernetes/Rebuild_Unhealthy_etcd_Clusters.md)
       *   [Backups for etcd-operator Clusters](kubernetes/Backups_for_etcd-operator_Clusters.md)
       *   [Create a Manual Backup of a Healthy etcd Cluster](kubernetes/Create_a_Manual_Backup_of_a_Healthy_etcd_Cluster.md)
       *   [Restore an etcd Cluster from a Backup](kubernetes/Restore_an_etcd_Cluster_from_a_Backup.md)
       *   [Repopulate Data in etcd Clusters When Rebuilding Them](kubernetes/Repopulate_Data_in_etcd_Clusters_When_Rebuilding_Them.md)
       *   [Restore Bare-Metal etcd Clusters from an S3 Snapshot](kubernetes/Restore_Bare-Metal_etcd_Clusters_from_an_S3_Snapshot.md)
       *   [Rebalance Healthy etcd Clusters](kubernetes/Rebalance_Healthy_etcd_Clusters.md)
       *   [Check for and Clear etcd Cluster Alarms](kubernetes/Check_for_and_Clear_etcd_Cluster_Alarms.md)
       *   [Report the Endpoint Status for etcd Clusters](kubernetes/Report_the_Endpoint_Status_for_etcd_Clusters.md)
       *   [Clear Space in an etcd Cluster Database](kubernetes/Clear_Space_in_an_etcd_Cluster_Database.md)
   *   [About Postgres](kubernetes/About_Postgres.md)
       *   [Troubleshoot Postgres Databases with the Patroni Tool](kubernetes/Troubleshoot_Postgres_Databases_with_the_Patroni_Tool.md)
       *   [View Postgres Information for System Databases](kubernetes/View_Postgres_Information_for_System_Databases.md)
   *   [Configure Kubernetes on Compute Nodes](kubernetes/Configure_Kubernetes_on_Compute_Nodes.md)
   *   [Kubernetes Troubleshooting Information](kubernetes/Kubernetes_Troubleshooting_Information.md)
       *   [Kubernetes Log File Locations](kubernetes/Kubernetes_Log_File_Locations.md)
       *   [Troubleshoot Liveliness or Readiness Probe Failures](kubernetes/Troubleshoot_Liveliness_Readiness_Probe_Failures.md)
       *   [Troubleshoot Unresponsive kubectl Commands](kubernetes/Troubleshoot_Unresponsive_kubectl_Commands.md)
       *   [Determine if Pods are Hitting Resource Limits](kubernetes/Determine_if_Pods_are_Hitting_Resource_Limits.md)
       *   [Increase Pod Resource Limits](kubernetes/Increase_Pod_Resource_Limits.md)
       *   [Increase Kafka Pod Resource Limits](kubernetes/Increase_Kafka_Pod_Resource_Limits.md)
   *   [About etcd](kubernetes/About_etcd.md)
       *   [Check the Health and Balance of etcd Clusters](kubernetes/Check_the_Health_and_Balance_of_etcd_Clusters.md)
       *   [Rebuild Unhealthy etcd Clusters](kubernetes/Rebuild_Unhealthy_etcd_Clusters.md)
       *   [Backups for etcd-operator Clusters](kubernetes/Backups_for_etcd-operator_Clusters.md)
       *   [Create a Manual Backup of a Healthy etcd Cluster](kubernetes/Create_a_Manual_Backup_of_a_Healthy_etcd_Cluster.md)
       *   [Restore an etcd Cluster from a Backup](kubernetes/Restore_an_etcd_Cluster_from_a_Backup.md)
       *   [Repopulate Data in etcd Clusters When Rebuilding Them](kubernetes/Repopulate_Data_in_etcd_Clusters_When_Rebuilding_Them.md)
       *   [Restore Bare-Metal etcd Clusters from an S3 Snapshot](kubernetes/Restore_Bare-Metal_etcd_Clusters_from_an_S3_Snapshot.md)
       *   [Rebalance Healthy etcd Clusters](kubernetes/Rebalance_Healthy_etcd_Clusters.md)
       *   [Check for and Clear etcd Cluster Alarms](kubernetes/Check_for_and_Clear_etcd_Cluster_Alarms.md)
       *   [Report the Endpoint Status for etcd Clusters](kubernetes/Report_the_Endpoint_Status_for_etcd_Clusters.md)
       *   [Clear Space in an etcd Cluster Database](kubernetes/Clear_Space_in_an_etcd_Cluster_Database.md)
   *   [About Postgres](kubernetes/About_Postgres.md)
       *   [Troubleshoot Postgres Databases with the Patroni Tool](kubernetes/Troubleshoot_Postgres_Databases_with_the_Patroni_Tool.md)
       *   [View Postgres Information for System Databases](kubernetes/View_Postgres_Information_for_System_Databases.md)
   *   [Configure Kubernetes on Compute Nodes](kubernetes/Configure_Kubernetes_on_Compute_Nodes.md)
   *   [Kubernetes Troubleshooting Information](kubernetes/Kubernetes_Troubleshooting_Information.md)
      *   [Kubernetes Log File Locations](kubernetes/Kubernetes_Log_File_Locations.md)
      *   [Troubleshoot Liveliness or Readiness Probe Failures](kubernetes/Troubleshoot_Liveliness_Readiness_Probe_Failures.md)
      *   [Troubleshoot Unresponsive kubectl Commands](kubernetes/Troubleshoot_Unresponsive_kubectl_Commands.md)


<a name="package-repository-management"></a>

### Package Repository Management

Repositories are added to  systems to extend the system functionality beyond what is initially delivered. The Sonatype Nexus Repository Manager is the primary method for repository management. Nexus hosts the Yum, Docker, raw, and Helm repositories for software and firmware content.

   * [Package Repository Management](package_repository_management/Package_Repository_Management.md)
   * [Package Repository Management with Nexus](package_repository_management/Package_Repository_Management_with_Nexus.md)
   * [Manage Repositories with Nexus](package_repository_management/Manage_Repositories_with_Nexus.md)
   * [Nexus Configuration](package_repository_management/Nexus_Configuration.md)
   * [Nexus Deployment](package_repository_management/Nexus_Deployment.md)
   * [Restrict Admin Privileges in Nexus](package_repository_management/Restrict_Admin_Privileges_in_Nexus.md)
   * [Repair Yum Repository Metadata](package_repository_management/Repair_Yum_Repository_Metadata.md)


<a name="security-and-authentication"></a>

### Security and Authentication

Mechanisms used by the system to ensure the security and authentication of internal and external requests.

   *   [System Security and Authentication](security_and_authentication/System_Security_and_Authentication.md)
   *   [Manage System Passwords](security_and_authentication/Manage_System_Passwords.md)
      *   [Update NCN Passwords](security_and_authentication/Update_NCN_Passwords.md)
      *   [Change Root Passwords for Compute Nodes](security_and_authentication/Change_Root_Passwords_for_Compute_Nodes.md)
       *   [Update NCN Passwords](security_and_authentication/Update_NCN_Passwords.md)
       *   [Change Root Passwords for Compute Nodes](security_and_authentication/Change_Root_Passwords_for_Compute_Nodes.md)
   *   [Retrieve an Authentication Token](security_and_authentication/Retrieve_an_Authentication_Token.md)
   *   [SSH Keys](security_and_authentication/SSH_Keys.md)
   *   [Authenticate an Account with the Command Line](security_and_authentication/Authenticate_an_Account_with_the_Command_Line.md)
   *   [Default Keycloak Realms, Accounts and Clients](security_and_authentication/Default_Keycloak_Realsm_Accounts_and_Clients.md)
       *   [Certificate Types](security_and_authentication/Certificate_Types.md)
       *   [Change the Keycloak Admin Password](security_and_authentication/Change_the_Keycloak_Admin_Password.md)
       *   [Create a Service Account in Keycloak](security_and_authentication/Create_a_Service_Account_in_Keycloak.md)
       *   [Retrieve the Client Secret for Service Accounts](security_and_authentication/Retrieve_the_Client_Secret_for_Service_Accounts.md)
       *   [Get a Long-Lived Token for a Service Account](security_and_authentication/Get_a_Long-lived_Token_for_a_Service_Account.md)
       *   [Access the Keycloak User Management UI](security_and_authentication/Access_the_Keycloak_User_Managment_UI.md)
       *   [Create Internal User Accounts in the Keycloak Shasta Realm](security_and_authentication/Create_Internal_User_Accounts_in_the_Keycloak_Shasta_Realm.md)
       *   [Delete Internal User Accounts in the Keycloak Shasta Realm](security_and_authentication/Delete_Internal_User_Accounts_from_the_Keycloak_Shasta_Realm.md)
       *   [Create Internal User Groups in the Keycloak Shasta Realm](security_and_authentication/Create_Internal_User_Accounts_in_the_Keycloak_Shasta_Realm.md)
       *   [Remove Internal Groups from the Keycloak Shasta Realm](security_and_authentication/Remove_Internal_Groups_from_the_Keycloak_Shasta_Realm.md)
       *   [Remove the Email Mapper from the LDAP User Federation](security_and_authentication/Remove_the_Email_Mapper_from_the_LDAP_User_Federation.md)
       *   [Re-Sync Keycloak Users to Compute Nodes](security_and_authentication/Resync_Keycloak_Users_to_Compute_Nodes.md)
       *   [Keycloak Operations](security_and_authentication/Keycloak_Operations.md)
       *   [Configure Keycloak for LDAP/AD authentication](security_and_authentication/Configure_Keycloak_for_LDAPAD_Authentication.md)
       *   [Configure the RSA Plugin in Keycloak](security_and_authentication/Configure_the_RSA_Plugin_in_Keycloak.md)
       *   [Preserve Username Capitalization for Users Exported from Keycloak](security_and_authentication/Preserve_Username_Capitalization_for_Users_Exported_from_Keycloak.md)
       *   [Change the LDAP Server IP for Existing LDAP Server Content](security_and_authentication/Change_the_LDAP_Server_IP_for_Existing_LDAP_Server_Content.md)
       *   [Change the LDAP Server IP for New LDAP Server Content](security_and_authentication/Change_the_LDAP_Server_IP_for_New_LDAP_Server_Content.md)
       *   [Remove the LDAP User Federation from Keycloak](security_and_authentication/Remove_the_LDAP_User_Federation_from_Keycloak.md)
       *   [Add LDAP User Federation](security_and_authentication/Add_LDAP_User_Federation.md)
   *   [Public Key Infrastructure \(PKI\)](security_and_authentication/Public_Key_Infrastructure_PKI.md)
       *   [PKI Certificate Authority \(CA\)](security_and_authentication/PKI_Certificate_Authority_CA.md)
       *   [Make HTTPS Requests from Sources Outside the Management Kubernetes Cluster](security_and_authentication/Make_HTTPS_Requests_from_Sources_Outside_the_Management_Kubernetes_Cluster.md)
       *   [Transport Layer Security \(TLS\) for Ingress Services](security_and_authentication/Transport_Layer_Security_for_Ingress_Services.md)
       *   [PKI Services](security_and_authentication/PKI_Services.md)
       *   [HashiCorp Vault](security_and_authentication/HashiCorp_Vault.md)
       *   [Backup and Restore Vault Clusters](security_and_authentication/Backup_and_Restore_Vault_Clusters.md)
       *   [Troubleshoot Common Vault Cluster Issues](security_and_authentication/Troubleshoot_Common_Vault_Cluster_Issues.md)
   *   [Public Key Infrastructure \(PKI\)](security_and_authentication/Public_Key_Infrastructure_PKI.md)
       *   [PKI Certificate Authority \(CA\)](security_and_authentication/PKI_Certificate_Authority_CA.md)
       *   [Make HTTPS Requests from Sources Outside the Management Kubernetes Cluster](security_and_authentication/Make_HTTPS_Requests_from_Sources_Outside_the_Management_Kubernetes_Cluster.md)
       *   [Transport Layer Security \(TLS\) for Ingress Services](security_and_authentication/Transport_Layer_Security_for_Ingress_Services.md)
       *   [PKI Services](security_and_authentication/PKI_Services.md)
       *   [HashiCorp Vault](security_and_authentication/HashiCorp_Vault.md)
       *   [Backup and Restore Vault Clusters](security_and_authentication/Backup_and_Restore_Vault_Clusters.md)
       *   [Troubleshoot Common Vault Cluster Issues](security_and_authentication/Troubleshoot_Common_Vault_Cluster_Issues.md)
   *   [Troubleshoot SPIRE Failing to Start on NCNs](security_and_authentication/Troubleshoot_SPIRE_Failing_to_Start_on_NCNs.md)
   *   [API Authorization](security_and_authentication/API_Authorization.md)


<a name="resiliency"></a>

### Resiliency

HPE Cray EX systems are designed so that system management services \(SMS\) are fully resilient and that there is no single point of failure.

   * [Resiliency](resiliency/Resiliency.md)
   * [Resilience of System Management Services](resiliency/Resilience_of_System_Management_Services.md)
   * [Restore System Functionality if a Kubernetes Worker Node is Down](resiliency/Restore_System_Functionality_if_a_Kubernetes%20Worker_Node_is_Down.md)
   * [Recreate StatefulSet Pods on Another Node](resiliency/Recreate_StatefulSet_Pods_on_Another_Node.md)
   * [NTP Resiliency](resiliency/NTP_Resiliency.md)


<a name="conman"></a>

### ConMan

ConMan is a tool used for connecting to remote consoles and collecting console logs. These node logs can then be used for various administrative purposes, such as troubleshooting node boot issues.

  * [Access Compute Node Logs](conman/Access_Compute_Node_Logs.md)
  * [Access Console Log Data Via the System Monitoring Framework \(SMF\)](conman/Access_Console_Log_Data_Via_the_System_Monitoring_Framework_SMF.md)
  * [Log in to a Node Using ConMan](conman/Log_in_to_a_Node_Using_ConMan.md)
  * [Establish a Serial Connection to NCNs](conman/Establish_a_Serial_Connection_to_NCNs.md)
  * [Disable ConMan After System Software Installation](conman/Disable_ConMan_After_System_Software_Installation.md)
  * [Troubleshoot ConMan Blocking Access to a Node BMC](conman/Troubleshoot_ConMan_Blocking_Access_to_a_Node_BMC.md)
  * [Troubleshoot ConMan Failing to Connect to a Console](conman/Troubleshoot_ConMan_Failing_to_Connect_to_a_Console.md)
  * [Troubleshoot ConMan Asking for Password on SSH Connection](conman/Troubleshoot_ConMan_Asking_for_Password_on_SSH_Connection.md)


<a name="utility-storage"></a>

### Utility Storage

Ceph is the utility storage platform that is used to enable pods to store persistent data. It is deployed to provide block, object, and file storage to the management services running on Kubernetes, as well as for telemetry data coming from the compute nodes.

  * [Utility Storage](utility_storage/Utility_Storage.md)
  * [Collect Information about the Ceph Cluster](utility_storage/Collect_Information_About_the_Ceph_Cluster.md)  
  * [Ceph Services](utility_storage/Ceph_Services.md)  
  * [Manage Ceph Services](utility_storage/Manage_Ceph_Services.md)  
  * [Restart Ceph Services via Ansible](utility_storage/Restart_Ceph_Services_via_Ansible.md)  
  * [Adjust Ceph Pool Quotas](utility_storage/Adjust_Ceph_Pool_Quotas.md)  
  * [Add Ceph OSDs](utility_storage/Add_Ceph_OSDs.md)  
  * [Shrink Ceph OSDs](utility_storage/Shrink_Ceph_OSDs.md)  
  * [Ceph Health States](utility_storage/Ceph_Health_States.md)  
  * [Dump Ceph Crash Data](utility_storage/Dump_Ceph_Crash_Data.md)  
  * [Identify Ceph Latency Issues](utility_storage/Identify_Ceph_Latency_Issues.md)  
  * [Troubleshoot Failure to Get Ceph Health](utility_storage/Troubleshoot_Failure_to_Get_Ceph_Health.md)  
  * [Troubleshoot a Down OSD](utility_storage/Troubleshoot_a_Down_OSD.md)  
  * [Troubleshoot Ceph OSDs Reporting Full](utility_storage/Troubleshoot_Ceph_OSDs_Reporting_Full.md)  
  * [Troubleshoot System Clock Skew](utility_storage/Troubleshoot_System_Clock_Skew.md)  
  * [Troubleshoot an Unresponsive S3 Endpoint](utility_storage/Troubleshoot_an_Unresponsive_S3_Endpoint.md)  
  * [Troubleshoot Ceph-Mon Processes Stopping and Exceeding Max Restarts](utility_storage/Troubleshoot_Ceph-Mon_Processes_Stopping_and_Exceeding_Max_Restarts.md)  
  * [Troubleshoot Pods Failing to Restart on Other Worker Nodes](utility_storage/Troubleshoot_Pods_Failing_to_Restart_on_Other_Worker_Nodes.md)  
  * [Troubleshoot Large Object Map Objects in Ceph Health](utility_storage/Troubleshoot_Large_Object_Map_Objects_in_Ceph_Health.md)  


<a name="system-management-health"></a>

### System Management Health

Enable system administrators to assess the health of their system. Operators need to quickly and efficiently troubleshoot system issues as they occur and be confident that a lack of issues indicates the system is operating normally.

  * [System Management Health](system_management_health/System_Management_Health.md)
  * [System Management Health Checks and Alerts](system_management_health/System_Management_Health_Checks_and_Alerts.md)
  * [Access System Management Health Services](system_management_health/Access_System_Management_Health_Services.md)
  * [Configure Prometheus Email Alert Notifications](system_management_health/Configure_Prometheus_Email_Alert_Notifications.md)


<a name="system-layout-service-sls"></a>

### System Layout Service (SLS)

The System Layout Service \(SLS\) holds information about the system design, such as the physical locations of network hardware, compute nodes, and cabinets. It also stores information about the network, such as which port on which switch should be connected to each compute node.

  * [System Layout Service (SLS)](system_layout_service/System_Layout_Service_SLS.md)
  * [Dump SLS Information](system_layout_service/Dump_SLS_Information.md)
  * [Load SLS Database with Dump File](system_layout_service/Load_SLS_Database_with_Dump_File.md)
  * [Add UAN CAN IP Addresses to SLS](system_layout_service/Add_UAN_CAN_IP_Addresses_to_SLS.md)


<a name="system-configuration-service"></a>

### System Configuration Service

The System Configuration Service \(SCSD\) allows admins to set various BMC and controller parameters. These parameters are typically set during discovery, but this tool enables parameters to be set before or after discovery. The operations to change these parameters are available in the Cray CLI under the `scsd` command.

  * [System Configuration Service](system_configuration_service/System_Configuration_Service.md)
  * [Manage Parameteres with the scsd Service](system_configuration_service/Manage_Parameters_with_the_scsd_Service.md)
  * [Set BMC Credentials](system_configuration_service/Set_BMC_Credentials.md)


<a name="hardware-state-manager-hsm"></a>

### Hardware State Manager (HSM)

Use the Hardware State Manager \(HSM\) to monitor and interrogate hardware components in the HPE Cray EX system, tracking hardware state and inventory information, and making it available via REST queries and message bus events when changes occur.

  * [Hardware State Manager (HSM)](hardware_state_manager/Hardware_State_Manager.md)
  * [Hardware Management Services (HMS) Locking API](hardware_state_manager/Hardware_Management_Services_HMS_Locking_API.md)
    * [NCN and Management Node Locking](hardware_state_manager/NCN_and_Management_Node_Locking.md)
    * [Manage HMS Locks](hardware_state_manager/Manage_HMS_Locks.md)
  * [Component Groups and Partitions](hardware_state_manager/Component_Groups_and_Partitions.md)
    * [Manage Component Groups](hardware_state_manager/Manage_Component_Groups.md)
    * [Component Group Members](hardware_state_manager/Component_Group_Members.md)
    * [Manage Component Partitions](hardware_state_manager/Manage_Component_Partitions.md)
    * [Component Partition Members](hardware_state_manager/Component_Partition_Members.md)
    * [Component Memberships](hardware_state_manager/Component_Memberships.md)
  * [Hardware State Manager (HSM) State and Flag Fields](hardware_state_manager/Hardware_State_Manager_HSM_State_and_Flag_Fields.md)
  * [Add a NCN into the HSM Database](hardware_state_manager/Add_a_NCN_into_HSM_Database.md)
  * [Add a Switch to the HSM Database](hardware_state_manager/Add_a_Switch_to_the_HSM_Database.md)
  * [Manage NodeMaps with HSM](hardware_state_manager/Manage_NodeMaps_with_HSM.md)


<a name="node_management"></a>

### Node Management

Monitor and manage compute nodes (CNs) and non-compute nodes (NCNs) used in the HPE Cray EX system.

  * [Node Management](node_management/Node_Management.md)
  * [Node Management Workflows](node_management/Node_Management_Workflows.md)
  * [Rebuild NCNs](node_management/Rebuild_NCNs.md)
  * [Reboot NCNs](node_management/Reboot_NCNs.md)
    * [Check and Set the metalno-wipe Setting on NCNs](node_management/Check_and_Set_the_metalno-wipe_Setting_on_NCNs.md)
  * [Enable Nodes](node_management/Enable_Nodes.md)
  * [Disable Nodes](node_management/Disable_Nodes.md)
  * [Find Node Type and Manufacturer](node_management/Find_Node_Type_and_Manufacturer.md)
  * [Add a Standard Rack Node](node_management/Add_a_Standard_Rack_Node.md)
    * [Move a Standard Rack Node](node_management/Move_a_Standard_Rack_Node.md)
    * [Move a Standard Rack Node (Same Rack/Same HSN Ports)](node_management/Move_a_Standard_Rack_Node_SameRack_SameHSNPorts.md)
  * [Clear Space in Root File System on Worker Nodes](node_management/Clear_Space_in_Root_File_System_on_Worker_Nodes.md)
  * [Manually Wipe Boot Configuration on Nodes to be Reinstalled](node_management/Manually_Wipe_Boot_Configuration_on_Nodes_to_be_Reinstalled.md)
  * [Troubleshoot Issues with Redfish Endpoint DiscoveryCheck for Redfish Events from Nodes](node_management/Troubleshoot_Issues_with_Redfish_Endpoint_Discovery.md)
  * [Reset Credentials on Redfish Devices](node_management/Reset_Credentials_on_Redfish_Devices_for_Reinstallation.md)
  * [Access and Update Settings for Replacement NCNs](node_management/Access_and_Update_the_Settings_for_Replacement_NCNs_.md)
  * [Change Settings for HMS Collector Polling of Air Cooled Nodes](node_management/Change_Settings_for_HMS_Collector_Polling_of_Air_Cooled_Nodes.md)
  * [Use the Physical KVM](node_management/Use_the_Physical_KVM.md)
  * [Launch a Virtual KVM on Gigabyte Servers](node_management/Launch_a_Virtual_KVM_on_Gigabyte_Servers.md)
  * [Launch a Virtual KVM on Intel Servers](node_management/Launch_a_Virtual_KVM_on_Intel_Servers.md)
  * [Change Java Security Settings](node_management/Change_Java_Security_Settings.md)
  * [Verify Accuracy of the System Clock](node_management/Verify_Accuracy_of_the_System_Clock.md)
  * [Configuration of NCN Bonding](node_management/Configuration_of_NCN_Bonding.md)
    * [Change Interfaces in the Bond](node_management/Change_Interfaces_in_the_Bond.md)
    * [Troubleshoot Interfaces with IP Address Issues](node_management/Troubleshoot_Interfaces_with_IP_Address_Issues.md)
  * [Troubleshoot Loss of Console Connections and Logs on Gigabyte Nodes](node_management/Troubleshoot_Loss_of_Console_Connections_and_Logs_on_Gigabyte_Nodes.md)
  * [Check the BMC Failover Mode](node_management/Check_the_BMC_Failover_Mode.md)
  * [Update Compute Node Mellanox HSN NIC Firmware](node_management/Update_Compute_Node_Mellanox_HSN_NIC_Firmware.md)
  * [TLS Certificates for Redfish BMCs](node_management/TLS_Certificates_for_Redfish_BMCs.md)
    * [Add TLS Certificates to BMCs](node_management/Add_TLS_Certificates_to_BMCs.md)
  * [Run a Manual ckdump on Compute Nodes](node_management/Run_a_Manual_ckdump_on_Compute_Nodes.md)
  * [Dump a Compute Node with Node Memory Dump (NMD)](node_management/Dump_a_Compute_Node_with_Node_Memory_Dump_nmd.md)
  * [Dump a Non-Compute Node](node_management/Dump_a_Non-Compute_Node.md)
  * [Enable Passwordless Connections to Liquid Cooled Node BMCs](node_management/Enable_Passwordless_Connections_to_Liquid_Cooled_Node_BMCs.md)
    * [View BIOS Logs for Liquid Cooled Nodes](node_management/View_BIOS_Logs_for_Liquid_Cooled_Nodes.md)
  * [Enable Nvidia GPU Support](node_management/Enable_Nvidia_GPU_Support.md)
    * [Update Nvidia GPU Software without Rebooting](node_management/Update_Nvidia_GPU_Software_without_Rebooting.md)


<a name="reds"></a>

### River Endpoint Discovery Service (REDS)

The River Endpoint Discovery Service \(REDS\) performs geolocation and initialization of compute nodes, based on a mapping file that is provided with each system.

  * [Configure a Management Switch for REDS](river_endpoint_discovery_service/Configure_a_Management_Switch_for_REDS.md)
  * [Initialize and Geolocate Nodes](river_endpoint_discovery_service/Initialize_and_Geolocate_Nodes.md)
  * [Verify Node Removal](river_endpoint_discovery_service/Verify_Node_Removal.md)
  * [Troubleshoot Common REDS Issues](river_endpoint_discovery_service/Troubleshoot_Common_REDS_Issues.md)
    * [Troubleshot Common Error Messages in REDS Logs](river_endpoint_discovery_service/Troubleshoot_Common_Error_Messages_in_REDS_Logs.md)
    * [Clear State and Restart REDS](river_endpoint_discovery_service/Clear_State_and_Restart_REDS.md)


<a name="network"></a>

### Network

Overview of the several different networks supported by the HPE Cray EX system.

  * [Network](network/Network.md)
  * [Access to System Management Services](network/Access_to_System_Management_Services.md)
  * [Default IP Address Ranges](network/Default_IP_Address_Ranges.md)
  * [Connect to the HPE Cray EX Environment](network/Connect_to_the_HPE_Cray_EX_Environment.md)


<a name="customer-access-network-can"></a>

#### Customer Access Network (CAN)

The Customer Access Network \(CAN\) provides access from outside the customer network to services, NCNs, and User Access Nodes \(UANs\) in the system.

   * [Customer Access Network (CAN)](network/customer_access_network/Customer_Access_Network_CAN.md)
   * [Required Labels if CAN is Not Configured](network/customer_access_network/Required_Labels_if_CAN_is_Not_Configured.md)
   * [Externally Exposed Services](network/customer_access_network/Externally_Exposed_Services.md)
   * [Connect to the CAN](network/customer_access_network/Connect_to_the_CAN.md)
   * [CAN with Dual-Spine Configuration](network/customer_access_network/CAN_with_Dual-Spine_Configuration.md)
   * [Troubleshoot CAN Issues](network/customer_access_network/Troubleshoot_CAN_Issues.md)


<a name="dynamic-host-configuration-protocol-dhcp"></a>

#### Dynamic Host Configuration Protocol (DHCP)

The DHCP service on the HPE Cray EX system uses the Internet Systems Consortium \(ISC\) Kea tool. Kea provides more robust management capabilities for DHCP servers.

  * [DHCP](/network/dhcp/DHCP.md)
  * [Troubleshoot DHCP Issues](/network/dhcp/Troubleshoot_DHCP_Issues.md)
  * [Clear HSM Tables to Resolve DHCP Issues](/network/dhcp/Clear_HSM_Tables_to_Resolve_DHCP_Issues.md)


<a name="domain-name-service-dns"></a>

#### Domain Name Service (DNS)

The central DNS infrastructure provides the structural networking hierarchy and datastore for the system.

  * [DNS](network/dns/DNS.md)
  * [Manage the DNS Unbound Resolver](network/dns/Manage_the_DNS_Unbound_Resolver.md)
  * [Enable ncsd on UANS](network/dns/Enable_ncsd_on_UANs.md)
  * [Troubleshoot Common DNS Issues](network/dns/Troubleshoot_Common_DNS_Issues.md)
  * [Troubleshoot Services Needed by the DNS](network/dns/Troubleshoot_Services_Needed_by_the_DNS_Unbound_Resolver.md)


<a name="external_dns"></a>

#### External DNS

External DNS, along with the Customer Access Network \(CAN\), Border Gateway Protocol \(BGP\), and MetalLB, makes it simpler to access the HPE Cray EX API and system management services. Services are accessible directly from a laptop without needing to tunnel into a non-compute node \(NCN\) or override /etc/hosts settings.

  * [External DNS](network/external_dns/External_DNS.md)
  * [External DNS csi config init Input Values](network/external_dns/External_DNS_csi_config_init_Input_Values.md)
  * [Update the system-name.site-domain Value Post-Installation](network/external_dns/Update_the_system-name_site-domain_Value_Post-Installation.md)
  * [Update the can-external-dns Value Post-Installation](network/external_dns/Update_the_can-external-dns_Value_Post-Installation.md)
  * [Ingress Routing](network/external_dns/Ingress_Routing.md)
  * [Add NCNs and UANs to External DNS](network/external_dns/Add_NCNs_and_UANs_to_External_DNS.md)
  * [External DNS Failing to Discover Services Workaround](network/external_dns/External_DNS_Failing_to_Discover_Services_Workaround.md)
  * [Troubleshoot Connectivity to Services with External IPs](network/external_dns/Troubleshoot_Systems_Not_Provisioned_with_External_IPs.md)
  * [Troubleshoot DNS Configuration Issues](network/external_dns/Troubleshoot_DNS_Configuration_Issues.md)


<a name="metallb-in-bgp-mode"></a>

#### MetalLB in BGP-Mode

MetalLB is a component in Kubernetes that manages access to LoadBalancer services from outside the Kubernetes cluster. There are LoadBalancer services on the Node Management Network \(NMN\), Hardware Management Network \(HMN\), and Customer Access Network \(CAN\).

MetalLB can run in either Layer2-mode or BGP-mode for each address pool it manages. BGP-mode is used for the NMN, HMN, and CAN. This enables true load balancing \(Layer2-mode does failover, not load balancing\) and allows for a more robust layer 3 configuration for these networks.

  * [MetalLB in BGP-Mode](network/metallb_bgp/MetalLB_in_BGP-Mode.md)
  * [MetalLB in BGP-Mode Configuration](network/metallb_bgp/MetalLB_in_BGP-Mode_Configuration.md)
  * [Check BGP Status and Reset Sessions](network/metallb_bgp/Check_BGP_Status_and_Reset_Sessions.md)
  * [Troubleshoot Services without an Allocated IP Address](network/metallb_bgp/Troubleshoot_Services_without_an_Allocated_IP_Address.md)
  * [Troubleshoot BGP not Accepting Routes from MetalLB](network/metallb_bgp/Troubleshoot_BGP_not_Accepting_Routes_from_MetalLB.md)

