# RHCSA Practice Set #2 — Shell Scripts (Intermediate)

prereqs:
- Work on node1 as root.
- Use `/root` for scripts and output files.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Size Search with Formatting and Errors

1.1 Create `/root/size_find2.sh` that:

- Finds regular files under `/usr` with >100KB and <300KB
- Outputs a sorted unique list to `/root/sized_files2.txt`
- Sends permission errors to `/root/sized_files2.err`

---

## Task 2: Conditional Script with Case and Exit Codes

2.1 Create `/root/insultme2.sh` that:

- Accepts exactly one argument: `me|them|we`
- `me` prints: `Maybe this job isn't for you.`
- `them` prints: `Without you, they are nothing.`
- `we` prints: `We automate the boring stuff.`
- Invalid usage prints: `Usage: ./insultme2.sh me|them|we` to stderr and exits 2

---

## Task 3: Users and Groups from a File

3.1 Create `/root/user_model.txt` with:

```text
ruth:3010:sys_admins,db_admins
sam:3020:sys_admins
nina:3030:db_admins
```

3.2 Write `/root/provision_users.sh` that:

- Reads that file
- Creates missing groups/users (idempotent)
- Sets passwords for those users to `Password@1`
- Logs actions to `/root/provision_users.log`

## Validate

Run `validate_set_2.sh` as root from `/root` on node1.
