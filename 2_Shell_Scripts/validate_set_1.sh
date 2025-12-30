#!/usr/bin/env bash
# validate_set_1.sh
# Checks: size_find output, simple_conditional.sh outputs, users/groups exist and have passwords set.

set -euo pipefail

score=0
max=10

pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; }

echo "== Set 1 Validation =="

# --- Task 1 ---
if [[ -x /root/size_find.sh ]]; then
  /root/size_find.sh >/dev/null 2>&1 || true
  if [[ -f /root/sized_files.txt ]]; then
    # Validate every listed path is a file and within size bounds
    bad=0
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      if [[ ! -f "$p" ]]; then bad=1; break; fi
      sz=$(stat -c %s "$p")
      # 30KB < sz < 50KB (KB=1024 bytes)
      if (( sz <= 30720 || sz >= 51200 )); then bad=1; break; fi
    done < /root/sized_files.txt

    if (( bad == 0 )); then pass "Task1"; score=$((score+3)); else fail "Task1 (bad paths/sizes)"; fi
  else
    fail "Task1 (/root/sized_files.txt missing)"
  fi
else
  fail "Task1 (/root/size_find.sh missing or not executable)"
fi

# --- Task 2 ---
if [[ -x /root/simple_conditional.sh ]]; then
  out_date=$(/root/simple_conditional.sh date 2>/dev/null || true)
  out_shell=$(/root/simple_conditional.sh shell 2>/dev/null || true)
  out_bad=$(/root/simple_conditional.sh nope 2>/dev/null || true)
  out_none=$(/root/simple_conditional.sh 2>/dev/null || true)

  prefix_date="The system date is: "
  if [[ "$out_date" == "$prefix_date"* ]]; then
    got_date="${out_date#"$prefix_date"}"
    d0="$(date)"
    d1="$(date -d '1 second ago')"
    d2="$(date -d '1 second')"
    [[ "$got_date" == "$d0" || "$got_date" == "$d1" || "$got_date" == "$d2" ]] && ok1=1 || ok1=0
  else
    ok1=0
  fi

  prefix_shell="The user's shell is: "
  expected_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  [[ "$out_shell" == "${prefix_shell}${expected_shell}" ]] && ok2=1 || ok2=0

  [[ "$out_bad" == "Usage: ./simple_conditional date|shell" ]] && ok3=1 || ok3=0
  [[ "$out_none" == "Usage: ./simple_conditional date|shell" ]] && ok4=1 || ok4=0

  if (( ok1 && ok2 && ok3 && ok4 )); then pass "Task2"; score=$((score+3)); else fail "Task2 (outputs wrong)"; fi
else
  fail "Task2 (/root/simple_conditional.sh missing or not executable)"
fi

# --- Task 3 ---
need_groups=(sys_admins db_admins)
need_users=(carter kenny mika)

g_ok=1
for g in "${need_groups[@]}"; do getent group "$g" >/dev/null || g_ok=0; done

u_ok=1
for u in "${need_users[@]}"; do getent passwd "$u" >/dev/null || u_ok=0; done

# Validate UIDs
uid_ok=1
[[ "$(id -u carter 2>/dev/null || echo X)" == "2030" ]] || uid_ok=0
[[ "$(id -u kenny  2>/dev/null || echo X)" == "2040" ]] || uid_ok=0
[[ "$(id -u mika   2>/dev/null || echo X)" == "2050" ]] || uid_ok=0

# Validate password is set (not locked/empty)
pw_ok=1
for u in "${need_users[@]}"; do
  st=$(passwd -S "$u" 2>/dev/null | awk '{print $2}')
  [[ "$st" == "P" ]] || pw_ok=0
done

if (( g_ok && u_ok && uid_ok && pw_ok )); then pass "Task3"; score=$((score+4)); else fail "Task3 (users/groups/uids/password state)"; fi

echo "== Score: $score / $max =="
exit $(( max - score == 0 ? 0 : 1 ))
