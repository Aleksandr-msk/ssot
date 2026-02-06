#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/ssot"
STATE_DIR="${BASE_DIR}/state"
SNAPSHOT_DIR="${BASE_DIR}/snapshots"
REPORT_FILE="${BASE_DIR}/report.txt"

LATEST_SNAPSHOT="${SNAPSHOT_DIR}/latest"

{
  echo "ssot.timestamp=$(date +"%Y-%m-%d %H:%M:%S")"

  echo "ssot.pg_version=$(cat "${STATE_DIR}/pg_version.lock" 2>/dev/null || echo UNKNOWN)"
  echo "ssot.db_schema=$(cat "${STATE_DIR}/db.version" 2>/dev/null || echo UNKNOWN)"

  echo "ssot.wal_policy=$(cat "${STATE_DIR}/wal.policy" 2>/dev/null | tr '\n' ' ' || echo UNKNOWN)"
  echo "ssot.wal_size=$(cat "${STATE_DIR}/wal.size" 2>/dev/null || echo UNKNOWN)"
  echo "ssot.wal_last_check=$(cat "${STATE_DIR}/wal.last_check" 2>/dev/null || echo UNKNOWN)"

  echo "ssot.audit_status=$(cat "${STATE_DIR}/audit_status.txt" 2>/dev/null || echo UNKNOWN)"
  echo "ssot.audit_last=$(cat "${STATE_DIR}/last_audit.ts" 2>/dev/null || echo UNKNOWN)"

  if [[ -L "${LATEST_SNAPSHOT}" ]]; then
    SNAPSHOT_FILE="$(readlink -f "${LATEST_SNAPSHOT}")"
    echo "ssot.snapshot_file=${SNAPSHOT_FILE}"
    echo "ssot.snapshot_mtime=$(stat -c %y "${SNAPSHOT_FILE}")"
  else
    echo "ssot.snapshot_file=NONE"
    echo "ssot.snapshot_mtime=UNKNOWN"
  fi
} > "${REPORT_FILE}"

echo "report_written=${REPORT_FILE}"
