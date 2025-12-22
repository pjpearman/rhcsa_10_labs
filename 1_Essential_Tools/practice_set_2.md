# RHCSA EX200 Exam Objective: Understand and Use Essential Tools – Practice Set 2

## Task 1: Text Search & Archive – Man Pages

1.1 Find the string "ServerName" in /etc/httpd/conf/httpd.conf and output it to /root/servername.txt

1.2 Create a bzip2-compressed tar archive of /var/log named logs_bkp.tar.bz2 in /archives directory

- use man pages to locate bzip2 option

---

## Task 2: File Links – Shortcuts

2.1 In /links directory:

- Create a file alpha.txt
- Create soft link beta.txt pointing to alpha.txt
- Create hard link gamma.txt pointing to alpha.txt
- Confirm all links reflect changes to original file

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /bin that are larger than 500KB and copy them to /binfiles directory

3.2 Find files under /var modified within the last 7 days and copy them to /var/tmp/recent/

3.3 Find all files owned by user operator and copy them to /operatorfiles

3.4 Find files named hosts on the system and save the absolute paths to /root/hosts-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node3, SSH into node4 as user devadmin and:

- Copy /etc/hosts to /tmp
- Change owner to root:root
- Remove write permissions for group and others