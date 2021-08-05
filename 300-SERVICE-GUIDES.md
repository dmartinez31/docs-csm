# Service Guides

This guide centers around constructing bootstrap-files and contains various pre-install operations.

The remainder of _this_ page provides important nomenclature, notes, and environment
help.

>#### Pre-Spring 2020 CRAY System Upgrade Notice
> Systems built before Sprint 2020 originally used onboard NICs for netbooting. The new topologies for Shasta
> cease using the onboard NICs. If your system is running Shasta v1.3, then it likely is using onboard NICs.
>
> It is recommended to cease using these for Shasta v1.4, an admin would have one less MAC address to track and account for.
> The NCN networking becomes relatively simpler as a result from caring about one less NIC.

This guide may receive more installments for other files as time goes on.

### Table of Contents:

- [Environments](#environments)
- [Nomenclature and Constraints](#nomenclature--constraints)
- [Files](#files)
    - [`ncn_metadata.csv`](#ncn_metadatacsv)
    - [`switch_metadata.csv`](#switch_metadatacsv)
    - [`hmn_connections.json`](#hmn_connectionsjson)

<a name="environments"></a>
## Environments

These guides expect you to have access to either of the following things for working on a bare-metal
system (assuming freshly racked, or fresh-installing an existing system).

- LiveCD (for more information, see [LiveCD USB Boot](003-CSM-USB-LIVECD.md))
- Linux and a Serial Console

If you do not have the LiveCD, or any other local Linux environment, this data collection
may be quicker the alternative method through the [303-NCN-METADATA-USB-SERIAL](303-NCN-METADATA-USB-SERIAL.md) page.

There are 2 parts to the NCN metadata file:
- Collecting the MAC of the BMC
- Collecting the MAC(s) of the shasta-network interface(s)

#### What is a "shasta-network interface"?

**This is not the High-Speed Network interface**

This is the interface, one or more, that comprise the NCNs' LACP link-aggregation ports.

##### LACP Bonding
NCNs may have 1 or more bond interfaces, which may be comprised from one or more physical interfaces. The
preferred default configuration is 2 physical network interfaces per bond. The number 
of bonds themselves depends on your systems network topology.

For example, systems with 4 network interfaces on a given node could configure either of these
permutations (for redundancy minimums within Shasta cluster):
- 1 bond with 4 interfaces (i.e. `bond0`)
- 2 bonds with 2 interfaces each (i.e. `bond0` and `bond1`)

For more information, see [103-NETWORKING](103-NCN-NETWORKING.md) page for NCNs.

<a name="nomenclature--constraints"></a>
## Nomenclature and Constraints

#### "PXE" or "BOOTSTRAP" MAC

In general this refers to the interface to be used when the node attempts to PXE boot. This varies between vintages
of systems; systems before "Spring 2020" often booted NCNs with onboard NICs, newer systems boot over their PCIe cards.

If the system is **booting over PCIe than the "bootstrap MAC" and the "bond0 MAC 0" will be identical**. If the 
system is **booting over onboards then the "bootstrap MAC" and the "bond0 MAC 0" will be different.**

> Other Nomenclature
- "BOND MACS" are the MAC addresses for the physical interfaces that your node will use for the various VLANs.
- "NMN MAC" is this is the same as the BOND MAC addresses, but with emphasis on the vlan-participation.
> Relationships ...
- BOND0 MAC0 and BOND0 MAC1 should **not** be on the same physical network card to establish redundancy for failed chips.
- On the other hand, if any nodes' capacity prevents it from being redundant, then MAC1 and MAC0 will still produce a valid configuration if they do reside on the same physical chip/card.
- The BMC MAC is the exclusive, dedicated LAN for the onboard BMC. It should not be swapped with any other device.

<a name="files"></a>
## Files

Each paragraph here will denote which pre-reqs are needed and which pages to follow 
for data collection.

--- 

<a name="ncn_metadatacsv"></a>
### `ncn_metadata.csv`

Unless your system is sans-onboards, meaning it does not use or does not have onboard NICs on the non-compute nodes, then these guides will be necessary before (re)constructing the `ncn_metadata.csv` file.
1. [Recabling from Shasta v1.3 for Shasta v1.4](309-MOVE-SITE-CONNECTIONS.md) (for machines still using ncn-w001 for BIS node)
2. [Enabling Network Boots over Spine Switches](304-NCN-PCIE-NET-BOOT-AND-RE-CABLE.md) (for Shasta v1.3 machines)

The following two guides will assist with (re)creating `ncn_metadata.csv` (an example file is below).

1. [Collecting BMC MAC Addresses](301-NCN-METADATA-BMC.md)
2. [Collecting NCN MAC Addresses](302-NCN-METADATA-BONDX.md)

The following are sample rows from a `ncn_metadata.csv` file:
* __Use case__: NCN with a single PCIe card (1 card with 2 ports):
    > Notice how the MAC address for `Bond0 MAC0` and `Bond0 MAC1` are only off by 1, which indicates that 
    > they are on the same 2 port card.
    ```
    Xname,Role,Subrole,BMC MAC,Bootstrap MAC,Bond0 MAC0,Bond0 MAC1
    x3000c0s6b0n0,Management,Worker,94:40:c9:37:77:b8,14:02:ec:da:bb:00,14:02:ec:da:bb:00,14:02:ec:da:bb:01
    ```
* __Use case__: NCN with a dual PCIe cards (2 cards with 2 ports each for 4 ports total):
    > Notice how the MAC address for `Bond0 MAC0` and `Bond0 MAC1` have a difference greater than 1, which 
    > indicates that they are on not on the same 2 port same card.
    ```
    Xname,Role,Subrole,BMC MAC,Bootstrap MAC,Bond0 MAC0,Bond0 MAC1
    x3000c0s9b0n0,Management,Storage,94:40:c9:37:77:26,14:02:ec:d9:76:88,14:02:ec:d9:76:88,94:40:c9:5f:b6:92
    ```

Example `ncn_metadata.csv` file for a system that has been configured as follows:
 * NCNs are configured to boot over the PCIe NICs
 * Master and Storage nodes have two 2 port PCIe cards
 * Worker nodes have one 2 port PCIe card
> Since the NCN have been configured to boot over their PCIe NICs the values for the columns `Bootstrap MAC` and `Bond0 MAC0` have the same value.
```
Xname,Role,Subrole,BMC MAC,Bootstrap MAC,Bond0 MAC0,Bond0 MAC1
x3000c0s9b0n0,Management,Storage,94:40:c9:37:77:26,14:02:ec:d9:76:88,14:02:ec:d9:76:88,94:40:c9:5f:b6:92
x3000c0s8b0n0,Management,Storage,94:40:c9:37:87:5a,14:02:ec:d9:7b:c8,14:02:ec:d9:7b:c8,94:40:c9:5f:b6:5c
x3000c0s7b0n0,Management,Storage,94:40:c9:37:0a:2a,14:02:ec:d9:7c:88,14:02:ec:d9:7c:88,94:40:c9:5f:9a:a8
x3000c0s6b0n0,Management,Worker,94:40:c9:37:77:b8,14:02:ec:da:bb:00,14:02:ec:da:bb:00,14:02:ec:da:bb:01
x3000c0s5b0n0,Management,Worker,94:40:c9:35:03:06,14:02:ec:d9:76:b8,14:02:ec:d9:76:b8,14:02:ec:d9:76:b9
x3000c0s4b0n0,Management,Worker,94:40:c9:37:67:60,14:02:ec:d9:7c:40,14:02:ec:d9:7c:40,14:02:ec:d9:7c:41
x3000c0s3b0n0,Management,Master,94:40:c9:37:04:84,14:02:ec:d9:79:e8,14:02:ec:d9:79:e8,94:40:c9:5f:b5:cc
x3000c0s2b0n0,Management,Master,94:40:c9:37:f9:b4,14:02:ec:da:b8:18,14:02:ec:da:b8:18,94:40:c9:5f:a3:a8
x3000c0s1b0n0,Management,Master,94:40:c9:37:87:32,14:02:ec:da:b9:98,14:02:ec:da:b9:98,14:02:ec:da:b9:99
```

<a name="switch_metadatacsv"></a>
### `switch_metadata.csv`

This file denotes your network topology devices, see [Switch Metadata](305-SWITCH-METADATA.md) for 
directions about creating this file. 

> use case: 2 leaf switches and 2 spine switches
```
pit# cat example_switch_metadata.csv
Switch Xname,Type,Brand
x3000c0w38,Leaf,Dell
x3000c0w36,Leaf,Dell
x3000c0h33s1,Spine,Mellanox
x3000c0h33s2,Spine,Mellanox
```
> use case: 2 CDU switches, 2 leaf switches, and 2 spines switches
```
pit# cat example_switch_metadata.csv
Switch Xname,Type,Brand
d0w1,CDU,Dell
d0w2,CDU,Dell
x3000c0w38,Leaf,Dell
x3000c0w36,Leaf,Dell
x3000c0h33s1,Spine,Mellanox
x3000c0h34s1,Spine,Mellanox
```

> use case: 2 CDU Switches, 2 leaf switches, 4 aggregation switches, and 2 spine switches
```
pit# cat example_switch_metadata.csv
Switch Xname,Type,Brand
d0w1,CDU,Aruba
d0w2,CDU,Aruba
x3000c0w31,Leaf,Aruba
x3000c0w32,Leaf,Aruba
x3000c0h33s1,Aggregation,Aruba
x3000c0h34s1,Aggregation,Aruba
x3000c0h35s1,Aggregation,Aruba
x3000c0h36s1,Aggregation,Aruba
x3000c0h37s1,Spine,Aruba
x3000c0h38s1,Spine,Aruba
``` 

<a name="hmn_connectionsjson"></a>
### `hmn_connections.json`

This file denotes your BMC interfaces and other hardware network topology devices, see [HMN Connections](307-HMN-CONNECTIONS.md) for
instructions creating this file. 

[1]: https://stash.us.cray.com/projects/MTL/repos/cray-pre-install-toolkit/browse
[2]: https://stash.us.cray.com/projects/MTL/repos/cray-site-init/browse
[3]: https://stash.us.cray.com/projects/MTL/repos/ipxe/browse