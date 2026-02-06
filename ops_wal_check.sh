#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
OUT="/media/sf_vm-share/ops_wal_check_$TS.txt"

echo "OPS WAL CHECK — READ ONLY" > "$OUT"
echo "TS: $TS" >> "$OUT"
echo >> "$OUT"

# 1. Active PVC list (reference)
echo "== Active PVC (SSOT reference) ==" >> "$OUT"
cat /opt/ssot/state/active_pvc.list >> "$OUT" || echo "Cannot read active_pvc.list" >> "$OUT"
echo >> "$OUT"

# 2. Find PGDATA mounts inside pods (kubelet)
echo "== PGDATA / pg_wal locations (host view) ==" >> "$OUT"
if [ -d /var/lib/kubelet/pods ]; then
  find /var/lib/kubelet/pods -type d -name pg_wal 2>/dev/null | while read -r d; do
    echo "pg_wal: $d" >> "$OUT"
    du -sh "$d" 2>/dev/null >> "$OUT" || true
  done
else
  echo "kubelet path not found" >> "$OUT"
fi
echo >> "$OUT"

# 3. Disk usage around kubelet
echo "== kubelet disk usage ==" >> "$OUT"
du -sh /var/lib/kubelet 2>/dev/null >> "$OUT" || true
echo >> "$OUT"

# 4. Top WAL directories by size
echo "== Top WAL directories ==" >> "$OUT"
find /var/lib/kubelet -type d -name pg_wal -exec du -sh {} \; 2>/dev/null | sort -hr >> "$OUT" || true

echo
echo "OK: OPS WAL check written to $OUT"
