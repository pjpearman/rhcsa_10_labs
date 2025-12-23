# RHCSA Practice Set #1 — Shell Scripts (Beginner)

prereqs:
- Work on node1 as root.
- Use `/root` for scripts and output files.

Task validation assumes the working directory is /root.
Use `~/` as `/root`.

## Task 1: Size-based File Search

1.1 Create `/root/size_find.sh` that:

- Finds regular files under `/usr` with size >30KB and <50KB
- Writes the full paths to `/root/sized_files.txt` (overwrite)

---

## Task 2: Conditional Argument Script

2.1 Create `/root/insultme.sh` that:

- `./insult.sh me` prints: `Maybe this job isn't for you.`
- `./insult.sh them` prints: `Without you, they are nothing.`
- Anything else or missing prints: `Usage: ./career.sh me|them`

---

## Task 3: Users, Groups, and Passwords

3.1 From this model list, create groups/users accordingly (primary group first, secondary group optional):

- `carter:2030:sys_admins,db_admins`
- `kenny:2040:sys_admins`
- `mika:2050:db_admins`

3.2 Set passwords for carter, kenny, mika to `Password@1`.

## Validate

Run `validate_set_1.sh` as root from `/root` on node1.
