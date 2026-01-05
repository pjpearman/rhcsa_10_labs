#!/usr/bin/env bash
#
# RHCSA Operate Running Systems - Practice Set 31 Validator
# Usage  : Run as root on node1 from /root.
# Scoring: 1 point per check; prints per-check status and total score.

score=0
max=15

check() {
  local desc="$1"; shift
  if "$@"; then
    printf '[OK]   %s\n' "$desc"
    score=$((score+1))
  else
    printf '[FAIL] %s\n' "$desc"
  fi
}

###########################################
# Task 1: Reset Root (Not automated)
###########################################

echo "[INFO] 1.x VALIDATION NOT AUTOMATED"

###########################################
# Task 2: Tuned and SELinux
###########################################

check "2.1 tuned active profile is balanced" \
  bash -c 'tuned-adm active 2>/dev/null | grep -q "balanced"'

check "2.2 SELinux is permissive now and persistent" \
  bash -c '[ "$(getenforce)" = "Permissive" ] && grep -Eq "^SELINUX=permissive" /etc/selinux/config'

check "2.3 chronyd is enabled and active" \
  bash -c 'systemctl is-enabled chronyd >/dev/null 2>&1 && systemctl is-active chronyd >/dev/null 2>&1'

###########################################
# Task 3: Persistent Journaling
###########################################

check "3.1 /var/log/journal exists" \
  test -d /var/log/journal

check "3.1 Storage=persistent set in journald config" \
  bash -c '
    shopt -s nullglob
    files=(/etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf)
    grep -Eq "^\s*Storage\s*=\s*persistent" "${files[@]}"
  '

check "3.2 systemd-journald is active" \
  bash -c 'systemctl is-active systemd-journald >/dev/null 2>&1'

check "3.3 /root/journal31.txt matches last 20 lines of current boot" \
  bash -c 'cmp -s <(journalctl -b -n 20 --no-pager 2>/dev/null) /root/journal31.txt'

###########################################
# Task 4: Process Management
###########################################

check "4.1 /root/sleep31.pid contains a numeric PID" \
  bash -c '[ -s /root/sleep31.pid ] && pid=$(cat /root/sleep31.pid) && [[ "$pid" =~ ^[0-9]+$ ]]'

check "4.2 sleep 1000 process niceness is 10" \
  bash -c '\
    [ -s /root/sleep31.pid ] || exit 1\n\
    pid=$(cat /root/sleep31.pid)\n\
    [ "$(ps -o ni= -p "$pid" 2>/dev/null | tr -d " ")" = "10" ]\n\
  '

check "4.3 sleep 1000 process from PID file is not running" \
  bash -c '
    [ -s /root/sleep31.pid ] || exit 1
    pid=$(cat /root/sleep31.pid)
    ! ps -p "$pid" -o comm= 2>/dev/null | grep -qx "sleep"
  '

###########################################
# Task 5: Permissions and ACLs
###########################################

check "5.2 owned31.txt is student:student" \
  bash -c '[ "$(stat -c "%U:%G" /root/perm31/owned31.txt 2>/dev/null)" = "student:student" ]'

check "5.3 script31.sh permissions are 700" \
  bash -c '[ "$(stat -c "%a" /root/perm31/script31.sh 2>/dev/null)" = "700" ]'

check "5.4 ACL grants student rx on script31.sh" \
  bash -c 'getfacl -p /root/perm31/script31.sh 2>/dev/null | grep -q "^user:student:rx"'

check "5.5 acl31.txt matches getfacl output" \
  bash -c 'getfacl -p /root/perm31/script31.sh 2>/dev/null | diff -q - /root/perm31/acl31.txt >/dev/null'

###########################################
# Task 6: Secure File Transfer
###########################################

check "6.1 /home/student/hosts.node1 on node2 matches /etc/hosts on node1" \
  bash -c '
    local_sum=$(sha256sum /etc/hosts | awk "{print \$1}")
    remote_sum=$(ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no student@node2 \
      "sha256sum /home/student/hosts.node1 2>/dev/null" | awk "{print \$1}")
    [ -n "$remote_sum" ] && [ "$local_sum" = "$remote_sum" ]
  '

check "6.2 /root/hosts.node2 matches /etc/hosts on node1" \
  bash -c 'cmp -s /root/hosts.node2 /etc/hosts'

echo
echo "Total score (Set 31): $score / $max"
