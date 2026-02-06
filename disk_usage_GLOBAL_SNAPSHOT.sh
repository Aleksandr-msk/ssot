#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
SNAPSHOT="disk_usage_global_$TS"
TMP="/tmp/$SNAPSHOT"
OUT="/media/sf_vm-share/$SNAPSHOT.tar.gz"

ROOT="/"

mkdir -p "$TMP"

df -h > "$TMP/00_df_h.txt"

du -xh --max-depth=1 "$ROOT" 2>/dev/null | sort -hr > "$TMP/01_root_top_dirs.txt"

for d in \
  /var/lib/docker \
  /var/lib/containerd \
  /var/lib/kubelet \
  /var/log \
  /tmp \
  /var/tmp \
  /media \
  /mnt \
  /opt
do
  if [ -d "$d" ]; then
    du -sh "$d" 2>/dev/null > "$TMP/02_$(echo "$d" | sed 's|/|_|g').txt"
  fi
done

find "$ROOT" -xdev -type f -size +100M -exec du -h {} \; 2>/dev/null \
  | sort -hr | head -n 200 > "$TMP/03_top_large_files.txt"

tar -czf "$OUT" -C /tmp "$SNAPSHOT"

echo "$OUT"
