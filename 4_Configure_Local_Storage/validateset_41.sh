#!/usr/bin/env bash
#
# RHCSA Configure Local Storage - Practice Set 41 Validator (Tasks 1-6)
# Usage  : Run as root on node1 from /root.
# Scoring: 1 point per check; prints per-check status and total score.

DISK1="${DISK1:-}"
DISK2="${DISK2:-}"

score=0
max=36

check() {
  local desc="$1"; shift
  if "$@"; then
    printf '[OK]   %s\n' "$desc"
    score=$((score+1))
  else
    printf '[FAIL] %s\n' "$desc"
  fi
}

size_between() {
  local dev="$1"
  local min="$2"
  local max="$3"
  local size
  size=$(lsblk -b -n -o SIZE "$dev" 2>/dev/null | head -n1)
  [[ -n "$size" && "$size" -ge "$min" && "$size" -le "$max" ]]
}

part_dev() {
  local disk="$1"
  local part="$2"
  if [[ "$disk" =~ [0-9]$ ]]; then
    printf '%sp%s\n' "$disk" "$part"
  else
    printf '%s%s\n' "$disk" "$part"
  fi
}

parent_disk() {
  local dev="$1"
  local parent
  parent=$(lsblk -n -o PKNAME "$dev" 2>/dev/null | head -n1)
  [[ -n "$parent" ]] && printf '/dev/%s\n' "$parent"
}

detect_disk_from_label() {
  local label="$1"
  local dev
  dev=$(blkid -L "$label" 2>/dev/null)
  [[ -n "$dev" ]] || return 1
  parent_disk "$dev"
}

detect_disk_from_swap() {
  local dev
  while read -r dev; do
    size_between "$dev" $((500*1024*1024)) $((524*1024*1024)) || continue
    parent_disk "$dev"
    return 0
  done < <(blkid -t TYPE=swap -o device 2>/dev/null)
  return 1
}

detect_vg_disk() {
  local exclude="$1"
  local pv disk
  while read -r pv; do
    [[ -n "$pv" ]] || continue
    disk=$(parent_disk "$pv")
    [[ -n "$disk" && "$disk" != "$exclude" ]] || continue
    printf '%s\n' "$disk"
    return 0
  done < <(pvs --noheadings -o pv_name --select vg_name=vg41 2>/dev/null | tr -d ' ')
  return 1
}

mount_on_device() {
  local target="$1"
  local dev="$2"
  local source
  source=$(findmnt -n -o SOURCE --target "$target" 2>/dev/null)
  [[ -n "$source" ]] || return 1
  [[ "$(readlink -f "$source")" = "$(readlink -f "$dev")" ]]
}

DEV1=""
DEV2=""
DEV1_SRC=""
DEV2_SRC=""

if [[ -n "$DISK1" ]]; then
  DEV1="/dev/${DISK1}"
  DEV1_SRC="override"
else
  DEV1=$(detect_disk_from_label BOOT41)
  if [[ -n "$DEV1" ]]; then
    DEV1_SRC="auto:BOOT41"
  else
    DEV1="/dev/sdb"
    DEV1_SRC="default"
  fi
fi

if [[ -n "$DISK2" ]]; then
  DEV2="/dev/${DISK2}"
  DEV2_SRC="override"
else
  DEV2=$(detect_disk_from_swap)
  if [[ -n "$DEV2" ]]; then
    DEV2_SRC="auto:swap"
  else
    DEV2=$(detect_vg_disk "$DEV1")
    if [[ -n "$DEV2" ]]; then
      DEV2_SRC="auto:vg41"
    else
      DEV2="/dev/sdc"
      DEV2_SRC="default"
    fi
  fi
fi

if [[ "$DEV1" = "$DEV2" && -z "$DISK2" ]]; then
  DEV2="/dev/sdc"
  DEV2_SRC="default"
fi

DEV1P1=$(part_dev "$DEV1" 1)
DEV1P2=$(part_dev "$DEV1" 2)
DEV1P3=$(part_dev "$DEV1" 3)
DEV2P1=$(part_dev "$DEV2" 1)
DEV2P2=$(part_dev "$DEV2" 2)
DEV2P3=$(part_dev "$DEV2" 3)

printf '[WARN] Using devices %s (%s) and %s (%s) (override with DISK1/DISK2)\n' \
  "$DEV1" "$DEV1_SRC" "$DEV2" "$DEV2_SRC"

###########################################
# Task 1: GPT Partitioning Practice
###########################################

check "1.1 ${DEV1} uses GPT" \
  bash -c "parted -s \"$DEV1\" print 2>/dev/null | grep -q \"Partition Table: gpt\""

check "1.1 ${DEV2} uses GPT" \
  bash -c "parted -s \"$DEV2\" print 2>/dev/null | grep -q \"Partition Table: gpt\""

check "1.2 ${DEV1P1} is ~300 MiB" \
  size_between "$DEV1P1" $((290*1024*1024)) $((310*1024*1024))

check "1.2 ${DEV1P2} is ~600 MiB" \
  size_between "$DEV1P2" $((590*1024*1024)) $((610*1024*1024))

check "1.2 ${DEV1P3} exists and is >900 MiB" \
  size_between "$DEV1P3" $((900*1024*1024)) $((10*1024*1024*1024))

check "1.2 ${DEV2P1} is ~1 GiB" \
  size_between "$DEV2P1" $((990*1024*1024)) $((1030*1024*1024))

check "1.2 ${DEV2P2} is ~512 MiB" \
  size_between "$DEV2P2" $((500*1024*1024)) $((524*1024*1024))

check "1.2 ${DEV2P3} removed" \
  bash -c "! lsblk -n \"$DEV2P3\" >/dev/null 2>&1"

###########################################
# Task 2: VFAT and ext4 Filesystems
###########################################

check "2.1 ${DEV1P1} is VFAT with label BOOT41" \
  bash -c "[ \"\$(blkid -o value -s TYPE \"$DEV1P1\" 2>/dev/null)\" = \"vfat\" ] && \
           [ \"\$(blkid -o value -s LABEL \"$DEV1P1\" 2>/dev/null)\" = \"BOOT41\" ]"

check "2.1 /mnt/vfat41 mounted from ${DEV1P1}" \
  mount_on_device /mnt/vfat41 "$DEV1P1"

check "2.1 /mnt/vfat41/hello41.txt exists" \
  test -f /mnt/vfat41/hello41.txt

check "2.2 ${DEV1P2} is ext4 with label EXT41" \
  bash -c "[ \"\$(blkid -o value -s TYPE \"$DEV1P2\" 2>/dev/null)\" = \"ext4\" ] && \
           [ \"\$(blkid -o value -s LABEL \"$DEV1P2\" 2>/dev/null)\" = \"EXT41\" ]"

check "2.2 /mnt/ext41 mounted from ${DEV1P2}" \
  mount_on_device /mnt/ext41 "$DEV1P2"

check "2.2 /mnt/ext41/data41.txt exists" \
  test -f /mnt/ext41/data41.txt

###########################################
# Task 3: LVM Setup Using Extents
###########################################

check "3.1 ${DEV1P3} is a PV in vg41" \
  bash -c "[ \"\$(pvs --noheadings -o vg_name \"$DEV1P3\" 2>/dev/null | tr -d \" \")\" = \"vg41\" ]"

check "3.1 ${DEV2P1} is a PV in vg41" \
  bash -c "[ \"\$(pvs --noheadings -o vg_name \"$DEV2P1\" 2>/dev/null | tr -d \" \")\" = \"vg41\" ]"

check "3.1 vg41 extent size is 8 MiB" \
  bash -c 'extent=$(vgs --noheadings -o vg_extent_size --units m --nosuffix vg41 2>/dev/null | tr -d " "); \
           awk -v val="$extent" "BEGIN {exit !(val>=7.9 && val<=8.1)}"'

check "3.2 lvxfs41 uses 64 extents" \
  bash -c 'le=$(lvdisplay /dev/vg41/lvxfs41 2>/dev/null | awk "/Current LE/ {print \$3}" | head -n1); \
           [ "$le" = "64" ]'

check "3.2 lvxfs41 is XFS" \
  bash -c '[ "$(blkid -o value -s TYPE /dev/vg41/lvxfs41 2>/dev/null)" = "xfs" ]'

check "3.2 /mnt/xfs41 mounted from lvxfs41" \
  mount_on_device /mnt/xfs41 /dev/vg41/lvxfs41

check "3.2 /mnt/xfs41/xfs41.txt exists" \
  test -f /mnt/xfs41/xfs41.txt

check "3.3 lvtemp41 removed" \
  bash -c '! lvs vg41/lvtemp41 >/dev/null 2>&1'

check "3.3 /mnt/temp41 is not mounted" \
  bash -c '! mountpoint -q /mnt/temp41'

###########################################
# Task 4: New LV and Swap (Non-Destructive)
###########################################

check "4.1 lvdata41 uses 32 extents" \
  bash -c 'le=$(lvdisplay /dev/vg41/lvdata41 2>/dev/null | awk "/Current LE/ {print \$3}" | head -n1); \
           [ "$le" = "32" ]'

check "4.1 lvdata41 is ext4" \
  bash -c '[ "$(blkid -o value -s TYPE /dev/vg41/lvdata41 2>/dev/null)" = "ext4" ]'

check "4.1 /srv/data41 mounted from lvdata41" \
  mount_on_device /srv/data41 /dev/vg41/lvdata41

check "4.2 ${DEV2P2} is swap" \
  bash -c "[ \"\$(blkid -o value -s TYPE \"$DEV2P2\" 2>/dev/null)\" = \"swap\" ]"

check "4.2 ${DEV2P2} swap is active" \
  bash -c "while read -r name; do \
             [ \"\$(readlink -f \"\$name\")\" = \"$DEV2P2\" ] && exit 0; \
           done < <(swapon --show --noheadings | awk '{print \$1}'); exit 1"

check "4.2 swap persists in /etc/fstab" \
  bash -c "uuid=\$(blkid -o value -s UUID \"$DEV2P2\" 2>/dev/null); \
           grep -Eqs \"^[[:space:]]*($DEV2P2|UUID=\${uuid})[[:space:]]+[^[:space:]]+[[:space:]]+swap([[:space:]]|$)\" /etc/fstab"

###########################################
# Task 5: Extend an Existing LV (Extents)
###########################################

check "5.1 lvxfs41 uses 80 extents" \
  bash -c 'le=$(lvdisplay /dev/vg41/lvxfs41 2>/dev/null | awk "/Current LE/ {print \$3}" | head -n1); \
           [ "$le" = "80" ]'

check "5.1 lvxfs41 XFS size reflects the extension" \
  bash -c 'blocks=$(xfs_info /dev/vg41/lvxfs41 2>/dev/null | \
           sed -n "s/.*blocks=\\([0-9]\\+\\).*/\\1/p" | head -n1); \
           [ -n "$blocks" ] && [ "$blocks" -ge 160000 ]'

###########################################
# Task 6: Persistent Mounts by UUID or Label
###########################################

check "6.1 /mnt/vfat41 uses LABEL=BOOT41 in /etc/fstab" \
  bash -c "grep -Eqs '^[[:space:]]*LABEL=BOOT41[[:space:]]+/mnt/vfat41[[:space:]]+vfat([[:space:]]|$)' /etc/fstab"

check "6.1 /mnt/ext41 uses UUID in /etc/fstab" \
  bash -c "grep -Eqs '^[[:space:]]*UUID=[^[:space:]]+[[:space:]]+/mnt/ext41[[:space:]]+ext4([[:space:]]|$)' /etc/fstab"

check "6.1 /srv/data41 uses UUID in /etc/fstab" \
  bash -c "uuid=\$(blkid -o value -s UUID /dev/vg41/lvdata41 2>/dev/null); \
           grep -Eqs \"^[[:space:]]*UUID=\${uuid}[[:space:]]+/srv/data41[[:space:]]+ext4([[:space:]]|$)\" /etc/fstab"

check "6.1 /mnt/xfs41 uses UUID in /etc/fstab" \
  bash -c "uuid=\$(blkid -o value -s UUID /dev/vg41/lvxfs41 2>/dev/null); \
           grep -Eqs \"^[[:space:]]*UUID=\${uuid}[[:space:]]+/mnt/xfs41[[:space:]]+xfs([[:space:]]|$)\" /etc/fstab"

check "6.1 swap uses UUID in /etc/fstab" \
  bash -c "grep -Eqs '^[[:space:]]*UUID=[^[:space:]]+[[:space:]]+(none|swap)[[:space:]]+swap([[:space:]]|$)' /etc/fstab"

echo
echo "Total score (Set 41, Tasks 1-6): $score / $max"
