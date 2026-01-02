#!/usr/bin/env bash
# validate_set_2.sh
# Checks: size_find2 sorting/errors, simple_conditional2 exit/output, provisioning from model file.

set -euo pipefail
score=0
max=12

STUDENT="student"
BASE="/home/${STUDENT}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this validator with sudo." >&2
  exit 1
fi

pass(){ echo "PASS: $*"; }
fail(){ echo "FAIL: $*"; }

echo "== Set 2 Validation =="

# Task 1
if [[ -x "${BASE}/size_find2.sh" ]]; then
  "${BASE}/size_find2.sh" >/dev/null 2>&1 || true
  if [[ -f "${BASE}/sized_files2.txt" && -f "${BASE}/sized_files2.err" ]]; then
    # ensure sorted unique
    if diff -q "${BASE}/sized_files2.txt" <(sort -u "${BASE}/sized_files2.txt") >/dev/null; then
      bad=0
      while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        [[ -f "$p" ]] || { bad=1; break; }
        sz=$(stat -c %s "$p")
        (( sz > 102400 && sz < 307200 )) || { bad=1; break; }
      done < "${BASE}/sized_files2.txt"
      if (( bad == 0 )); then pass "Task1"; score=$((score+4)); else fail "Task1 (bad sizes/paths)"; fi
    else
      fail "Task1 (not sort -u)"
    fi
  else
    fail "Task1 (missing output/error files)"
  fi
else
  fail "Task1 (${BASE}/size_find2.sh missing or not executable)"
fi

# Task 2
if [[ -x "${BASE}/simple_conditional2.sh" ]]; then
  set +e
  out_date=$("${BASE}/simple_conditional2.sh" date 2>/dev/null); rc_date=$?
  out_uptime=$("${BASE}/simple_conditional2.sh" uptime 2>/dev/null); rc_uptime=$?
  out_release=$("${BASE}/simple_conditional2.sh" release 2>/dev/null); rc_release=$?
  out_bad=$("${BASE}/simple_conditional2.sh" nope 2>&1); rc_bad=$?
  out_none=$("${BASE}/simple_conditional2.sh" 2>&1); rc_none=$?
  set -e

  ok=1
  prefix_date="The system date is: "
  if [[ "$out_date" == "$prefix_date"* && $rc_date -eq 0 ]]; then
    got_date="${out_date#"$prefix_date"}"
    d0="$(date)"
    d1="$(date -d '1 second ago')"
    d2="$(date -d '1 second')"
    norm_got="$(printf '%s' "$got_date" | tr -s ' ')"
    norm_d0="$(printf '%s' "$d0" | tr -s ' ')"
    norm_d1="$(printf '%s' "$d1" | tr -s ' ')"
    norm_d2="$(printf '%s' "$d2" | tr -s ' ')"
    [[ "$norm_got" == "$norm_d0" || "$norm_got" == "$norm_d1" || "$norm_got" == "$norm_d2" ]] || ok=0
  else
    ok=0
  fi

  prefix_uptime="The system uptime is: "
  expected_uptime="$(uptime -p)"
  [[ "$out_uptime" == "${prefix_uptime}${expected_uptime}" && $rc_uptime -eq 0 ]] || ok=0

  prefix_release="The redhat release is: "
  expected_release="$(cat /etc/redhat-release)"
  [[ "$out_release" == "${prefix_release}${expected_release}" && $rc_release -eq 0 ]] || ok=0

  [[ "$out_bad" == "Usage: ./simple_conditional2 date|uptime|release" ]] || ok=0
  [[ "$out_none" == "Usage: ./simple_conditional2 date|uptime|release" ]] || ok=0

  if (( ok )); then pass "Task2"; score=$((score+4)); else fail "Task2 (usage/output wrong)"; fi
else
  fail "Task2 (${BASE}/simple_conditional2.sh missing or not executable)"
fi

# Task 3
need_groups=(sys_admins db_admins)
need_users=(ruth sam nina)

if [[ -f "${BASE}/user_model.txt" && -x "${BASE}/provision_users.sh" ]]; then
  "${BASE}/provision_users.sh" >/dev/null 2>&1 || true

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

  if (( g_ok && u_ok && uid_ok && pw_ok )); then pass "Task3"; score=$((score+4)); else fail "Task3 (idempotency artifacts/users/groups/password)"; fi
else
  fail "Task3 (model file and/or script missing)"
fi

echo "== Score: $score / $max =="
exit $(( max - score == 0 ? 0 : 1 ))
