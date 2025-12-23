#!/usr/bin/env bash
#
# RHCSA Essential Tools - Practice Set 3 Validator
# Usage  : Run as root on node1; Task 4.1 checks run on node2 over SSH.
# Scoring: 1 point per check; prints per-check status and total score.

score=0
max=10
home_dir=/home/student

check() {
  local desc="$1"; shift
  if "$@"; then
    printf '[OK]   %s\n' "$desc"
    score=$((score+1))
  else
    printf '[FAIL] %s\n' "$desc"
  fi
}

########################
# Task 1: Text & Archive
########################

check "1.1 /home/student/login_pass.txt exists and contains PASS_ lines" \
  bash -c '[ -s /home/student/login_pass.txt ] && grep -q "PASS_" /home/student/login_pass.txt'

check "1.2 /home/student/archives/syscfg.tar.gz is a valid gzip tar of /etc (excluding shadow)" \
  bash -c '
    [ -f /home/student/archives/syscfg.tar.gz ] || exit 1
    file -b --mime-type /home/student/archives/syscfg.tar.gz | grep -q gzip || exit 1
    tar -tzf /home/student/archives/syscfg.tar.gz >/dev/null 2>&1 || exit 1
    tar -tzf /home/student/archives/syscfg.tar.gz | grep -q "^etc/hosts" || exit 1
    ! tar -tzf /home/student/archives/syscfg.tar.gz | grep -q "^etc/shadow$"
  '

#################################
# Task 2: Links in /ref
#################################

check "2.1 datafile1 exists in /home/student/ref3" \
  test -f /home/student/ref3/datafile1

check "2.1 datafile2 is a relative symlink to datafile1" \
  bash -c '
    [ -L /home/student/ref3/datafile2 ] || exit 1
    [ "$(readlink /home/student/ref3/datafile2)" = "datafile1" ] || exit 1
    [ "$(readlink -f /home/student/ref3/datafile2)" = "$(readlink -f /home/student/ref3/datafile1)" ]
  '

check "2.1 datafile3 is a hard link to datafile1 (same inode)" \
  bash -c '
    [ -f /home/student/ref3/datafile3 ] || exit 1
    [ "$(stat -c "%i" /home/student/ref3/datafile3)" = "$(stat -c "%i" /home/student/ref3/datafile1)" ]
  '

###############################################
# Task 3: Advanced find/copy operations
###############################################

check "3.1 /home/student/binadv has at least one world-executable file between 2MB and 8MB" \
  bash -c '
    [ -d /home/student/binadv ] || exit 1
    find /home/student/binadv -type f -size +2M -size -8M -perm -o=x | grep -q .
  '

check "3.2 /home/student/etc_oldconf contains .conf files older than 60 days" \
  bash -c '
    [ -d /home/student/etc_oldconf ] || exit 1
    find /home/student/etc_oldconf -type f -name "*.conf" -mtime +60 | grep -q .
  '

check "3.3 /home/student/emptyfiles has at least one empty file" \
  bash -c '
    [ -d /home/student/emptyfiles ] || exit 1
    find /home/student/emptyfiles -type f -size 0 | grep -q .
  '

check "3.4 /home/student/fstab-paths.txt has valid absolute paths to fstab files" \
  bash -c '
    [ -s /home/student/fstab-paths.txt ] || exit 1
    while IFS= read -r p; do
      [ -n "$p" ] || exit 1
      [[ "$p" = /*fstab ]] || exit 1
      [ -f "$p" ] || exit 1
    done < /home/student/fstab-paths.txt
  '

###########################################
# Task 4: Remote copy result on node6
###########################################

check "4.1 /home/student/sshd.remote on node2 is root-owned with 600 permissions" \
  bash -c '
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no student@node2 \
      "test -f /home/student/sshd.remote && \
       [ \"\$(stat -c \"%U:%G\" /home/student/sshd.remote)\" = \"root:root\" ] && \
       [ \"\$(stat -c \"%a\" /home/student/sshd.remote)\" = \"600\" ]"
  '

echo
echo "Total score (Set 3): $score / $max"
