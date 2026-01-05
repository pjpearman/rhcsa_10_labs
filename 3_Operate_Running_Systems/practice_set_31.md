# RHCSA Practice Set #31 - Operate Running Systems (Beginner)

prereqs:
- Work on node1 as root.
- Use `/root` for files created in this set.
- Ensure user `student` exists on node1 and node2 with password `password`.
- Console access to node2 is available for the root password reset task.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Reset Root

1.1 On node2, reset the root password to `RootReset31` using the GRUB `init=/bin/bash` method.

1.2 Ensure SELinux relabels on next boot (`touch /.autorelabel`).

1.3 Reboot node2 and confirm root login works with the new password.

Validation for Task 1 is not automated.

---

## Task 2: Using Tuned and SELinux Familiarity

2.1 Set the tuned profile to `balanced` on node1.

2.2 Set SELinux to permissive and make the change persistent across reboots.

2.3 Enable and start `chronyd` so it starts at boot.

---

## Task 3: Persistent Journaling

3.1 Configure journald for persistent storage by creating `/var/log/journal` and setting `Storage=persistent`.

3.2 Restart `systemd-journald`.

3.3 Save the last 20 lines of the current boot journal to `/root/journal31.txt`.

---

## Task 4: Process Management

4.1 Start `sleep 1000` in the background and save its PID to `/root/sleep31.pid`.

4.2 Use `renice` to change the process niceness to `10`.

4.3 Terminate the process and confirm it is no longer running.

---

## Task 5: Work with File Permissions and ACLs

5.1 Create `/root/perm31` with files `owned31.txt` and `script31.sh`.

5.2 Change ownership of `owned31.txt` to `student:student`.

5.3 Set `script31.sh` permissions to `700` (owner read/write/execute only).

5.4 Use ACLs to grant user `student` read and execute access to `script31.sh`.

5.5 Save `getfacl` output for `script31.sh` to `/root/perm31/acl31.txt`.

---

## Task 6: Secure File Transfer

6.1 As user `student` on node1, use `scp` to copy `/etc/hosts` to `student@node2:/home/student/hosts.node1`.

6.2 From node2 as user `student`, copy that file back to node1 as `/home/student/hosts.node2`.

6.3 On node1, move `/home/student/hosts.node2` to `/root/hosts.node2`.

## Validate

Run `validate_set31.sh` as root from `/root` on node1.
