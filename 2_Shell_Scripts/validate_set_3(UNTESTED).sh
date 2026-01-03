#!/usr/bin/env bash
# validate_set3.sh
# Checks: exclusions+CSV sort, flag parsing, idempotent provisioning + JSON report existence.

set -euo pipefail
score=0
max=15

pass(){ echo "PASS: $*"; }
fail(){ echo "FAIL: $*"; }

echo "== Set 3 Validation =="

# Task 1
if [[ -x /root/size_find3.sh ]]; then
  /root/size_find3.sh >/dev/null 2>&1 || true
  if [[ -f /root/sized_files3.csv ]]; then
    bad=0
    prev=-1
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      IFS=',' read -r size mtime path <<<"$line"
      [[ "$size" =~ ^[0-9]+$ && "$mtime" =~ ^[0-9]+$ && -n "${path:-}" ]] || { bad=1; break; }
      [[ -f "$path" ]] || { bad=1; break; }
      [[ "$path" != /usr/lib/debug/* && "$path" != /usr/share/doc/* ]] || { bad=1; break; }
      (( size > 1048576 && size < 5242880 )) || { bad=1; break; }
      (( prev <= size )) || { bad=1; break; }
      prev=$size
    done < /root/sized_files3.csv
    if (( bad == 0 )); then pass "Task1"; score=$((score+5)); else fail "Task1 (format/exclusions/sort/size)"; fi
  else
    fail "Task1 (/root/sized_files3.csv missing)"
  fi
else
  fail "Task1 (/root/size_find3.sh missing or not executable)"
fi

# Task 2
if [[ -x /root/insultme3.sh ]]; then
  set +e
  out_me=$(/root/insultme3.sh --who me 2>/dev/null); rc_me=$?
  out_them=$(/root/insultme3.sh --who them 2>/dev/null); rc_them=$?
  out_we=$(/root/insultme3.sh --who we 2>/dev/null); rc_we=$?
  outU=$(/root/insultme3.sh --who we --upper 2>/dev/null); rcU=$?
  err=$(/root/insultme3.sh --who nope 2>&1 >/dev/null); rcE=$?
  set -e

  ok=1
  [[ "$out_me" == "Maybe this job isn't for you." && $rc_me -eq 0 ]] || ok=0
  [[ "$out_them" == "Without you, they are nothing." && $rc_them -eq 0 ]] || ok=0
  [[ "$out_we" == "We automate the boring stuff." && $rc_we -eq 0 ]] || ok=0
  [[ "$outU" == "WE AUTOMATE THE BORING STUFF." && $rcU -eq 0 ]] || ok=0
  [[ $rcE -eq 2 && "$err" == Usage:* ]] || ok=0

  if (( ok )); then pass "Task2"; score=$((score+5)); else fail "Task2 (flag parsing/upper/usage/exit)"; fi
else
  fail "Task2 (/root/insultme3.sh missing or not executable)"
fi

# Task 3
need_groups=(sys_admins db_admins sec audit)
need_users=(vera omar li)

if [[ -f /root/user_model3.txt && -x /root/provision3.sh ]]; then
  /root/provision3.sh >/dev/null 2>&1 || true

  g_ok=1; for g in "${need_groups[@]}"; do getent group "$g" >/dev/null || g_ok=0; done
  u_ok=1; for u in "${need_users[@]}";  do getent passwd "$u" >/dev/null || u_ok=0; done

  uid_ok=1
  [[ "$(id -u vera 2>/dev/null || echo X)" == "4010" ]] || uid_ok=0
  [[ "$(id -u omar 2>/dev/null || echo X)" == "4020" ]] || uid_ok=0
  [[ "$(id -u li   2>/dev/null || echo X)" == "4030" ]] || uid_ok=0

  # Secondary groups check (must contain expected)
  grp_ok=1
  id vera | grep -qE '\bsec\b' || grp_ok=0
  id vera | grep -qE '\baudit\b' || grp_ok=0
  id omar | grep -qE '\baudit\b' || grp_ok=0
  id li   | grep -qE '\bsec\b' || grp_ok=0

  pw_ok=1
  for u in "${need_users[@]}"; do
    st=$(passwd -S "$u" 2>/dev/null | awk '{print $2}')
    [[ "$st" == "P" ]] || pw_ok=0
  done

  json_ok=0
  [[ -f /root/provision3_report.json ]] && json_ok=1

  if (( g_ok && u_ok && uid_ok && grp_ok && pw_ok && json_ok )); then pass "Task3"; score=$((score+5)); else fail "Task3 (users/groups/uids/secondary/password/json)"; fi
else
  fail "Task3 (model and/or /root/provision3.sh missing)"
fi

echo "== Score: $score / $max =="
exit $(( max - score == 0 ? 0 : 1 ))
