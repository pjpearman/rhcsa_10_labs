#!/usr/bin/env bash
# validate_set1.sh
# Checks: size_find output, insultme.sh outputs, users/groups exist and have passwords set.

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
if [[ -x /root/insultme.sh ]]; then
  out1=$(/root/insultme.sh me 2>/dev/null || true)
  out2=$(/root/insultme.sh them 2>/dev/null || true)
  out3=$(/root/insultme.sh 2>/dev/null || true)

  [[ "$out1" == "Maybe this job isn't for you." ]] && ok1=1 || ok1=0
  [[ "$out2" == "Without you, they are nothing." ]] && ok2=1 || ok2=0
  [[ "$out3" == "Usage: ./insultme.sh me|them" ]] && ok3=1 || ok3=0

  if (( ok1 && ok2 && ok3 )); then pass "Task2"; score=$((score+3)); else fail "Task2 (outputs wrong)"; fi
else
  fail "Task2 (/root/insultme.sh missing or not executable)"
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
