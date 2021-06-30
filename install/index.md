# Install CSM

Installation of the CSM product stream has many steps in multiple procedures which should be done in a
specific order.  Information about the HPE Cray EX system and the site is used to prepare the configuration
payload.  The initial node used to bootstrap the installation process is called the PIT node because the
Pre-Install Toolkit is installed there. Once the management network switches have been configured, the other
management nodes can be deployed with an operating system and the software to create a Kubernetes cluster
utilizing Ceph storage.  The CSM services provide essential software infrastructure including the API gateway
and many microservices with REST APIs for managing the system.  Once administrative access has been configured,
the installation of CSM software and nodes can be validated with health checks before doing operational tasks
like the check and update of firmware on system components or the preparation of compute nodes. 
Once the CSM installation has completed, other product streams for the HPE Cray EX system can be installed.

### Topics:
   
   1. [Validate Management Network Cabling](#validate_management_network_cabling)
   1. [Prepare Configuration Payload](#prepare_configuration_payload)
   1. [Prepare Management Nodes](#prepare_management_nodes)
   1. [Bootstrap PIT Node](#bootstrap_pit_node)
   1. [Configure Management Network Switches](#configure_management_network)
   1. [Collect MAC Addresses for NCNs](#collect_mac_addresses_for_ncns)
   1. [Deploy Management Nodes](#deploy_management_nodes)
   1. [Install CSM Services](#install_csm_services)
   1. [Validate CSM Health Before PIT Node Redeploy](#validate_csm_health_before_pit_redeploy)
   1. [Redeploy PIT Node](#redeploy_pit_node)
   1. [Configure Administrative Access](#configure_administrative_access)
   1. [Validate CSM Health](#validate_csm_health)
   1. [Update Firmware with FAS](#update_firmware_with_fas)
   1. [Prepare Compute Nodes](#prepare_compute_nodes)
   1. [Next Topic](#next_topic)
   1. [Troubleshooting Installation Problems](#troubleshooting_installation)

The topics in this chapter need to be done as part of an ordered procedure so are shown here with numbered topics.

**Note**: If problems are encountered during the installation, some of the topics do have their own troubleshooting
sections, but there is also a general troubleshooting topic.

## Details
 
   <a name="validate_management_network_cabling"></a>

   1. Validate Management Network Cabling  
   The cabling should be validated between the nodes and the management network switches.  The information in the 
   Shasta Cabling Diagram (SHCD) can be used to confirm the cables which physically connect components of the system. 
   Having the data in the SHCD which matches the physical cabling will be needed later in both
   [Prepare Configuration Payload](#prepare_configuration_payload) and [Configure Management Network Switches](#configure_management_network).
   
      See [Validate Management Network Cabling](validate_management_network_cabling.md)  

      **Note**: If a reinstall or fresh install of this software release is being done on this system and the management
      network cabling has already been validated, then this topic could be skipped and instead move to
      [Prepare Configuration Payload](#prepare_configuration_payload)
   <a name="prepare_configuration_payload"></a>

   1. Prepare Configuration Payload  
   Information gathered from a site survey is needed to feed into the CSM installation process, such as system name,
   system size, site network information for the CAN, site DNS configuration, site NTP configuration, network
   information for the node used to bootstrap the installation.  Much of the information about the system hardware
   is encapsulated in the SHCD (Shasta Cabling Diagram), which is a spreadsheet prepared by HPE Cray Manufacturing
   to assemble the components of the system and connect appropriately labeled cables. 
   
      See [Prepare Configuration Payload](prepare_configuration_payload.md)  
   <a name="prepare_management_nodes"></a>

   1. Prepare Management Nodes  
   Some preparation of the management nodes might be needed before starting an install or reinstall.
   The preparation includes checking and updating the firmware on the PIT node, quiescing the compute nodes
   and application nodes, scaling back DHCP on the management nodes, wiping the storage on the management nodes,
   powering off the management nodes, and possibly powering off the PIT node.

   
      See [Prepare Management Nodes](prepare_management_nodes.md)  
   <a name="bootstrap_pit_node"></a>
   
   1. Bootstrap PIT Node  
   The Pre-Install Toolkit (PIT) node needs to be bootstrapped from the LiveCD.  There are two media available
   to bootstrap the PIT node--the RemoteISO or a bootable USB device.  The recommended media is the RemoteISO,
   since it does not require any physical media to prepare. However, remotely mounting an ISO on a BMC does not
   work smoothly for nodes from all vendors. It is recommended to try the RemoteISO first.  
   
      Use one of these procedures to bootstrap the PIT node from the LiveCD.  
      * [Bootstrap Pit Node from LiveCD Remote ISO](bootstrap_livecd_remote_iso.md) (recommended)
         * **Gigabyte BMCs** should not use the RemoteISO method.
         * **Intel BMCs** should not use the RemoteISO method.
      * [Bootstrap Pit Node from LiveCD USB](bootstrap_livecd_usb.md) (fallback)

      Using the LiveCD USB method requires a USB 3.0 device with at least 1TB of space to create a bootable LiveCD.
   <a name="configure_management_network"></a>  

   1. Configure Management Network Switches  
   Now that the PIT node has been booted with the LiveCD environment and CSI has generated the switch IP addresses,
   the management network switches can be configured.  This procedure will configure the spine switches, aggregation
   switches (if present), CDU switches (if present), and the leaf switches.  
   
      See [Configure Management Network Switches](configure_management_network.md)  
      
      **Note**: If a reinstall of this software release is being done on this system and the management network switches
      have already been configured, then this topic could be skipped and instead move to
      [Collect MAC Addresses for NCNs](#collect_mac_addresses_for_ncns)
   <a name="collect_mac_addresses_for_ncns"></a>

   1. Collect MAC Addresses for NCNs  
   Now that the PIT node has been booted with the LiveCD and the management network switches have been configured,
   the actual MAC address for the management nodes can be collected.  This process will include repitition of some
   of the steps done up to this point because `csi config init` will need to be run with the proper
   MAC addresses.

      See [Collect MAC Addresses for NCNs](collect_mac_addresses_for_ncns.md)

      **Note**: If a reinstall of this software release is being done on this system and the `ncn_metadata.csv`
      file aleady had valid MAC addresses for both BMC and node interfaces before `csi config init` was run, then
      this topic could be skipped and instead move to [Deploy Management Nodes](#deploy_management_nodes).  

      **Note**: If a first time install of this software release is being done on this system and the `ncn_metadata.csv`
      file aleady had valid MAC addresses for both BMC and node interfaces before `csi config init` was run, then
      this topic could be skipped and instead move to [Deploy Management Nodes](#deploy_management_nodes).  
   <a name="deploy_management_nodes"></a>
 
   1. Deploy Management Nodes  
   Now that the PIT node has been booted with the LiveCD and the management network switches have been configured,
   the other management nodes can be deployed.  This procedure will boot all of the management nodes, initialize
   Ceph storage on the storage nodes and start the Kubernetes cluster on all of the worker nodes and the master nodes,
   except for the PIT node.  The PIT node will join Kubernetes after it is rebooted later in 
   [Redeploy PIT Node](#redeploy_pit_node).  
   
      See [Deploy Management Nodes](deploy_management_nodes.md)  
   <a name="install_csm_services"></a>
 
   1. Install CSM Services  
   Now that deployment of management nodes is complete with initialized Ceph storage and a running Kubernetes
   cluster on all worker and master nodes, except the PIT node, the CSM services can be installed.  The Nexus
   repository will be populated with artifacts, containerized CSM services will be installed, and a few other configuration steps.  
   
      See [Install CSM Services](install_csm_services.md)
   <a name="validate_csm_health_before_pit_redeploy"></a>
 
   1. Validate CSM Health Before PIT Node Redeploy  
   After installing all of the CSM services now would be an good time to validate the health of the
   management nodes and all CSM services.  The advantage in doing it now is that if there are any problems
   detected with the core infrastructure or the nodes, it is easy to rewind the installation to
   [Deploy Management Nodes](#deploy_management_nodes) since the PIT node has not yet been redeployed.  
   
      After installing all of the CSM services, wait at least 15 minutes to let the various Kubernetes
      resources get initialized and started before trying to validate CSM health. Because there are a number
      of dependencies between them, some services are not expected to work immediately after the install
      script completes.  Some of the time waiting can be spent preparing the `cray` CLI.  
      
      **Note**: If doing the CSM validation at this point, some of the tests which use the 'cray' CLI may fail
      until these two procedures have been done.  These tests, such as Booting the CSM Barebones Image on compute
      nodes or the UAS/UAI Tests can be skipped until after the PIT node has been redeployed.  
   
      To enable the 'cray' CLI, these two procedures could be done now.  
      
      * Optional [Configure Keycloak Account](configure_administrative_access.md#configure_keycloak_account)
      * Optional [Configure the Cray Command Line Interface (cray CLI)](configure_administrative_access.md#configure_cray_cli)  
   
      To run the CSM health checks now, see [Validate CSM Health](../operations/validate_csm_health.md)  
   <a name="redeploy_pit_node"></a>

   1. Redeploy PIT Node  
   Now that all CSM services have been installed and the CSM health checks completed, with the possible exception
   of Booting the CSM Barebones Image and the UAS/UAI tests, the PIT node can be rebooted to leave the LiveCD
   environment and assume its intended role as one the Kubernetes master nodes.  
   
      See [Redeploy PIT Node](redeploy_pit_node.md)
   <a name="configure_administrative_access"></a>

   1. Configure Administrative Access  
   Now that all of the CSM services have been installed and the PIT node has been redeployed, administrative access
   can be prepared.   This may include configuring Keycloak with a local Keycloak account or confirming Keycloak
   is properly federating LDAP or other Identity Provider (IdP), initializing the 'cray' CLI for administrative 
   commands, locking the management nodes from accidental actions firmware updates by FAS or power actions by
   CAPMC, and configuring node BMCs (node controllers) for nodes in liquid cooled cabinets.  
   
      See [Configure Administrative Access](configure_administrative_access.md)
   <a name="validate_csm_health"></a>

   1. Validate CSM Health   
   Now that all management nodes have joined the Kubernetes cluster, CSM services have been installed,
   and administrative access has been enabled, the health of the management nodes and all CSM services
   should be validated.  There are no exceptions to running the tests--all can be run now.  
   
      This CSM health validation can also be run at other points during the system lifecycle, such as when replacing
      a management node, checking the health after a management node has rebooted due to a crash, as part of doing
      a full system power down or power up, or after other types of system maintenance.  
   
      See [Validate CSM Health](../operations/validate_csm_health.md)
   <a name="update_firmware_with_fas"></a>

   1. Update Firmware with FAS  
   Now that all management nodes and CSM services have been validated as healthy, the firmware on other
   components in the system can be checked and updated.  The Firmware Action Service (FAS) communicates
   with many devices on the system. FAS can be used to update the firmware for all of the devices it
   communicates with at once, or specific devices can be targeted for a firmware update.  
   
      See [Update Firmware with FAS](../operations/update_firmware_with_fas.md)
   <a name="prepare_compute_nodes"></a>

   1. Prepare Compute Nodes  
   After completion of the firmware update with FAS, compute nodes can be prepared.  Some compute node
   types have special preparation steps, but most compute nodes are ready to be used now.  
   
      These compute node types require preparation.  
         * HPE Apollo 6500 XL645d Gen10 Plus  
   
      See [Prepare Compute Nodes](prepare_compute_nodes.md)
   <a name="next_topic"></a>
   1. Next Topic  
   After completion of the firmware update with FAS and the preparation of compute nodes, the CSM product stream has
   been fully installed and configured.  Refer to the _HPE Cray EX Installation and Configuration Guide 1.5 S-8000_
   for other product streams to be installed and configured after CSM.
   <a name="troubleshooting_installation"></a>
   
   1. Troubleshooting Installation Problems  
   The installation of the Cray System Management (CSM) product requires knowledge of the various nodes and
   switches for the HPE Cray EX system. The procedures in this section should be referenced during the CSM install
   for additional information on system hardware, troubleshooting, and administrative tasks related to CSM.  
   See [Troubleshooting Installation Problems](troubleshooting_installation.md)