#!/usr/bin/env bash
#
# RHCSA Operate Running Systems - Practice Set 32 Validator
# Usage  : Run as root on node1 from /home/student.
# Scoring: 1 point per check; prints per-check status and total score.

score=0
max=18

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

check "2.1 tuned profile is throughput-performance" \
  bash -c 'tuned-adm active 2>/dev/null | grep -q "throughput-performance"'

check "2.1 tuned32.txt contains tuned-adm active output" \
  bash -c 'grep -q "throughput-performance" /root/tuned32.txt 2>/dev/null'

check "2.2 SELinux is enforcing now and persistent" \
  bash -c '[ "$(getenforce)" = "Enforcing" ] && grep -Eq "^SELINUX=enforcing" /etc/selinux/config'

check "2.2 selinux32.txt contains Enforcing" \
  bash -c 'grep -qx "Enforcing" /root/selinux32.txt 2>/dev/null'

check "2.3 httpd is enabled and active" \
  bash -c 'systemctl is-enabled httpd >/dev/null 2>&1 && systemctl is-active httpd >/dev/null 2>&1'

check "2.3 httpd.txt reports enabled" \
  bash -c 'grep -qx "enabled" /root/httpd.txt 2>/dev/null'

###########################################
# Task 3: Persistent Journaling
###########################################

check "3.1 journald persistent config file exists" \
  test -f /etc/systemd/journald.conf.d/99-persistent.conf

check "3.1 journald config has required settings" \
  bash -c ' \
    grep -Eq "^[[:space:]]*\\[Journal\\][[:space:]]*$" /etc/systemd/journald.conf.d/99-persistent.conf && \
    grep -Eq "^[[:space:]]*Storage=persistent[[:space:]]*$" /etc/systemd/journald.conf.d/99-persistent.conf && \
    grep -Eq "^[[:space:]]*SystemMaxUse=150M[[:space:]]*$" /etc/systemd/journald.conf.d/99-persistent.conf \
  '

check "3.2 journal32.prev matches last 5 lines of previous boot" \
  bash -c 'cmp -s <(journalctl -b -1 -n 5 --no-pager 2>/dev/null) /root/journal32.prev'

###########################################
# Task 4: Process Management
###########################################

check "4.1 yes.nice has two entries" \
  bash -c '[ "$(wc -l < /root/yes.nice 2>/dev/null)" -eq 2 ]'

check "4.1 yes process initial niceness is 15" \
  bash -c '[ "$(sed -n "1p" /root/yes.nice 2>/dev/null | tr -d " ")" = "15" ]'

check "4.2 yes process reniced to -5" \
  bash -c '[ "$(sed -n "2p" /root/yes.nice 2>/dev/null | tr -d " ")" = "-5" ]'

check "4.3 yes process is not running" \
  bash -c '! pgrep -x yes >/dev/null 2>&1'

###########################################
# Task 5: Permissions and ACLs
###########################################

check "5.1 /root/perm32 exists with report32.txt and run32.sh" \
  bash -c '[ -d /root/perm32 ] && [ -f /root/perm32/report32.txt ] && [ -f /root/perm32/run32.sh ]'

check "5.2 report32.txt owned by root:root with 644 permissions" \
  bash -c '[ "$(stat -c "%U:%G %a" /root/perm32/report32.txt 2>/dev/null)" = "root:root 644" ]'

check "5.3 run32.sh permissions are 750" \
  bash -c '[ "$(stat -c "%a" /root/perm32/run32.sh 2>/dev/null)" = "750" ]'

check "5.4 ACL grants student read on report32.txt" \
  bash -c 'getfacl -p /root/perm32/report32.txt 2>/dev/null | grep -q "^user:student:r--"'

check "5.5 default ACL grants group student read on /root/perm32" \
  bash -c 'getfacl -p /root/perm32 2>/dev/null | grep -q "^default:group:student:r--"'

check "5.6 acl32.txt matches getfacl output for dir and file" \
  bash -c 'diff -q <( \
      { getfacl -p /root/perm32 2>/dev/null; getfacl -p /root/perm32/report32.txt 2>/dev/null; } | \
      sed "/^# file:/d" \
    ) <(sed "/^# file:/d" /root/perm32/acl32.txt 2>/dev/null) >/dev/null'

###########################################
# Task 6: Secure File Transfer
###########################################

check "6.1 payload32.txt exists locally" \
  bash -c '[ -f /root/transfer32/payload32.txt ]'

check "6.2 transfer32 directory exists on node2" \
  bash -c 'ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no student@node2 \
    "test -d /home/student/transfer32"'

check "6.3 payload32.node2 matches node2 copy" \
  bash -c '
    local_sum=$(sha256sum /root/transfer32/payload32.node2 2>/dev/null | awk "{print \$1}")
    remote_sum=$(ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no student@node2 \
      "sha256sum /home/student/transfer32/payload32.node2 2>/dev/null" | awk "{print \$1}")
    [ -n "$local_sum" ] && [ -n "$remote_sum" ] && [ "$local_sum" = "$remote_sum" ]
  '

echo
echo "Total score (Set 32): $score / $max"
