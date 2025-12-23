# RHCSA 10 Practical Exercises

Hands-on RHCSA-style practice sets with validation scripts.
Largely based on the tasks as performed by Haruna Adoga. https://youtube.com/playlist?list=PLiI_-JOspy6FuSPXSipE0xE4oC2XXYyuI&si=2WT_iQJdeyymMDie 

## Repo layout

- `1_Essential_Tools/` contains practice sets and validators.
- `1_Essential_Tools/practice_set_*.md` are the task instructions.
- `1_Essential_Tools/validate_set_*.sh` are the scoring scripts.

## Clone the repo

```bash
git clone https://github.com/pjpearman/rhcsa_10_labs.git
cd rhcsa_10_labs
```

## Prereqs

- Red Hat Enterprise Linux Server: node1
- Red Hat Enterprise Linux Server: node2
- User `student` exists on node1 and node2 with sudo privileges.
- Password auth works between node1 and node2 for `student` (validators use SSH).

Create the student user (run on both nodes):
```bash
sudo useradd student
echo 'student:password' | sudo chpasswd
echo 'student ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/student >/dev/null
sudo chmod 0440 /etc/sudoers.d/student
```

## Using the task sets

1. Pick a set: `1_Essential_Tools/practice_set_1.md`, `practice_set_2.md`,
   or `practice_set_3.md`.
2. Complete the tasks as user `student` (use `sudo` when needed).
3. Run the corresponding validator as root on node1:

```bash
cd /path/to/rhcsa_10_labs/1_Essential_Tools
sudo ./validate_set_1.sh
sudo ./validate_set_2.sh
sudo ./validate_set_3.sh
```

Each validator prints `[OK]` / `[FAIL]` per check and a total score.

## Validation details

- Validators assume task files live under `/home/student`.
- Some checks run on node2 via SSH; expect a password prompt for `student@node2`.
- If a check fails, fix the task and rerun the validator.

## Versioning

Tagged releases follow SemVer (`vX.Y.Z`). To see the version of your clone:

```bash
git describe --tags --always
```
