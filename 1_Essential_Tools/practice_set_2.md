# RHCSA Practice Set #2 — Understand and Use Essential Tools (Intermediate)

prereqs:
- Create user 'student'. Set student passwd to 'password' on node1 & node2.
- Permission 'student' with sudo.
- Create some files that are owned by student.

```bash
sudo useradd student
echo 'student:password' | sudo chpasswd
echo 'student ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/student >/dev/null
sudo chmod 0440 /etc/sudoers.d/student
```

```bash
sudo -u student mkdir -p /home/student/lab2_files
sudo -u student touch /home/student/lab2_files/file_{1..5}
```

User 'student'. Create all directories in /home/student.
Task validation assumes the working directory is /home/student.
Use `~/` as `/home/student`.

## Task 1: Text Search & Archive – Man Pages

1.1 Find the string "PASS_MAX_DAYS" in /etc/login.defs and output it (with line numbers) to ~/pass_max.txt

1.2 Create a bzip2-compressed tar archive of /var/log named logs_bkp.tar.bz2 in ~/archives directory

- use man pages to locate bzip2 option and consider using `-C` to avoid absolute paths

---

## Task 2: File Links – Shortcuts

2.1 In ~/links2 directory:

- Create a file alpha.txt and add text to it
- Create soft link beta.txt pointing to alpha.txt
- Create hard link gamma.txt pointing to alpha.txt
- Use `ls -li` to confirm inode relationships

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /usr/bin that are larger than 1MB but smaller than 5MB and copy them to ~/binpick

3.2 Find files under /etc modified within the last 30 days and copy them to ~/etc_recent/

3.3 Find all files owned by user student under /home/student and copy them to ~/ownedfiles

- Use `cp --preserve=timestamps` for 3.1 and 3.2
- Use `cp --preserve=ownership` for 3.3

3.4 Find files named ssh_config on the system and save the absolute paths to ~/ssh_config-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node1, SSH into node2 as user student and:

- Copy /etc/hosts to ~/hosts.remote
- Change owner to root:root
- Set permissions to 640 (rw-r-----)

## Validate

Run validate_set_2.sh as root from /home/student on node1.
