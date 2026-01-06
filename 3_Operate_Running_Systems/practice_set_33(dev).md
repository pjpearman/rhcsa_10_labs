# RHCSA Practice Set #33 - Operate Running Systems (Advanced)

prereqs:
- Work on node1 as root.
- Use `/root` for files created in this set.
- Ensure user `student` exists on node1 and node2 with password `password`.
- Console access to node2 is available for the root password reset task.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Reset Root

1.1 On node2, change the root password to `TempLock33` and lock the account.

1.2 Recover by using GRUB `rd.break` to set the root password to `RootReset33`.

1.3 Ensure SELinux relabels on next boot and confirm `passwd -S root` shows the account is unlocked.

1.4 Save `last -1 root` output to `/root/rootreset33.txt` on node2.

---

## Task 2: Using Tuned and SELinux Familiarity

2.1 Create a custom tuned profile `rhcsa33` under `/etc/tuned/rhcsa33/tuned.conf` that includes `balanced` and sets `vm.swappiness=10`.

2.2 Activate the profile and save `tuned-adm active` output to `/root/tuned33.txt`.

2.3 Set SELinux to enforcing, persist it across reboot, and save `sestatus` output to `/root/selinux33.txt`.

2.4 Enable and start `firewalld` so it starts at boot.

---

## Task 3: Persistent Journaling

3.1 Create `/etc/systemd/journald.conf.d/99-rhcsa33.conf` with:

- `Storage=persistent`
- `SystemMaxUse=100M`
- `MaxRetentionSec=1week`

3.2 Restart `systemd-journald` and save `journalctl --disk-usage` output to `/root/journal33_usage.txt`.

3.3 Reboot node1 and save `journalctl -b -1 -n 3` output to `/root/journal33_prev.txt`.

---

## Task 4: Process Management

4.1 Start `yes > /dev/null` and `sleep 1200` in the background.

4.2 Set the `yes` process niceness to `12` and the `sleep` process niceness to `-5`.

4.3 Save `ps -o pid,ni,cmd` output for both processes to `/root/proc33.txt`.

4.4 Kill the `yes` process with `SIGKILL`, then stop `sleep` with `SIGTERM`.

---

## Task 5: Work with File Permissions and ACLs

5.1 Create `/root/perm33` with files `data33.txt` and `exec33.sh`.

5.2 Change ownership of `data33.txt` to `student:student`.

5.3 Set `exec33.sh` permissions to `750` (owner/group read/write/execute).

5.4 Set a default ACL on `/root/perm33` granting user `student` read and execute access.

5.5 Use ACLs to grant user `student` read access to `data33.txt` and save `getfacl` output to `/root/perm33/acl33.txt`.

---

## Task 6: Secure File Transfer

6.1 As user `student` on node1, create `~/transfer33/subdir` with two files.

6.2 Use `scp -p -r` to copy `~/transfer33` to `student@node2:/home/student/transfer33`.

6.3 From node2, copy the directory back to node1 as `/root/transfer33.node2`.

## Validate

Run `validate_set33.sh` as root from `/root` on node1.
