#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=70
OUT="/media/sf_vm-share/ops_wal_alert_last.txt"

echo "OPS WAL ALERT CHECK $(date)" > "$OUT"
echo >> "$OUT"

find /var/lib/kubelet/pods -type d -name pg_wal 2>/dev/null | while read -r d; do
  USED=$(df -P "$d" | awk 'NR==2 {print $5}' | tr -d '%')
  SIZE=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
  if [ "$USED" -ge "$THRESHOLD" ]; then
    echo "ALERT: $d usage=${USED}% size=$SIZE" >> "$OUT"
  else
    echo "OK: $d usage=${USED}% size=$SIZE" >> "$OUT"
  fi
done

echo
echo "RESULT WRITTEN TO $OUT"
