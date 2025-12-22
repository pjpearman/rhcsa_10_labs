## RHCSA Practice Set #1 — Understand and Use Essential Tools

prereqs:
- Create user 'student'. Set student passwd to 'password' on node1 & node2.
- Permission 'student' with sudo.
 
```bash
sudo useradd student
echo 'student:password' | sudo chpasswd
echo 'student ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/student >/dev/null
sudo chmod 0440 /etc/sudoers.d/student
```

## Task 1: Text Search & Archive – Man Pages

1.1 Find the string "Port" in /etc/ssh/sshd_config and output to /root/ssh.txt

1.2 Create a gzip-compressed tar archive of /etc named etc_archive.tar.gz in /root directory

- reference 'man grep' or 'grep --help'

---

## Task 2: File Links – Shortcuts

2.1 In /shorts directory:

- Create a file file_a
- echo 'This is file A' into file_a
- Create soft link file_b pointing to file_a
- Create hard link file_c pointing to file_a
- Verify all links work

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /usr that are greater than 3MB but less than 10MB, copy them to /largefiles directory

3.2 Find files in /etc modified more than 120 days ago and copy them to /var/tmp/oldfiles/

3.3 Find all files owned by user student and copy them to /largefiles

3.4 Find a file named sshd_config and save the absolute path to /root/sshd-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node1, SSH into node2 as user student and:

- Copy the contents of /etc/fstab to /var/tmp
- Set the file ownership to root
- Ensure no execute permissions for anyone
