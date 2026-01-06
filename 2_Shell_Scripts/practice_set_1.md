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

2.1 Create `/root/simple_conditional.sh` that:

- `./simple_conditional.sh date` prints: `The system date is: <display system date and time>`
- `./simple_conditional.sh shell` prints: `The user's shell is: <display the users shell>`
- Anything else or missing prints: `Usage: ./simple_conditional date|shell`

  Hint: to return date, set DATE=$(date) to expand the variable. 
---

## Task 3: Users, Groups, and Passwords. Make use of 'if, then, else, while, do'.

3.1 From this model list, use a bash script called `add_users.sh` to create groups/users accordingly. The group in field 3 is a secondary group.

- `carter:2030:sys_admins`
- `kenny:2040:sys_admins`
- `mika:2050:db_admins`

  Hint: 'cut' 'sort' commands to work with fields.

3.2 Set passwords for carter, kenny, mika to `Password@1`.

---

## Validate

Run `validate_set_1.sh` as root from `/root` on node1.
