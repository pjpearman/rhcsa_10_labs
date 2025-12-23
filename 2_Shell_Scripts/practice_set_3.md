# RHCSA Practice Set #3 — Shell Scripts (Advanced)

prereqs:
- Work on node1 as root.
- Use `/root` for scripts and output files.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Robust Size Search

1.1 Create `/root/size_find3.sh` that:

- Searches `/usr` for regular files >1MB and <5MB
- Excludes paths matching: `/usr/lib/debug/*` and `/usr/share/doc/*`
- Produces `/root/sized_files3.csv` as: `size_bytes,mtime_epoch,full_path`
- Sorts by `size_bytes` ascending

---

## Task 2: Multi-arg Logic and Strict Validation

2.1 Create `/root/insultme3.sh` that supports:

- `./insultme3.sh --who me|them|we` (required)
- Optional `--upper` to uppercase the output
- Invalid flags or values print a usage line to stderr and exit 2

Expected output lines:
- `me` prints: `Maybe this job isn't for you.`
- `them` prints: `Without you, they are nothing.`
- `we` prints: `We automate the boring stuff.`

---

## Task 3: Provisioning with Cleanup and Safety

3.1 Create `/root/user_model3.txt` formatted:

```text
user:uid:primary_group:secondary_group1,secondary_group2
```

3.2 Use this model:

```text
vera:4010:sys_admins:sec,audit
omar:4020:sys_admins:audit
li:4030:db_admins:sec
```

3.3 Create `/root/provision3.sh` that:

- Reads `/root/user_model3.txt`
- Ensures groups exist
- Ensures users exist with specified UID and primary group
- Applies secondary groups
- Sets passwords to `Password@1`
- Writes a machine-readable report to `/root/provision3_report.json`
- Report contains `created_users[]`
- Report contains `updated_users[]`
- Report contains `created_groups[]`
- Is idempotent and refuses to modify any existing user whose UID does not match the model (print error, exit 3)

## Validate

Run `validate_set_3.sh` as root from `/root` on node1.
