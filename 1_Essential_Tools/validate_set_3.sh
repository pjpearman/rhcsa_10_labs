#!/usr/bin/env bash
#
# RHCSA Essential Tools - Practice Set 3 Validator
# Usage  : Run as root on the target system (for Task 4.1, run on node6).
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

check "1.1 /root/docroot.txt exists and contains 'DocumentRoot'" \
  bash -c '[ -s /root/docroot.txt ] && grep -q "DocumentRoot" /root/docroot.txt'

check "1.2 /backup/share_backup.tar is a valid tar archive" \
  bash -c '
    [ -f /backup/share_backup.tar ] || exit 1
    file -b --mime-type /backup/share_backup.tar | grep -qi "x-tar" || exit 1
    tar -tf /backup/share_backup.tar >/dev/null 2>&1
  '

#################################
# Task 2: Links in /ref
#################################

check "2.1 datafile1 exists in /ref" \
  test -f /ref/datafile1

check "2.1 datafile2 is a symlink to datafile1" \
  bash -c '
    [ -L /ref/datafile2 ] || exit 1
    [ "$(readlink -f /ref/datafile2)" = "$(readlink -f /ref/datafile1)" ]
  '

check "2.1 datafile3 is a hard link to datafile1 (same inode)" \
  bash -c '
    [ -f /ref/datafile3 ] || exit 1
    [ "$(stat -c "%i" /ref/datafile3)" = "$(stat -c "%i" /ref/datafile1)" ]
  '

###############################################
# Task 3: Advanced find/copy operations
###############################################

check "3.1 /sbinfiles has at least one file > 1MB" \
  bash -c '
    [ -d /sbinfiles ] || exit 1
    find /sbinfiles -type f -size +1M | grep -q .
  '

check "3.2 /var/tmp/oldhome contains files older than 90 days" \
  bash -c '
    [ -d /var/tmp/oldhome ] || exit 1
    find /var/tmp/oldhome -type f -mtime +90 | grep -q .
  '

check "3.3 /apachefiles has at least one file owned by user apache" \
  bash -c '
    id apache &>/dev/null || exit 1
    [ -d /apachefiles ] || exit 1
    find /apachefiles -type f -user apache | grep -q .
  '

check "3.4 /root/fstab-paths.txt has valid absolute paths to fstab files" \
  bash -c '
    [ -s /root/fstab-paths.txt ] || exit 1
    while IFS= read -r p; do
      [ -n "$p" ] || exit 1
      [[ "$p" = /*fstab ]] || exit 1
      [ -f "$p" ] || exit 1
    done < /root/fstab-paths.txt
  '

###########################################
# Task 4: Remote copy result on node6
###########################################

check "4.1 /tmp/passwd is root-owned and not world-readable" \
  bash -c '
    [ -f /tmp/passwd ] || exit 1
    [ "$(stat -c "%U:%G" /tmp/passwd)" = "root:root" ] || exit 1
    perms=$(stat -c "%A" /tmp/passwd)
    # others read at index 7 (0-based)
    [ "${perms:7:1}" != "r" ]
  '

echo
echo "Total score (Set 3): $score / $max"
