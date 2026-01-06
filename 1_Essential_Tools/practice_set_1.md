## RHCSA 10 Practice Set #1 — Understand and Use Essential Tools

## Key Tasks: 
    - Access a shell prompt and issue commands with correct syntax
    - Use input-output redirection (>, >>, |, 2>, etc.)
    - Use grep and regular expressions to analyze text
    - Access remote systems using SSH
    - Log in and switch users in multiuser targets
    - Archive, compress, unpack, and uncompress files using tar, gzip, and bzip2
    - Create and edit text files
    - Create, delete, copy, and move files and directories
    - Create hard and soft links
    - List, set, and change standard ugo/rwx permissions
    - Locate, read, and use system documentation including man, info, and files in /usr/share/doc

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
sudo -u student touch /home/student/task3_1 /home/student/task3_2 /home/student/task3_3 /home/student/task3_4 /home/student/task3_5
```

User 'student'. Create all directories in /home/student.
Task validation assumes the working directory is /home/student.

## Task 1: Text Search & Archive – Man Pages

1.1 Find the string "Port" in /etc/ssh/sshd_config and output to ~/ssh.txt

1.2 Create a gzip-compressed tar archive of /etc named etc_archive.tar.gz in ~/

- reference 'man grep' or 'grep --help'

---

## Task 2: File Links – Shortcuts

2.1 In ~/shorts directory:

- Create a file file_a
- echo 'This is file A' into file_a
- Create soft link file_b pointing to file_a
- Create hard link file_c pointing to file_a
- Verify all links work

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /usr that are greater than 3MB but less than 10MB, copy them to ~/largefiles directory

3.2 Find files in /etc modified more than 120 days ago and copy them to ~/oldfiles/

- Use `cp -p` or `cp --preserve=timestamps` so the copied files keep their original mtime (validation checks rely on this).

3.3 Find all files owned by user student and copy them to ~/largefiles

- Use `cp -a` or `cp --preserve=ownership` so the copied files keep student ownership (validation checks rely on this).

3.4 Find a file named sshd_config and save the absolute path to ~/sshd-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node1, SSH into node2 as user student and:

- Copy the contents of /etc/fstab to ~/fstab
- Set the file ownership to root
- Ensure no execute permissions for anyone

## Validate

Run validate_set_1.sh as root from /home/student on node1.
