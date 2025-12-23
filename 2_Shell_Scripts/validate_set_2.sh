#!/usr/bin/env bash
# validate_set2.sh
# Checks: size_find2 sorting/errors, insultme2 stderr+exit, provisioning from model file.

set -euo pipefail
score=0
max=12

pass(){ echo "PASS: $*"; }
fail(){ echo "FAIL: $*"; }

echo "== Set 2 Validation =="

# Task 1
if [[ -x /root/size_find2.sh ]]; then
  /root/size_find2.sh >/dev/null 2>&1 || true
  if [[ -f /root/sized_files2.txt && -f /root/sized_files2.err ]]; then
    # ensure sorted unique
    if diff -q /root/sized_files2.txt <(sort -u /root/sized_files2.txt) >/dev/null; then
      bad=0
      while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        [[ -f "$p" ]] || { bad=1; break; }
        sz=$(stat -c %s "$p")
        (( sz > 102400 && sz < 307200 )) || { bad=1; break; }
      done < /root/sized_files2.txt
      if (( bad == 0 )); then pass "Task1"; score=$((score+4)); else fail "Task1 (bad sizes/paths)"; fi
    else
      fail "Task1 (not sort -u)"
    fi
  else
    fail "Task1 (missing output/error files)"
  fi
else
  fail "Task1 (/root/size_find2.sh missing or not executable)"
fi

# Task 2
if [[ -x /root/insultme2.sh ]]; then
  set +e
  out_me=$(/root/insultme2.sh me 2>/dev/null); rc_me=$?
  out_them=$(/root/insultme2.sh them 2>/dev/null); rc_them=$?
  out_we=$(/root/insultme2.sh we 2>/dev/null); rc_we=$?
  err_bad=$(/root/insultme2.sh nope 2>&1 >/dev/null); rc_bad=$?
  set -e

  ok=1
  [[ "$out_me" == "Maybe this job isn't for you." && $rc_me -eq 0 ]] || ok=0
  [[ "$out_them" == "Without you, they are nothing." && $rc_them -eq 0 ]] || ok=0
  [[ "$out_we" == "We automate the boring stuff." && $rc_we -eq 0 ]] || ok=0
  [[ "$err_bad" == "Usage: ./insultme2.sh me|them|we" && $rc_bad -eq 2 ]] || ok=0

  if (( ok )); then pass "Task2"; score=$((score+4)); else fail "Task2 (stderr/exit/output wrong)"; fi
else
  fail "Task2 (/root/insultme2.sh missing or not executable)"
fi

# Task 3
need_groups=(sys_admins db_admins)
need_users=(ruth sam nina)

if [[ -f /root/user_model.txt && -x /root/provision_users.sh ]]; then
  /root/provision_users.sh >/dev/null 2>&1 || true

  g_ok=1; for g in "${need_groups[@]}"; do getent group "$g" >/dev/null || g_ok=0; done
  u_ok=1; for u in "${need_users[@]}";  do getent passwd "$u" >/dev/null || u_ok=0; done

  uid_ok=1
  [[ "$(id -u ruth 2>/dev/null || echo X)" == "3010" ]] || uid_ok=0
  [[ "$(id -u sam  2>/dev/null || echo X)" == "3020" ]] || uid_ok=0
  [[ "$(id -u nina 2>/dev/null || echo X)" == "3030" ]] || uid_ok=0

  pw_ok=1
  for u in "${need_users[@]}"; do
    st=$(passwd -S "$u" 2>/dev/null | awk '{print $2}')
    [[ "$st" == "P" ]] || pw_ok=0
  done

  log_ok=0
  [[ -f /root/provision_users.log ]] && log_ok=1

  if (( g_ok && u_ok && uid_ok && pw_ok && log_ok )); then pass "Task3"; score=$((score+4)); else fail "Task3 (idempotency artifacts/users/groups/password/log)"; fi
else
  fail "Task3 (model file and/or script missing)"
fi

echo "== Score: $score / $max =="
exit $(( max - score == 0 ? 0 : 1 ))
