#!/usr/bin/env bash
set -eu

# === FIXED CONTRACT ===
NAMESPACE="trading"
POD="trading-postgres-0"

PGDATA="/var/lib/postgresql/data"
WAL_DIR="$PGDATA/pg_wal"

STATE_DIR="/opt/ssot/state"
STATUS_FILE="$STATE_DIR/wal.status"

# thresholds (unchanged)
WAL_WARN=$((1024 * 1024 * 1024))
WAL_CRIT=$((3 * 1024 * 1024 * 1024))
PVC_MIN_FREE=$((10 * 1024 * 1024 * 1024))

# === PRECHECKS ===
command -v kubectl >/dev/null 2>&1 || {
  echo "FATAL: kubectl not found"
  exit 10
}

[ -d "$STATE_DIR" ] || {
  echo "FATAL: $STATE_DIR missing"
  exit 11
}

# === COLLECT FACTS FROM POD ===
wal_size=$(
  kubectl exec -n "$NAMESPACE" "$POD" -- \
    du -sb "$WAL_DIR" | awk '{print $1}'
)

pvc_free=$(
  kubectl exec -n "$NAMESPACE" "$POD" -- \
    df -B1 "$PGDATA" | awk 'NR==2 {print $4}'
)

status="OK"

if [ "$wal_size" -ge "$WAL_CRIT" ] || [ "$pvc_free" -le "$PVC_MIN_FREE" ]; then
  status="ERROR"
elif [ "$wal_size" -ge "$WAL_WARN" ]; then
  status="NEAR_LIMIT"
fi

cat > "$STATUS_FILE" <<EOF
timestamp=$(date -Is)
namespace=$NAMESPACE
pod=$POD
wal_dir=$WAL_DIR
wal_size_bytes=$wal_size
pvc_free_bytes=$pvc_free
status=$status
EOF
