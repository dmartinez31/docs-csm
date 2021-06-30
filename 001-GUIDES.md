# CSM Documentation Guide

The installation of CSM software has three scenarios which are described in this documentation with many supporting procedures.  Here is an overview of the workflow through the documentation to support these scenarios.

[CSM Install] (002-CSM-INSTALL.md)

Installation prerequisites

Satisfy the prerequisites for one of these three installation scenarios 

* Migration from a Shasta v1.3.x system.  How to collect information from a v1.3.x system to be used during the v1.4 installation, quiescing v1.3.x, checking and updating firmware to required versions, recabling site connection to shift from ncn-w001 to ncn-m001, adjust management NCNs to boot over PCIe instead of onboard NICs, shutting down Kubernetes, and powering off NCNs.  Then you move to Starting an Installation.
* First time installation of Shasta software (a bare-metal install).  This describes now to setup the LiveCD to be able to collect the configuration payload, configure network switches, update firmware for switches and nodes to required versions.  Then you move to Starting an Installation.
* Reinstalling Shasta v1.4 software on a system which previously had Shasta v1.4 installed.  These steps here are scaling down DHCP, wiping disks on the NCNs (except ncn-m001), power off NCNs, change management node BMCs to be DHCP not Static, and powering off the LiveCD or ncn-m001 (unless it will be used to prepare the LiveCD).  Then you move to Starting an Installation.

Once the installation prerequisites have been addressed, the installation is very similar for all of them.  There are a few places where a comment will be made for how one of the scenarios needs to do something different.

Starting an installation

The three separate scenarios (above) continue the same way at this point, with preparation and then booting from the LiveCD.  

* This version of the documentation supports booting from a [CSM USB LiveCD] (003-CSM-USB-LIVECD.md).
* A future version of this documentation will support booting from a virtual ISO method [CSM Remote LiveCD] (004-CSM-REMOTE-LIVECD.md). 

##### [CSM USB LiveCD - Creation and Configuration](003-CSM-USB-LIVECD.md)

Preparation of the LiveCD on a USB stick can be done from a Linux system such as a booted ncn-m001 node with either Shasta v1.3 or v1.4 or a laptop or desktop.

* [Download and Expand the CSM Release](003-CSM-USB-LIVECD.md#download-and-expand-the-csm-release)
* [Create the Bootable Media](003-CSM-USB-LIVECD.md#create-the-bootable-media)
* [Configuration Payload](003-CSM-USB-LIVECD.md#configuration-payload)
  * [Generate Installation Files](003-CSM-USB-LIVECD.md#generate-installation-files)
  * [CSI Workarounds](003-CSM-USB-LIVECD.md#csi-workarounds)
  * [SHASTA-CFG](003-CSM-USB-LIVECD.md#shasta-cfg)
* [Pre-Populate LiveCD Daemons Configuration and NCN Artifacts](003-CSM-USB-LIVECD.md#pre-populate-livecd-daemons-configuration-and-ncn-artifacts)
* [Boot the LiveCD](003-CSM-USB-LIVECD.md#boot-the-livecd)
  * [First Login](003-CSM-USB-LIVECD.md#first-login)

##### [CSM Metal Install](005-CSM-METAL-INSTALL.md)

Now that ncn-m001 has been booted from the LiveCD, the other management NCNs will be deployed to create the management Kubernetes cluster.

* [Configure Bootstrap Registry to Proxy an Upstream Registry](005-CSM-METAL-INSTALL.md#configure-bootstrap-registry-to-proxy-an-upstream-registry)
* [Tokens and IPMI Password](005-CSM-METAL-INSTALL.md#tokens-and-ipmi-password)
* [Timing of Deployments](005-CSM-METAL-INSTALL.md#timing-of-deployments)
* [NCN Deployment](005-CSM-METAL-INSTALL.md#ncn-deployment)
  * [Apply NCN Pre-Boot Workarounds](005-CSM-METAL-INSTALL.md#apply-ncn-pre-boot-workarounds)
  * [Ensure Time Is Accurate Before Deploying NCNs](005-CSM-METAL-INSTALL.md#ensure-time-is-accurate-before-deploying-ncns)
  * [Start Deployment](005-CSM-METAL-INSTALL.md#start-deployment)
    * [Workflow](005-CSM-METAL-INSTALL.md#workflow)
    * [Deploy](005-CSM-METAL-INSTALL.md#deploy)
  * [Apply NCN Post-Boot Workarounds](005-CSM-METAL-INSTALL.md#apply-ncn-post-boot-workarounds)
  * [LiveCD Cluster Authentication](005-CSM-METAL-INSTALL.md#livecd-cluster-authentication)
  * [BGP Routing](005-CSM-METAL-INSTALL.md#bgp-routing)
  * [Validation](005-CSM-METAL-INSTALL.md#validation)
  * [Optional Validation](005-CSM-METAL-INSTALL.md#optional-validation)
* [Configure and Trim UEFI Entries](005-CSM-METAL-INSTALL.md#configure-and-trim-uefi-entries)


##### [CSM Platform Install](006-CSM-PLATFORM-INSTALL.md)

Install all of the CSM applications and services into the management Kubernetes cluster.

* [Initialize Bootstrap Registry](006-CSM-PLATFORM-INSTALL.md#initialize-bootstrap-registry)
* [Create Site-Init Secret](006-CSM-PLATFORM-INSTALL.md#create-site-init-secret)
* [Deploy Sealed Secret Decryption Key](006-CSM-PLATFORM-INSTALL.md#deploy-sealed-secret-decryption-key)
* [Deploy CSM Applications and Services](006-CSM-PLATFORM-INSTALL.md#deploy-csm-applications-and-services)
  * [Setup Nexus](006-CSM-PLATFORM-INSTALL.md#setup-nexus)
  * [Set NCNs to use Unbound](006-CSM-PLATFORM-INSTALL.md#set-ncns-to-use-unbound)
  * [Validate CSM Install](006-CSM-PLATFORM-INSTALL.md#validate-csm-install)
  * [Reboot from the LiveCD to NCN](006-CSM-PLATFORM-INSTALL.md#reboot-from-the-livecd-to-ncn)
* [Add Compute Cabinet Routing to NCNs](006-CSM-PLATFORM-INSTALL.md#add-compute-cabinet-routing-to-ncns)
* [Known Issues](006-CSM-PLATFORM-INSTALL.md#known-issues)
  * [error: timed out waiting for the condition on jobs/cray-sls-init-load](006-CSM-PLATFORM-INSTALL.md#error-timed-out-sls-init-load-job)
  * [Error: not ready: https://packages.local](006-CSM-PLATFORM-INSTALL.md#error-not-ready)
  * [Error initiating layer upload ... in registry.local: received unexpected HTTP status: 200 OK](006-CSM-PLATFORM-INSTALL.md#error-initiating-layer-upload)
  * [Error lookup registry.local: no such host](006-CSM-PLATFORM-INSTALL.md#error-registry-local-no-such-host)

<a name="csm-install-validation-and-health-checks"></a> 
###### [CSM Install Validation and Health Checks](008-CSM-VALIDATION.md)

The CSM installation validation and health checks can be run after install.sh finishes in this installation process, but can also be run at other times later.

* [Platform Health Checks](008-CSM-VALIDATION.md#platform-health-checks)
  * [ncnHealthChecks](008-CSM-VALIDATION.md#pet-ncnhealthchecks)
  * [ncnPostgresHealthChecks](008-CSM-VALIDATION.md#pet-ncnpostgreshealthchecks)
  * [BGP Peering Status and Reset](008-CSM-VALIDATION.md#pet-bgp)
    * [Mellanox Switch](008-CSM-VALIDATION.md#pet-bgp-mellanox)
    * [Aruba Switch](008-CSM-VALIDATION.md#pet-bgp-aruba)
* [Network Health Checks](008-CSM-VALIDATION.md#network-health-checks)
  * [Verify that KEA has active DHCP leases](008-CSM-VALIDATION.md#net-kea)
  * [Verify ability to resolve external DNS](008-CSM-VALIDATION.md#net-extdns)
  * [Verify Spire Agent is Running on Kubernetes NCNs](008-CSM-VALIDATION.md#net-spire)
  * [Verify the Vault Cluster is Healthy](008-CSM-VALIDATION.md#net-vault)
* [Automated Goss Testing](008-CSM-VALIDATION.md#automated-goss-testing)
  * [Known Goss Test Issues](008-CSM-VALIDATION.md#autogoss-issues)
* [Hardware Management Services Tests](008-CSM-VALIDATION.md#hms-tests)
  * [Test Execution](008-CSM-VALIDATION.md#hms-exec)
* [Cray Management Services Validation Utility](008-CSM-VALIDATION.md#cms-validation-utility)
  * [Usage](008-CSM-VALIDATION.md#cms-usage)
  * [Interpreting Results](008-CSM-VALIDATION.md#cms-results)
  * [Checks To Run](008-CSM-VALIDATION.md#cms-checks)
* [Booting CSM Barebones Image](008-CSM-VALIDATION.md#booting-csm-barebones-image)
  * [Locate the CSM Barebones Image in IMS](008-CSM-VALIDATION.md#csm-ims)
  * [Create a BOS Session Template for the CSM Barebones Image](008-CSM-VALIDATION.md#csm-bst)
  * [Find an available compute node and boot the session template](008-CSM-VALIDATION.md#csm-node)
  * [Reboot node](008-CSM-VALIDATION.md#csm-reboot)
  * [Verify console connections](008-CSM-VALIDATION.md#csm-consoles)
  * [Connect to the node's console and watch the boot](008-CSM-VALIDATION.md#csm-watch)
* [UAS / UAI Tests](008-CSM-VALIDATION.md#uas-uai-tests)
  * [Initialize and Authorize the CLI](008-CSM-VALIDATION.md#uas-uai-init-cli)
    * [Stop Using the CRAY_CREDENTIALS Service Account Token](008-CSM-VALIDATION.md#uas-uai-init-cli-stop)
    * [Initialize the CLI Configuration](008-CSM-VALIDATION.md#uas-uai-init-cli-init)
    * [Authorize the CLI for Your User](008-CSM-VALIDATION.md#uas-uai-init-cli-auth)
    * [Troubleshooting CLI issues](008-CSM-VALIDATION.md#uas-uai-init-cli-debug)
  * [Validate UAS and UAI Functionality](008-CSM-VALIDATION.md#uas-uai-validate)
    * [Validate the Basic UAS Installation](008-CSM-VALIDATION.md#uas-uai-validate-install)
    * [Validate UAI Creation](008-CSM-VALIDATION.md#uas-uai-validate-create)
    * [Troubleshooting](008-CSM-VALIDATION.md#uas-uai-validate-debug)
      * [Authorization Issues](008-CSM-VALIDATION.md#uas-uai-validate-debug-auth)
      * [UAS Cannot Access Keycloak](008-CSM-VALIDATION.md#uas-uai-validate-debug-keycloak)
      * [UAI Images not in Registry](008-CSM-VALIDATION.md#uas-uai-validate-debug-registry)
      * [Missing Volumes and other Container Startup Issues](008-CSM-VALIDATION.md#uas-uai-validate-debug-container)

##### [CSM Install Reboot - Final NCN Install](007-CSM-INSTALL-REBOOT.md)

The ncn-m001 node needs to reboot from the LiveCD to normal operation as a Kubernetes master node.

* [Required Services](007-CSM-INSTALL-REBOOT.md#required-services)
* [Notice of Danger](007-CSM-INSTALL-REBOOT.md#notice-of-danger)
* [LiveCD Pre-Reboot Workarounds](007-CSM-INSTALL-REBOOT.md#livecd-pre-reboot-workarounds)
* [Hand-Off](007-CSM-INSTALL-REBOOT.md#hand-off)
  * [Start Hand-Off](007-CSM-INSTALL-REBOOT.md#start-hand-off)
* [Reboot](007-CSM-INSTALL-REBOOT.md#reboot)
* [Accessing USB Partitions After Reboot](007-CSM-INSTALL-REBOOT.md#accessing-usb-partitions-after-reboot)
  * [Accessing CSI from a USB or RemoteISO](007-CSM-INSTALL-REBOOT.md#accessing-csi-from-a-usb-or-remoteiso)
* [Enable NCN Disk Wiping Safeguard](007-CSM-INSTALL-REBOOT.md#enable-ncn-disk-wiping-safeguard)

##### [CSM Validation process](008-CSM-VALIDATION.md)

[*Double-back...*](#csm-install-validation-and-health-checks)

The CSM installation validation and health checks can be run again now that ncn-m001 has been rebooted to join the Kubernetes cluster. 

##### [NCN/Management Node Locking](009-NCN-LOCKING.md) 

The NCNs should be locked to prevent accidental firmware upgrades with FAS or power down operations and reset operations with CAPMC.

* [Why?](009-NCN-LOCKING.md#why)
* [When To Lock Management NCNs](009-NCN-LOCKING.md#when-to-lock-management-ncns)
* [When To Unlock Management NCNs](009-NCN-LOCKING.md#when-to-unlock-management-ncns)
* [Locked Behavior](009-NCN-LOCKING.md#locked-behavior)
* [How To Lock Management NCNs](009-NCN-LOCKING.md#how-to-lock-management-ncns)
* [How To Unlock Management NCNs](009-NCN-LOCKING.md#how-to-unlock-management-ncns)


##### [Firmware Update the system with FAS](010-FIRMWARE-UPDATE-WITH-FAS.md)

The firmware versions of many components may need to be updated at this point in the installation process.

* [Prerequisites](010-FIRMWARE-UPDATE-WITH-FAS.md#prerequisites)
* [Current Capabilities as of Shasta Release v1.4](010-FIRMWARE-UPDATE-WITH-FAS.md#current-capabilities)
* [Order Of Operations](010-FIRMWARE-UPDATE-WITH-FAS.md#order-of-operations)
* [Hardware Precedence Order](010-FIRMWARE-UPDATE-WITH-FAS.md#hardware-precedence-order)
* [Next Steps](010-FIRMWARE-UPDATE-WITH-FAS.md#next-steps)


The details of the process are outlined in [255-FIRMWARE-ACTION-SERVICE-FAS.md](255-FIRMWARE-ACTION-SERVICE-FAS.md) using recipes listed in [256-FIRMWARE-ACTION-SERVICE-FAS-RECIPES.md](256-FIRMWARE-ACTION-SERVICE-FAS-RECIPES.md)

Then the administrator should install additional products following the procedures in the HPE Cray EX System Installation and Configuration Guide S-8000.

# Naming convention for files in CSM documentation

These documentation files are grouped to keep similar pages together.

- 000 - 001 INTRO : Information describing this book.
- 002 - 008 CSM INSTALL : Install Pages for CSM
- 009 - 049: Other install pages
- 050 - 099 PROCS : Procedures referenced by install; help guides, tricks/tips, etc.
- 100 - 150 NCN-META : Technical information for Non-Compute Nodes
- 250 - 300 Common  : Technical information common to all nodes.
- 300 - 350 MFG/SVC : Procedures referenced by service teams.
- 400 - 499 NETWORK : Procedures for management network installation.