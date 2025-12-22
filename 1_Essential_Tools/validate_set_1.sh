#!/usr/bin/env bash
#
# RHCSA Essential Tools - Practice Set 1 Validator
# Usage  : Run as root on node1; Task 4.1 checks run on node2 over SSH.
# Scoring: 1 point per check; prints per-check status and total score.

score=0
max=10

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

check "1.1 /root/ssh.txt exists and contains 'Port'" \
  bash -c '[ -s /root/ssh.txt ] && grep -q "Port" /root/ssh.txt'

check "1.2 /root/etc_archive.tar.gz is a valid gzip tar of /etc" \
  bash -c '
    [ -f /root/etc_archive.tar.gz ] || exit 1
    file -b --mime-type /root/etc_archive.tar.gz | grep -q gzip || exit 1
    tar -tzf /root/etc_archive.tar.gz >/dev/null 2>&1
  '

#################################
# Task 2: Links in /shorts
#################################

check "2.1 file_a exists in /shorts" \
  test -f /shorts/file_a

check "2.1 file_a contains expected text" \
  bash -c 'grep -qx "This is file A" /shorts/file_a'

check "2.1 file_b is a symlink to file_a" \
  bash -c '
    [ -L /shorts/file_b ] || exit 1
    [ "$(readlink -f /shorts/file_b)" = "$(readlink -f /shorts/file_a)" ]
  '

check "2.1 file_c is a hard link to file_a (same inode)" \
  bash -c '
    [ -f /shorts/file_c ] || exit 1
    [ "$(stat -c "%i" /shorts/file_c)" = "$(stat -c "%i" /shorts/file_a)" ]
  '

###############################################
# Task 3: Advanced find/copy operations
###############################################

check "3.1 /largefiles has at least one file between 3MB and 10MB" \
  bash -c '
    [ -d /largefiles ] || exit 1
    find /largefiles -type f -size +3M -a -size -10M | grep -q .
  '

check "3.2 /var/tmp/oldfiles contains files older than 120 days" \
  bash -c '
    [ -d /var/tmp/oldfiles ] || exit 1
    find /var/tmp/oldfiles -type f -mtime +120 | grep -q .
  '

check "3.3 /largefiles contains at least one file owned by user student" \
  bash -c '
    id student &>/dev/null || exit 1
    [ -d /largefiles ] || exit 1
    find /largefiles -maxdepth 1 -type f -user student | grep -q .
  '

check "3.4 /root/sshd-paths.txt has valid absolute paths to sshd_config" \
  bash -c '
    [ -s /root/sshd-paths.txt ] || exit 1
    while IFS= read -r p; do
      [ -n "$p" ] || exit 1
      [[ "$p" = /*sshd_config ]] || exit 1
      [ -f "$p" ] || exit 1
    done < /root/sshd-paths.txt
  '

###########################################
# Task 4: Remote copy result on node2
###########################################

check "4.1 /var/tmp/fstab on node2 is root-owned and non-executable" \
  bash -c '
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no student@node2 \
      "test -f /var/tmp/fstab && \
       [ \"\$(stat -c \"%U:%G\" /var/tmp/fstab)\" = \"root:root\" ] && \
       perms=\$(stat -c \"%A\" /var/tmp/fstab) && \
       [[ \"\$perms\" != *x* ]]"'

echo
echo "Total score (Set 1): $score / $max"
