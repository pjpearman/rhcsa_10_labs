#!/usr/bin/env bash
#
# RHCSA Essential Tools - Practice Set 2 Validator
# Usage  : Run as root on the target system (for Task 4.1, run on node4).
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

check "1.1 /root/servername.txt exists and contains 'ServerName'" \
  bash -c '[ -s /root/servername.txt ] && grep -q "ServerName" /root/servername.txt'

check "1.2 /archives/logs_bkp.tar.bz2 is a valid bzip2 tar of /var/log" \
  bash -c '
    [ -f /archives/logs_bkp.tar.bz2 ] || exit 1
    file -b --mime-type /archives/logs_bkp.tar.bz2 | grep -q bzip2 || exit 1
    tar -tjf /archives/logs_bkp.tar.bz2 >/dev/null 2>&1
  '

#################################
# Task 2: Links in /links
#################################

check "2.1 alpha.txt exists in /links" \
  test -f /links/alpha.txt

check "2.1 beta.txt is a symlink to alpha.txt" \
  bash -c '
    [ -L /links/beta.txt ] || exit 1
    [ "$(readlink -f /links/beta.txt)" = "$(readlink -f /links/alpha.txt)" ]
  '

check "2.1 gamma.txt is a hard link to alpha.txt (same inode)" \
  bash -c '
    [ -f /links/gamma.txt ] || exit 1
    [ "$(stat -c "%i" /links/gamma.txt)" = "$(stat -c "%i" /links/alpha.txt)" ]
  '

###############################################
# Task 3: Advanced find/copy operations
###############################################

check "3.1 /binfiles has at least one file > 500KB" \
  bash -c '
    [ -d /binfiles ] || exit 1
    find /binfiles -type f -size +500k | grep -q .
  '

check "3.2 /var/tmp/recent contains files modified in last 7 days" \
  bash -c '
    [ -d /var/tmp/recent ] || exit 1
    find /var/tmp/recent -type f -mtime -7 | grep -q .
  '

check "3.3 /operatorfiles has at least one file owned by user operator" \
  bash -c '
    id operator &>/dev/null || exit 1
    [ -d /operatorfiles ] || exit 1
    find /operatorfiles -type f -user operator | grep -q .
  '

check "3.4 /root/hosts-paths.txt has valid absolute paths to hosts files" \
  bash -c '
    [ -s /root/hosts-paths.txt ] || exit 1
    while IFS= read -r p; do
      [ -n "$p" ] || exit 1
      [[ "$p" = /*hosts ]] || exit 1
      [ -f "$p" ] || exit 1
    done < /root/hosts-paths.txt
  '

###########################################
# Task 4: Remote copy result on node4
###########################################

check "4.1 /tmp/hosts is root-owned and not writable by group/others" \
  bash -c '
    [ -f /tmp/hosts ] || exit 1
    [ "$(stat -c "%U:%G" /tmp/hosts)" = "root:root" ] || exit 1
    perms=$(stat -c "%A" /tmp/hosts)
    # group write at index 5, others write at index 8 (0-based)
    [ "${perms:5:1}" != "w" ] && [ "${perms:8:1}" != "w" ]
  '

echo
echo "Total score (Set 2): $score / $max"
