#!/usr/bin/env bash
set -euo pipefail

echo "== SSOT SNAPSHOT START =="

BASE_DIR="/opt/ssot"
STATE_DIR="${BASE_DIR}/state"
SNAPSHOT_DIR="${BASE_DIR}/snapshots"
REPORT_SH="${BASE_DIR}/report.sh"

mkdir -p "${SNAPSHOT_DIR}"

TS="$(date +"%Y-%m-%d_%H-%M-%S")"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/snapshot_${TS}.txt"

{
  echo "timestamp=${TS}"
  echo "pg_version=$(cat "${STATE_DIR}/pg_version.lock" 2>/dev/null || echo UNKNOWN)"
  echo "db_schema=$(cat "${STATE_DIR}/db.version" 2>/dev/null || echo UNKNOWN)"
  echo "wal_size=$(cat "${STATE_DIR}/wal.size" 2>/dev/null || echo UNKNOWN)"
  echo "wal_last_check=$(cat "${STATE_DIR}/wal.last_check" 2>/dev/null || echo UNKNOWN)"
} > "${SNAPSHOT_FILE}"

ln -sfn "${SNAPSHOT_FILE}" "${SNAPSHOT_DIR}/latest"

# ------------------------------------------------------------------
# UPDATE REPORT AFTER SNAPSHOT
# ------------------------------------------------------------------
if [[ -x "${REPORT_SH}" ]]; then
  "${REPORT_SH}" >/dev/null 2>&1 || true
fi

echo "snapshot_file=${SNAPSHOT_FILE}"
echo "== SSOT SNAPSHOT END =="
