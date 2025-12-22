#RHCSA 10 PRACTICAL EXERCISES

Prereqs:

- Red Hat Enterprise Linux Server : node1
- Red Hat Enterprise Linux Server : node2
- user 'student' created on node1 and node 1 with sudo.

Create the student user
```bash
sudo useradd student
echo 'student:password' | sudo chpasswd
echo 'student ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/student >/dev/null
sudo chmod 0440 /etc/sudoers.d/student
```
