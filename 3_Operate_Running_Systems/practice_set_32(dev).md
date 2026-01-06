# RHCSA Practice Set #32 - Operate Running Systems (Intermediate)

prereqs:
- Work on node1 as user `student` (use `sudo` when needed).
- Use `/home/student` for files created in this set.
- Ensure console access to node2 for the root password reset task.

Task validation assumes the working directory is /home/student.
Use `~/` as `/home/student`.

## Task 1: Reset Root

1.1 On node2, lock the root account (`passwd -l root`).

1.2 Recover by using GRUB `rd.break` to set the root password to `RootReset32`.

1.3 Ensure SELinux relabels on next boot and confirm root login works.

---

## Task 2: Using Tuned and SELinux Familiarity

2.1 Set the tuned profile to `throughput-performance` and save `tuned-adm active` output to `~/tuned32.txt`.

2.2 Set SELinux to enforcing and make it persistent; save `getenforce` output to `~/selinux32.txt`.

2.3 Enable and start `crond` so it starts at boot; save `systemctl is-enabled crond` output to `~/crond32.txt`.

---

## Task 3: Persistent Journaling

3.1 Create `/etc/systemd/journald.conf.d/99-persistent.conf` with:

- `Storage=persistent`
- `SystemMaxUse=150M`

3.2 Restart `systemd-journald`.

3.3 Reboot node1 and save `journalctl -b -1 -n 5` output to `~/journal32.prev`.

---

## Task 4: Process Management

4.1 Start `yes > /dev/null` with `nice -n 15` and start `sleep 900` in the background.

4.2 Use `renice` to set the `sleep` process to niceness `-5`.

4.3 Stop only the `yes` process with `SIGTERM` and confirm `sleep` is still running.

---

## Task 5: Work with File Permissions and ACLs

5.1 Create `~/perm32` with files `report32.txt` and `run32.sh`.

5.2 Change ownership of `report32.txt` to `root:root` and set permissions to `640`.

5.3 Set `run32.sh` permissions to `750` (owner/group read/write/execute).

5.4 Use ACLs to grant user `student` read access to `report32.txt`.

5.5 Set a default ACL on `~/perm32` granting group `student` read access.

5.6 Save `getfacl` output for `~/perm32` and `~/perm32/report32.txt` to `~/perm32/acl32.txt`.

---

## Task 6: Secure File Transfer

6.1 Create `~/transfer32/payload32.txt` with any content.

6.2 Use `scp -p -r` to copy `~/transfer32` to `student@node2:/home/student/transfer32`.

6.3 On node2, rename `payload32.txt` to `payload32.node2`, then copy it back to `~/transfer32/payload32.node2` on node1.

## Validate

Run `validate_set32.sh` as root from `/home/student` on node1.
