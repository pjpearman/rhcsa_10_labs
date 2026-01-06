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
# Task 1: Reset Root (Scoring unavailable)
###########################################

echo "[INFO] 1.x SCORING UNAVAILABLE"

###########################################
# Task 2: Tuned and SELinux
###########################################

check "2.1 tuned active profile is balanced" \
  bash -c 'tuned-adm active 2>/dev/null | grep -q "balanced"'

check "2.2 SELinux is permissive now and persistent" \
  bash -c '[ "$(getenforce)" = "Permissive" ] && grep -Eq "^SELINUX=permissive" /etc/selinux/config'

check "2.3 cockpit.socket is enabled and active" \
  bash -c 'systemctl is-enabled cockpit.socket >/dev/null 2>&1 && systemctl is-active cockpit.socket >/dev/null 2>&1'

###########################################
# Task 3: Persistent Journaling
###########################################

check "3.1 /var/log/journal exists" \
  test -d /var/log/journal

check "3.1 /var/log/journal has .journal files" \
  bash -c 'shopt -s nullglob; files=(/var/log/journal/*/*.journal); (( ${#files[@]} > 0 ))'

check "3.2 systemd-journald is active" \
  bash -c 'systemctl is-active systemd-journald >/dev/null 2>&1'

check "3.3 /root/journal31.txt contains 20 current-boot journal lines" \
  bash -c '[ "$(wc -l < /root/journal31.txt 2>/dev/null)" -eq 20 ] && \
    journalctl -b --no-pager 2>/dev/null | tail -n 200 | \
    grep -Fx -f /root/journal31.txt >/dev/null'

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

check "5.3 script31.sh permissions are 750" \
  bash -c '[ "$(stat -c "%a" /root/perm31/script31.sh 2>/dev/null)" = "750" ]'

check "5.4 ACL grants student r-x on script31.sh" \
  bash -c 'getfacl -p /root/perm31/script31.sh 2>/dev/null | grep -q "^user:student:r-x"'

check "5.5 acl31.txt matches getfacl output" \
  bash -c 'diff -q <(getfacl -p /root/perm31/script31.sh 2>/dev/null | sed "/^# file:/d") \
    <(sed "/^# file:/d" /root/perm31/acl31.txt 2>/dev/null) >/dev/null'

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

echo
echo "Total score (Set 31): $score / $max"
