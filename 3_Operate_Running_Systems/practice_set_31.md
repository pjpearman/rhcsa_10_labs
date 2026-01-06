# RHCSA Practice Set #31 - Operate Running Systems (Beginner)

prereqs:
- Work on node1 as root.
- Use `/root` for files created in this set.
- Ensure user `student` exists on node1 and node2 with password `password`.
- Console access to node2 is available for the root password reset task.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Reset Root

1.1 On node2, run 'openssl rand -base64 15 | passwd --stdin root'.

1.2 Reboot node2 and recover the root password. 

1.3 Reboot node2 and confirm root login works with the new password.

Validation for Task 1 is not automated.

---

## Task 2: Using Tuned and SELinux Familiarity

2.1 Set the tuned profile to `balanced` on node1.

2.2 Set SELinux to permissive and make the change persistent across reboots.

2.3 Enable and start `cockpit` so it starts at boot. NOTE: Firewall changes are not required for this task, but cockpit will not be remotely accessible. Firewall tasks are covered later. 

---

## Task 3: Persistent Journaling

3.1 Configure journald for persistent storage.

3.2 Save any 20 journal lines from the current boot to `/root/journal31.txt`.
    Hint: `journalctl -b -n 20 --no-pager > /root/journal31.txt`

---

## Task 4: Process Management

4.1 Start `sleep 1000` in the background.

4.2 Use `renice` to change the process niceness to `10`. Save sleep's pid to /root/sleep31.pid

4.3 Terminate the process and confirm it is no longer running.

---

## Task 5: Work with File Permissions and ACLs

5.1 Create directory `/root/perm31` with files `owned31.txt` and `script31.sh`.

5.2 Change ownership of `owned31.txt` to `student:student`.

5.3 Set `script31.sh` permissions to 750.

5.4 Use ACLs to grant user `student` read and execute access to `script31.sh`.

5.5 Save `getfacl` output for `script31.sh` to `/root/perm31/acl31.txt`.

---

## Task 6: Secure File Transfer

6.1 As user `student` on node1, use secure copy `/etc/hosts` to student's home directoy on node2 with filename `hosts.node1`.

## Validate

Run `validate_set31.sh` as root from `/root` on node1.
