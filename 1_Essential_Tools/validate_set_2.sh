#!/usr/bin/env bash
#
# RHCSA Essential Tools - Practice Set 2 Validator
# Usage  : Run as root on the target system (for Task 4.1, run on node2).
# Scoring: 1 point per check; prints per-check status and total score.

score=0
max=9

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

check "1.1 /home/student/pass_max.txt exists and contains 'PASS_MAX_DAYS'" \
  bash -c '[ -s /home/student/pass_max.txt ] && grep -q "PASS_MAX_DAYS" /home/student/pass_max.txt'

check "1.2 /home/student/archives/logs_bkp.tar.bz2 is a valid bzip2 tar of /var/log" \
  bash -c '
    [ -f /home/student/archives/logs_bkp.tar.bz2 ] || exit 1
    file -b --mime-type /home/student/archives/logs_bkp.tar.bz2 | grep -q bzip2 || exit 1
    tar -tjf /home/student/archives/logs_bkp.tar.bz2 >/dev/null 2>&1
  '

#################################
# Task 2: Links in /links
#################################

check "2.1 alpha.txt exists in /home/student/links2" \
  test -f /home/student/links2/alpha.txt

check "2.1 beta.txt is a symlink to alpha.txt" \
  bash -c '
    [ -L /home/student/links2/beta.txt ] || exit 1
    [ "$(readlink -f /home/student/links2/beta.txt)" = "$(readlink -f /home/student/links2/alpha.txt)" ]
  '

check "2.1 gamma.txt is a hard link to alpha.txt (same inode)" \
  bash -c '
    [ -f /home/student/links2/gamma.txt ] || exit 1
    [ "$(stat -c "%i" /home/student/links2/gamma.txt)" = "$(stat -c "%i" /home/student/links2/alpha.txt)" ]
  '

###############################################
# Task 3: Advanced find/copy operations
###############################################

check "3.1 /home/student/binpick has at least one file between 1MB and 5MB" \
  bash -c '
    [ -d /home/student/binpick ] || exit 1
    find /home/student/binpick -type f -size +1M -size -5M | grep -q .
  '

check "3.2 /home/student/etc_recent contains files modified in last 30 days" \
  bash -c '
    [ -d /home/student/etc_recent ] || exit 1
    find /home/student/etc_recent -type f -mtime -30 | grep -q .
  '

check "3.3 /home/student/ownedfiles has at least one file owned by user student" \
  bash -c '
    id student &>/dev/null || exit 1
    [ -d /home/student/ownedfiles ] || exit 1
    find /home/student/ownedfiles -type f -user student | grep -q .
  '

check "3.4 /home/student/ssh_config-paths.txt has valid absolute paths to ssh_config files" \
  bash -c '
    [ -s /home/student/ssh_config-paths.txt ] || exit 1
    while IFS= read -r p; do
      [ -n "$p" ] || exit 1
      [[ "$p" = /*ssh_config ]] || exit 1
      [ -f "$p" ] || exit 1
    done < /home/student/ssh_config-paths.txt
  '

###########################################
# Task 4: Remote copy result on node4
###########################################

check "4.1 /home/student/hosts.remote is root-owned and has 640 permissions" \
  bash -c '
    [ -f /home/student/hosts.remote ] || exit 1
    [ "$(stat -c "%U:%G" /home/student/hosts.remote)" = "root:root" ] || exit 1
    [ "$(stat -c "%a" /home/student/hosts.remote)" = "640" ]
  '

echo
echo "Total score (Set 2): $score / $max"
