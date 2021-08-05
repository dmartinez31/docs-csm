
<a name="ncn-partitions"></a>
# NCN Partitions

Shasta non-compute nodes use drive storage for persistence and block storage. This page outlines
reference information for these disks, their partition tables, and their management.

* [NCN Partitions](104-NCN-PARTITIONING.md#ncn-partitions)
    * [What Controls Partitioning?](104-NCN-PARTITIONING.md#what-controls-partitioning)
    * [Plan of Record / Baseline](104-NCN-PARTITIONING.md#plan-of-record--baseline)
        * [Problems When Above/Below Baseline](104-NCN-PARTITIONING.md#problems-when-abovebelow-baseline)
        * [Worker Nodes with ETCD](104-NCN-PARTITIONING.md#worker-nodes-with-etcd)
            * [Disable Luks](104-NCN-PARTITIONING.md#disable-luks)
            * [Expand the RAID](104-NCN-PARTITIONING.md#expand-the-raid)
    * [Disk Layout Quick-Reference Tables](104-NCN-PARTITIONING.md#disk-layout-quick-reference-tables)
* [OverlayFS and Persistence](104-NCN-PARTITIONING.md#overlayfs-and-persistence)
    * [Persistent Directories](104-NCN-PARTITIONING.md#persistent-directories)
    * [OverlayFS Example](104-NCN-PARTITIONING.md#overlayfs-example)
      * [Layering - Upperdir and Lowerdir(s)](104-NCN-PARTITIONING.md#layering---upperdir-and-lowerdirs)
      * [Layering Real World Example](104-NCN-PARTITIONING.md#layering-real-world-example)
    * [OverlayFS Control](104-NCN-PARTITIONING.md#overlayfs-control)
        * [Reset Toggles](104-NCN-PARTITIONING.md#reset-toggles)
        * [Reset On Next Boot](104-NCN-PARTITIONING.md#reset-on-next-boot)
        * [Reset on Every Boot](104-NCN-PARTITIONING.md#reset-on-every-boot)
        * [Re-sizing the Persistent Overlay](104-NCN-PARTITIONING.md#re-sizing-the-persistent-overlay)
        * [Thin Overlay Feature](104-NCN-PARTITIONING.md#thin-overlay-feature)
* [SystemD MetalFS](104-NCN-PARTITIONING.md#systemd-metalfs)
* [Old/Retired FS-Labels](104-NCN-PARTITIONING.md#oldretired-fs-labels)


<a name="what-controls-partitioning"></a>
## What Controls Partitioning?

Partitioning is controlled by two aspects:

- dracut; this selects disks and builds their partition tables and/or LVM storage.
- cloud-init; this manages standalone partitions or volumes, as well as high-level object storage.

<a name="plan-of-record--baseline"></a>
## Plan of Record / Baseline

| Node Type | No. of "small" disks (0.5 TiB) | No. of "large" disks (1.9 TiB) |
| --- |:---:|:---:|
| k8s-master nodes | 3 | 0
| k8s-worker nodes | 2 | 1 
| ceph-storage nodes | 2 | 3+

Disks are chosen by dracut. Kubernetes and storage nodes use different dracut modules.
- First, `two disks` for the OS are chosen from the pool of "small" disks
- Second, `one disk` is selected for the ephemeral data

<a name="problems-when-abovebelow-baseline"></a>
### Problems When Above/Below Baseline

NCN masters and workers use the same artifacts, and thus have the same dracut modules assimilating disks. Therefore, it is important
to beware of:
- k8s-master nodes with 1 or more extra "large" disk(s); these disks help but are unnecessary 
- ceph-storage nodes do not run the same dracut modules since they have different disk demands

<a name="worker-nodes-with-etcd"></a>
### Worker Nodes with ETCD

k8s-worker nodes with 1 or more extra "small" disk(s); these disks are confusing and unnecessary and can be disabled
easily.

<a name="disable-luks"></a>
#### Disable Luks

> **`NOTE`** This is broken, use the [expand RAID](#expand-the-raid) option instead. (MTL-1309) 

All NCNs (master/worker/storage) have the same kernel parameters, but are not always necessary. This method works by toggling the dependency
for the metal ETCD module, disabling LUKs will disable ETCD bare-metal creation.

1. Disable LUKs for each worker node, thus disabling the metal ETCD module:
    - During Bootstrap (on the `pit` node):
        ```bash
        sed -i 's/disk-opts rd.luks /disk-opts rd.luks=0 /g' /var/www/ncn-w*/script.ipxe
        ```
    - During runtime with `csi`:
        ```bash
        csi handoff bss-update-param rd.luks=0
        ```

1. Rebuild the node
    - Run the [basic wipe](051-DISK-CLEANSLATE.md#basic-wipe) if the node was already booted
    - (re)boot the node

<a name="expand-the-raid"></a>
#### Expand the RAID

This option simply expands the RAID to consume the extra disks, leaving none behind for the metal ETCD module to find.

1. Set `metal.disks` equal to the number of "small" disks in the node(s), this will reserve them for the RAID and prevent any other partitioning from happening on them.

    - During Bootstrap (on the `pit` node):
        ```bash
        sed -i 's/disk-opts /disk-opts metal.disks=3 /g' /var/www/ncn-w*/script.ipxe
        ```
    - During runtime with `csi`:
        ```bash
        csi handoff bss-update-param metal.disks=3
        ```

1. Change the RAID type, or leave it as default (mirror)

    - During Bootstrap (on the `pit` node):
        ```bash
        sed -i 's/disk-opts /disk-opts metal.md-level=stripe /g' /var/www/ncn-w*/script.ipxe
        ```
    - During runtime with `csi`:
        ```bash
        csi handoff bss-update-param metal.md-level=stripe
        ```

1. Rebuild the node
    - Run the [basic wipe](051-DISK-CLEANSLATE.md#basic-wipe) if the node was already booted
    - (re)boot the node

<a name="disk-layout-quick-reference-tables"></a>
## Disk Layout Quick-Reference Tables

The table below represents all recognizable FS labels on any given NCN, varying slightly by node-role (i.e. kubernetes-manager vs. kubernetes-worker).

| k8s-manager | k8s-worker | storage-ceph | FS Label | Partitions | Device |  Partition Size | OverlayFS | Work Order(s) | Memo
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ✅ | ✅ | ✅ | `BOOTRAID` | _Not Mounted_ | 2 small disks in RAID1 | `500 MiB` | ❌ | Present since Shasta-Preview 1 |
| ✅ | ✅ | ✅ | `SQFSRAID` | `/run/initramfs/live` | 2 small disks in RAID1 | `100 GiB` | ✅ | [CASM-1885](https://connect.us.cray.com/jira/browse/MTL-1885) |  squashfs should compress our images to about 1/3rd their uncompressed size. (20G → 6.6G)  On pepsi's ncn-w001, we are at about 20G of non-volatile data storage needed. |
| ✅ | ✅ | ✅ | `ROOTRAID` | `/run/initramfs/overlayfs` | 2 small disks in RAID1 | Max/Remainder | ✅ | Present since Shasta-Preview 1 | The persistent image file is loaded from this partition, when the image file is loaded the underlying drive is lazily unmounted (`umount -l`) so that when the overlay closes the disk follows suit. |
| ❌ | ✅ | ❌ | `CONRUN` | `/run/containerd` | Ephemeral | `75 GiB` | ❌ | [MTL-916](https://connect.us.cray.com/jira/browse/MTL-916) | On pepsi ncn-w001, we have less than 200G of operational storage for this. |
| ❌ | ✅ | ❌ | `CONLIB` | `/run/lib-containerd` | Ephemeral | `25%` | ✅ | [MTL-892](https://connect.us.cray.com/jira/browse/MTL-892) [CASMINST-255](https://connect.us.cray.com/jira/browse/CASMINST-255) | |
| ✅ | ❌ | ❌ | `ETCDK8S` | `/run/lib-etcd` | Ephemeral | `32 GiB` | ✅ | [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) | |
| ✅ | ❌ | ❌ | `K8SLET` | `/var/lib/kubelet` | Ephemeral | `25%` | ❌ | [MTL-892](https://connect.us.cray.com/jira/browse/MTL-892) [CASMINST-255](https://connect.us.cray.com/jira/browse/CASMINST-255) | |

The above table's rows with overlayFS map their "Mount Paths" to the "Upper Directory" in the table below:

> The "OverlayFS Name" is the name used in fstab and seen in the output of `mount`.

| OverlayFS Name | Upper Directory | Lower Directory (or more) 
| --- | --- | --- |
| `etcd_overlayfs` | `/run/lib-etcd` | `/var/lib/etcd` |
| `containerd_overlayfs` | `/run/lib-containerd` | `/var/lib/containerd` |

> For notes on previous/old labels, scroll to the bottom.

<a name="overlayfs-and-persistence"></a>
# OverlayFS and Persistence

There are a few overlays used for NCN image boots. These enable two critical functions; changes to data and new data will persist between reboots, and RAM (memory) is freed because we are using our block-devices (SATA/PCIe).

1. `ROOTRAID` is the persistent root overlayFS, it commits and saves all changes made to the running OS and it stands on a RAID1 mirror.
2. `CONLIB` is a persistent overlayFS for containerd, it commits and saves all new changes while allowing read-through to pre-existing (baked-in) data from the squashFS.
3. `ETCDK8S` is a persistent overlayFS for etcd, it works like the `CONLIB` overlayFS however this exists in an encrypted LUKS2 partition.

<a name="persistent-directories"></a>
#### OverlayFS Example

> Helpful commands... the overlayFS organization can be best viewed with these three commands:
> 1. `lsblk`, `lsblk -f` will show how the RAIDs and disks are mounted
> 2. `losetup -a` will show where the squashFS is mounted from
> 3. `mount | grep ' / '` will show you the overlay being layered atop the squashFS


Let us pick apart the `SQFSRAID` and `ROOTRAID` overlays. 
- `/run/rootfsbase` is the SquashFS image itself
- `/run/initramfs/live` is the squashFS's storage array, where one or more squashFS can live
- `/run/initramfs/overlayfs` is the overlayFS storage array, where the persistent directories live
- `/run/overlayfs` and `/run/ovlwork` are symlinks to `/run/initramfs/overlayfs/overlayfs-SQFSRAID-$(blkid -s UUID -o value /dev/disk/by-label/SQFSRAID) and the neighboring work directory
- Admin note: The "work" directory is where the operating system processes data. It is the interim where data passes between RAM and persistent storage.

Using the above bullets, one may be able to better understand the machine output below:

```bash
ncn-m002# mount | grep  ' / '
LiveOS_rootfs on / type overlay (rw,relatime,lowerdir=/run/rootfsbase,upperdir=/run/overlayfs,workdir=/run/ovlwork)
                                             ^^^R/O^SQUASHFS IMAGE^^^|^^^ R/W PERSISTENCE ^^^|^^^^^^INTERIM^^^^^^
                                             ^^^R/O^SQUASHFS IMAGE^^^|^^^ R/W PERSISTENCE ^^^|^^^^^^INTERIM^^^^^^
                                             ^^^R/O^SQUASHFS IMAGE^^^|^^^ R/W PERSISTENCE ^^^|^^^^^^INTERIM^^^^^^
ncn-m002#  losetup -a
/dev/loop1: [0025]:74858 (/run/initramfs/thin-overlay/meta)
/dev/loop2: [0025]:74859 (/run/initramfs/thin-overlay/data)
/dev/loop0: [2430]:100 (/run/initramfs/live/LiveOS/filesystem.squashfs)
```

> The THIN OVERLAY is the transient space the system uses behind the scenes to allow data to live in RAM as it is written to disk.
> The THIN part of the overlay is the magic, using THIN overlays means the kernel will automatically clear free blocks.

Below is the layout of what a persistent system looks like. Note, this means that persistent capacity
is there, but admins should beware of reset toggles on unfamiliar systems. There are toggles to reset
overlays that are, by default, toggled `off` (so data persistence be default is safe but one should
not assume).

```bash
ncn-m002# lsblk
NAME                MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
loop0                 7:0    0   3.8G  1 loop  /run/rootfsbase
loop1                 7:1    0    30G  0 loop
└─live-overlay-pool 254:2    0   300G  0 dm
loop2                 7:2    0   300G  0 loop
└─live-overlay-pool 254:2    0   300G  0 dm
sda                   8:0    1 447.1G  0 disk
├─sda1                8:1    1   476M  0 part
│ └─md127             9:127  0   476M  0 raid1
├─sda2                8:2    1  92.7G  0 part
│ └─md126             9:126  0  92.6G  0 raid1 /run/initramfs/live
└─sda3                8:3    1 279.4G  0 part
  └─md125             9:125  0 279.3G  0 raid1 /run/initramfs/overlayfs
sdb                   8:16   1 447.1G  0 disk
├─sdb1                8:17   1   476M  0 part
│ └─md127             9:127  0   476M  0 raid1
├─sdb2                8:18   1  92.7G  0 part
│ └─md126             9:126  0  92.6G  0 raid1 /run/initramfs/live
└─sdb3                8:19   1 279.4G  0 part
  └─md125             9:125  0 279.3G  0 raid1 /run/initramfs/overlayfs
sdc                   8:32   1 447.1G  0 disk
└─ETCDLVM           254:0    0 447.1G  0 crypt
  └─etcdvg0-ETCDK8S 254:1    0    32G  0 lvm   /run/lib-etcd
```

<a name="overlayfs-example"></a>
### Persistent Directories

**Not all directories are persistent!**

Only the following directories are persistent _by default_:

- `etc`
- `home`
- `root`
- `srv`
- `tmp`
- `var`
- `/run/containerd`
- `/run/lib-containerd`
- `/run/lib-etcd`
- `/run/lib/kubelet`

More directories can be added, but mileage varies. The initial set is actually managed by dracut, when
using a reset toggle the above list is "reset/cleared". If more directories are added, they will be eradicated when
enabling a reset toggle.

These are all provided through the Overlay from `/run/overlayfs`:
```bash
ncn-m001:/run/overlayfs # ls -l
total 0
drwxr-xr-x 8 root root 290 Oct 15 22:41 etc
drwxr-xr-x 3 root root  18 Oct 15 22:41 home
drwx------ 3 root root  39 Oct 13 16:53 root
drwxr-xr-x 3 root root  18 Oct  5 19:16 srv
drwxrwxrwt 2 root root  85 Oct 16 14:50 tmp
drwxr-xr-x 8 root root  76 Oct 13 16:52 var
```
> Remember: `/run/overlayfs` is a symbolic link to the real disk `/run/initramfs/overlayfs/*`.

<a name="layering---upperdir-and-lowerdirs"></a>
##### Layering - Upperdir and Lowerdir(s)

The file-system the user is working on is really two layered file-systems (overlays).
- The lower layer is the SquashFS image itself, read-only, which provides all that we need to run.
- The upper layer is the OverlayFS, read-write, which does a bit-wise `xor` with the lower-layer
- Anything in the upper-layer takes precedence by default.

> There are fancier options for overlays, such as multiple lower-layers, copy-up (lower-layer precedence),
>  and opaque (removing a directory in the upper layer hides it in the lower layer). You can read more [here|https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html#inode-properties]

<a name="layering-real-world-example"></a>
##### Layering Real World Example

Let us take `/root` for example, we can see in the upper-dir (the overlay) we have these files:

The upper-dir has these files:
```bash
ncn-m001# ls -l /run/overlayfs/root/
total 4
-rw------- 1 root root 252 Nov  4 18:23 .bash_history
drwxr-x--- 4 root root  37 Nov  4 04:35 .kube
drwx------ 2 root root  29 Oct 21 21:57 .ssh
```
Then in the squashFS image (lower-dir) we have these...
```bash
ncn-m001# ls -l /run/rootfsbase/root/
total 1
-rw------- 1 root root   0 Oct 19 15:31 .bash_history
drwxr-xr-x 2 root root   3 May 25  2018 bin
drwx------ 3 root root  26 Oct 21 22:07 .cache
drwx------ 2 root root   3 May 25  2018 .gnupg
drwxr-xr-x 4 root root  57 Oct 19 15:23 inst-sys
drwxr-xr-x 2 root root  33 Oct 19 15:33 .kbd
drwxr-xr-x 5 root root  53 Oct 19 15:34 spire
drwx------ 2 root root  70 Oct 21 21:57 .ssh
-rw-r--r-- 1 root root 172 Oct 26 15:25 .wget-hsts
```

- Notice how the `.bash_history` file in the lower-dir is `0` bytes, but it is `252` bytes in the upperdir?
- Notice the `.kube` dir exists in the upper, but not the lower?

Finally, looking at `/root` we see the magic:
```bash
ncn-m001# ls -l /root
total 5
-rw------- 1 root root 252 Nov  4 18:23 .bash_history
drwxr-xr-x 2 root root   3 May 25  2018 bin
drwx------ 3 root root  26 Oct 21 22:07 .cache
drwx------ 2 root root   3 May 25  2018 .gnupg
drwxr-xr-x 4 root root  57 Oct 19 15:23 inst-sys
drwxr-xr-x 2 root root  33 Oct 19 15:33 .kbd
drwxr-x--- 4 root root  37 Nov  4 04:35 .kube
drwxr-xr-x 5 root root  53 Oct 19 15:34 spire
drwx------ 1 root root  29 Oct 21 21:57 .ssh
-rw-r--r-- 1 root root 172 Oct 26 15:25 .wget-hsts
```
- Notice how `.bash_history` matches the upper-dir?
- Notice how `.kube` exists here?

The take-away here is: any change done to `/root/` will persist through `/run/overlayfs/root` and will take precedence to the squashFS image root.

<a name="overlayfs-control"></a>
## OverlayFS Control

These features or toggles are passable on the kernel command line, and change the behavior of the overlayFS.

<a name="reset-toggles"></a>
### Reset Toggles

The overlay FS provides a few reset toggles to clear out the persistence directories without reinstall.

**The toggles require rebooting.**

<a name="reset-on-next-boot"></a>
#### Reset On Next Boot

The preferred way to reset persistent storage is to use the overlayFS reset toggle.

Modify the boot command line on the PXE server, adding this

```bash
# Reset the overlay on boot
rd.live.overlay.reset=1
```

Once reset, you may want to enable persistence again. Simply revert your change and the next reboot
will persist.

```bash
# Cease resetting the overlayFS
rd.live.overlay.reset=0
```

<a name="reset-on-every-boot"></a>
#### Reset on Every Boot

There are two options one can leave enabled to accomplish this:

1. `rd.live.overlay.reset=1` will eradicate/recreate the overlay every reboot.
2. `rd.live.overlayr.readonly=1` will clear the overlay on every reboot.

For long-term usage, `rd.live.overlay.readonly=1` should be added to the command line.

The `reset=1` toggle is usually used to fix a side-ways overlay, if you want to completely refresh 
and purge the overlay then  `rd.live.overlay.reset` is your friend.


```
# Authorize METAL to purge
metal.no-wipe=0 rd.live.overlay.reset=1
```

> Note: `metal.no-wipe=1` does not protect against `rd.live.overlay.reset`, `metal.no-wipe` is not
> a feature of dmsquash-live.

<a name="re-sizing-the-persistent-overlay"></a>
### Re-sizing the Persistent Overlay

- Default Size: 300 GiB
- File System: XFS

The overlay can be resized to fit a variety of needs or use cases. The size is provided directly
on the command line. Any value can be provided, but it must be in *megabytes*.

If you are resetting the overlay on a deployed node, you will need to also set `rd.live.overlay.reset=1`.

It is recommended to set the size before deployment. There is a linkage between the metal-dracut module and the
live-module that makes this inflexible.

```bash
# Use a 300 GiB overlayFS (default)
rd.live.overlay.size=307200

# Use a 1 TiB overlayFS
rd.live.overlay.size=1000000
``` 

<a name="thin-overlay-feature"></a>
### Thin Overlay Feature

The persistent overlayFS leverages newer, "thin" overlays that support discards and that will
free blocks that are not claimed by the file system. This means that memory is free/released
when the filesystem does not claim it anymore.

Thin overlays can be disabled, and instead classic DM Snapshots can be used to manage the overlay. This
will use more RAM. It is not recommended, since dmraid is not included in the initrd.

```shell script
# Enable (default)
rd.live.overlay.thin=1

# Disable (not recommended; undesirable RAM waste)
rd.live.overlay.thin=0
```

<a name="systemd-metalfs"></a>
## SystemD MetalFS

The `metalfs` systemd service will try to mount any metal created partitions.

This runs against the `/run/initramfs/overlayfs/fstab.metal` when it exists. This file is dynamically created by most metal dracut modules.

The service will continuously attempt to mount the partitions, if problems arise please stop the service:

```bash
ncn# systemctl stop metalfs
```

<a name="oldretired-fs-labels"></a>
# Old/Retired FS-Labels

Deprecated FS labels/partitions from Shasta 1.3.X (no longer in Shasta 1.4.0 and onwards).

| FS Label | Partitions | Nodes	| Device | Size on Disk | Work Order | Memo
| --- | --- | ---| --- | --- | --- | --- |
| `K8SKUBE` | `/var/lib/kubelet` | ncn-w001, ncn-w002 | Ephemeral | Max/Remainder | [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) [CASMPET-342](https://connect.us.cray.com/jira/browse/CASMPET-342) | No longer mounted/used in shasta-1.4 |
| `K8SEPH` | `/var/lib/cray/k8s_ephemeral` | ncn-w001, ncn-w002 | Ephemeral | Max/Remainder | [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) [CASMPET-342](https://connect.us.cray.com/jira/browse/CASMPET-342) | No longer mounted/used in shasta-1.4 |
| `CRAYINSTALL` | `/var/cray/vfat` | ncn-w001, ncn-w002 | Ephemeral | `12 GiB` |  [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) [CASMPET-342](https://connect.us.cray.com/jira/browse/CASMPET-342) | No longer mounted/used in shasta-1.4 |
| `CRAYVBIS` | `/var/cray/vbis` | ncn-w001, ncn-w002 | Ephemeral | `900 GiB` |  [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) [CASMPET-342](https://connect.us.cray.com/jira/browse/CASMPET-342) | No longer mounted/used in shasta-1.4 |
| `CRAYNFS` | `/var/lib/nfsroot/nmd` | ncn-w001, ncn-w002 | Ephemeral | `12 GiB` |  [CASMPET-338](https://connect.us.cray.com/jira/browse/CASMPET-338) [CASMPET-342](https://connect.us.cray.com/jira/browse/CASMPET-342) | No longer mounted/used in shasta-1.4 |