#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/opt/ssot/state"
OUT_STATE="${STATE_DIR}/disk_guard.status"

WAL_STATUS_FILE="${STATE_DIR}/wal.status"
RETENTION_STATUS_FILE="${STATE_DIR}/retention.status"

mkdir -p "${STATE_DIR}"

STATUS="OK"
REASON=""

# --- WAL gate (SSOT) ---
/opt/ssot/wal_gate.sh || {
  STATUS="FAIL"
  REASON="WAL gate blocked"
}


# --- Retention check ---
if [[ "${STATUS}" == "OK" ]]; then
  if [[ ! -f "${RETENTION_STATUS_FILE}" ]]; then
    STATUS="FAIL"
    REASON="retention.status missing"
  else
    source "${RETENTION_STATUS_FILE}"
    if [[ "${retention_status:-FAIL}" != "OK" ]]; then
      STATUS="FAIL"
      REASON="retention not OK"
    fi
  fi
fi

# --- Write state ---
cat > "${OUT_STATE}" <<EOT
disk_guard_status=${STATUS}
reason=${REASON}
checked_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOT

# --- Enforce ---
if [[ "${STATUS}" != "OK" ]]; then
  echo "❌ DISK GUARD BLOCKED: ${REASON}"
  exit 42
fi

echo "✅ DISK GUARD OK"
