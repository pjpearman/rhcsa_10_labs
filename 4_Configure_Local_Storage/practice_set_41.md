# RHCSA 10 Practice Set #41 - Configure Local Storage (Beginner)

prereqs:
- Work on node1 as root.
- Add two new virtual disks (2-4 GiB each) to node1. Assume they appear as `/dev/sdb` and `/dev/sdc` and are empty.
- Node2 is reachable for NFS. If no export exists, create `/exports/rhcsa41` on node2 and allow node1 access.
- Use `/root` for files created in this set.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: GPT Partitioning Practice

1.1 Ensure `/dev/sdb` and `/dev/sdc` use GPT partition tables.

1.2 Create the following partitions:

- `/dev/sdb1` 300 MiB (for VFAT)
- `/dev/sdb2` 600 MiB (for ext4)
- `/dev/sdb3` remainder (for LVM)
- `/dev/sdc1` 1 GiB (for LVM)
- `/dev/sdc2` 512 MiB (for swap)
- `/dev/sdc3` 100 MiB (temporary; use it to practice PV create/remove and then delete the partition)

---

## Task 2: VFAT and ext4 Filesystems

2.1 Format `/dev/sdb1` as VFAT with label `BOOT41`. Mount it at `/mnt/vfat41` and create `/mnt/vfat41/hello41.txt`.

2.2 Format `/dev/sdb2` as ext4 with label `EXT41`. Mount it at `/mnt/ext41` and create `/mnt/ext41/data41.txt`.

2.3 Unmount and remount both filesystems to confirm clean mount/unmount behavior.

---

## Task 3: LVM Setup Using Extents

3.1 Initialize `/dev/sdb3` and `/dev/sdc1` as physical volumes and create volume group `vg41` with 8 MiB extents.

3.2 Create logical volume `lvxfs41` using exactly 64 extents. Format it as XFS, mount at `/mnt/xfs41`, and create `/mnt/xfs41/xfs41.txt`.

3.3 Create logical volume `lvtemp41` using 8 extents. Format it as ext4 and mount it at `/mnt/temp41` to verify. Then remove `lvtemp41` and clean up the mount.

---

## Task 4: New LV and Swap (Non-Destructive)

4.1 Create logical volume `lvdata41` using 32 extents in `vg41`. Format it as ext4 and mount at `/srv/data41`.

4.2 Initialize `/dev/sdc2` as swap, enable it, and ensure it persists across reboots.

---

## Task 5: Extend an Existing LV (Extents)

5.1 Extend `lvxfs41` by 16 extents and grow the XFS filesystem.

---

## Task 6: Persistent Mounts by UUID or Label

6.1 Configure `/etc/fstab` so that:

- VFAT uses the `BOOT41` label.
- ext4 and XFS mounts use UUIDs.
- Swap uses a UUID.

6.2 Verify the configuration is valid and all filesystems mount cleanly.

---

## Task 7: NFS Mount/Unmount

7.1 Mount `node2:/exports/rhcsa41` at `/mnt/nfs41`, create `/mnt/nfs41/nfs41.txt`, then unmount it.

---

## Task 8: Configure autofs

8.1 Configure autofs to mount `node2:/exports/rhcsa41` on demand at `/net/auto41` with key `share`.

8.2 Access `/net/auto41/share` to confirm the automount works.

---

## Task 9: Diagnose and Correct Permissions

9.1 Ensure directory `/srv/data41/report41` is owned by `root:storage`, has the setgid bit, is group-writable, and is not world-accessible.

9.2 Confirm user `student` (member of `storage`) can create files there, while users outside the group cannot read it.

## Validate

Run `validateset_41.sh` as root from `/root` on node1.
