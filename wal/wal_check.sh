#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/opt/ssot/state"
OUT_STATE="${STATE_DIR}/wal.status"
LAST_CHECK="${STATE_DIR}/wal.last_check"

THRESHOLD_PCT=70
NAMESPACE="trading"
POD="trading-postgres-0"
DB_USER="trading"
DB_NAME="trading"

mkdir -p "${STATE_DIR}"

WAL_DIR="$(kubectl exec -n "$NAMESPACE" "$POD" -- \
  psql -U "$DB_USER" -d "$DB_NAME" -Atc "show data_directory")/pg_wal"

USED_PCT="$(kubectl exec -n "$NAMESPACE" "$POD" -- \
  df -P "$WAL_DIR" | awk 'NR==2 {print $5}' | tr -d '%')"

SIZE="$(kubectl exec -n "$NAMESPACE" "$POD" -- \
  du -sh "$WAL_DIR" | awk '{print $1}')"

STATUS="OK"
if [ "$USED_PCT" -ge "$THRESHOLD_PCT" ]; then
  STATUS="BLOCKED"
fi

cat > "$OUT_STATE" <<EOT
wal_status=${STATUS}
wal_used_pct=${USED_PCT}
wal_size=${SIZE}
threshold_pct=${THRESHOLD_PCT}
checked_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOT

date -u +"%Y-%m-%d %H:%M:%S" > "$LAST_CHECK"

if [ "$STATUS" = "BLOCKED" ]; then
  echo "❌ WAL BLOCKED (${USED_PCT}%)"
  exit 1
fi

echo "✅ WAL OK (${USED_PCT}%)"
