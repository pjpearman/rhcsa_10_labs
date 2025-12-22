# RHCSA Practice Set #3 — Understand and Use Essential Tools (Advanced)

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
sudo -u student mkdir -p /home/student/adv_files
sudo -u student touch /home/student/adv_files/empty_{1..3}
sudo -u student touch /home/student/adv_files/data_{1..3}
```

User 'student' should generally be used to complete tasks. Use 'sudo', as needed.
Task validation assumes the working directory is /home/student.
Use `~/` as `/home/student`.

## Task 1: Text Search & Archive – Man Pages

1.1 Use grep to find lines that start with "PASS_" in /etc/login.defs and save the output (with line numbers) to ~/login_pass.txt

1.2 Create a gzip-compressed tar archive of /etc named syscfg.tar.gz in ~/archives and exclude /etc/shadow

- use man pages to identify the exclude option

---

## Task 2: File Links – Shortcuts

2.1 In ~/ref3 directory:

- Create a file datafile1
- Create soft link datafile2 → datafile1 using a relative path
- Create hard link datafile3 → datafile1
- Validate inode relationships for each link and confirm datafile2 points to "datafile1"

---

## Task 3: Advanced File Operations – Find

3.1 Find files in /usr/bin that are larger than 2MB but smaller than 8MB and are world-executable; copy them to ~/binadv

3.2 Find files under /etc ending with .conf modified more than 60 days ago and copy them to ~/etc_oldconf/

3.3 Find empty files under /home/student and copy them to ~/emptyfiles

- Use `cp --preserve=timestamps` for 3.1 and 3.2
- Use `cp --preserve=mode,ownership` for 3.3

3.4 Find files named fstab anywhere on the system and save full paths to ~/fstab-paths.txt

---

## Task 4: Remote Access & File Permissions

4.1 From node1, SSH into node2 as user student and:

- Copy /etc/ssh/sshd_config to ~/sshd.remote
- Set ownership to root:root
- Set permissions to 600 (rw-------)

## Validate

Run validate_set_3.sh as root from /home/student on node1.
