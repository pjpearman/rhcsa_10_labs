# RHCSA Practice Set #2 — Shell Scripts (Intermediate)

prereqs:
- Work on node1 as user `student`.
- Use `/home/student` for scripts and output files.

Task validation assumes the working directory is /home/student.
Use `~/` as `/home/student`.

## Task 1: Size Search with Formatting and Errors

1.1 Create `/home/student/size_find2.sh` that:

- Finds regular files under `/usr` with >100KB and <300KB
- Outputs a sorted unique list to `/home/student/sized_files2.txt`
- Sends permission errors to `/home/student/sized_files2.err`

---

## Task 2: Conditional Script with Case and Exit Codes

2.1 Create `/home/student/simple_conditional2.sh` that:

- Accepts exactly one argument: `date|uptime|release`
- `date` prints: `The system date is: <display system date and time>`
- `uptime` prints: `The system uptime is: <display the uptime -p output>`
- `release` prints: `The redhat release is: <display the redhat-release of the system>`
- Invalid usage prints: `Usage: ./simple_conditional2 date|uptime|release`

---

## Task 3: Users and Groups from a File

3.1 Create `/home/student/user_model.txt` with:

```text
ruth:3010:sys_admins
sam:3020:sys_admins
nina:3030:db_admins
```

3.2 Write `/home/student/provision_users.sh` that:

- Reads that file
- Creates missing groups/users (idempotent)
- Sets passwords for those users to `Password@1`
- Logs actions to `/home/student/provision_users.log`
- Run this script using `sudo`

## Validate

Run `sudo validate_set_2.sh` from `/home/student` on node1.
