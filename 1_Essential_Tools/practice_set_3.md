# RHCSA EX200 Exam Objective: Understand and Use Essential Tools – Practice Set 3

## Task 1: Text Search & Archive – Man Pages

1.1 Search for the string "DocumentRoot" in /etc/httpd/conf/httpd.conf and save the output to /root/docroot.txt

1.2 Create an uncompressed tar archive of /usr/share named share_backup.tar in /backup directory

- use man pages to identify archive mode options

---

## Task 2: File Links – Shortcuts

2.1 In /ref directory:

- Create a file datafile1
- Create soft link datafile2 → datafile1
- Create hard link datafile3 → datafile1
- Validate inode relationships for each link

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /sbin that are larger than 1MB and copy them to /sbinfiles directory

3.2 Find files under /home modified more than 90 days ago and copy them to /var/tmp/oldhome/

3.3 Find all files owned by user apache and copy them to /apachefiles

3.4 Find files named fstab anywhere on the system and save full paths# to /root/fstab-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node5, SSH into node6 as user opsengineer and:

- Copy /etc/passwd to /tmp
- Set ownership to root:root
- Remove read permission for others