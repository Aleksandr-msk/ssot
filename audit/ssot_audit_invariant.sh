#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/opt/ssot/state"
OUT_STATE="${STATE_DIR}/audit_invariant.status"

REQ_FILES=(
  "wal.status"
  "retention.status"
  "disk_guard.status"
)

STATUS="OK"
REASON=""

# --- existence check ---
for f in "${REQ_FILES[@]}"; do
  if [[ ! -f "${STATE_DIR}/${f}" ]]; then
    STATUS="FAIL"
    REASON="missing ${f}"
    break
  fi
done

# --- content check ---
if [[ "${STATUS}" == "OK" ]]; then
  source "${STATE_DIR}/wal.status"
  if [[ "${status:-FAIL}" != "OK" ]]; then
    STATUS="FAIL"
    REASON="WAL not OK"
  fi
fi

if [[ "${STATUS}" == "OK" ]]; then
  source "${STATE_DIR}/retention.status"
  if [[ "${retention_status:-FAIL}" != "OK" ]]; then
    STATUS="FAIL"
    REASON="retention not OK"
  fi
fi

if [[ "${STATUS}" == "OK" ]]; then
  source "${STATE_DIR}/disk_guard.status"
  if [[ "${disk_guard_status:-FAIL}" != "OK" ]]; then
    STATUS="FAIL"
    REASON="disk_guard not OK"
  fi
fi

# --- write invariant state ---
cat > "${OUT_STATE}" <<EOF
audit_invariant_status=${STATUS}
reason=${REASON}
checked_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

# --- enforce ---
if [[ "${STATUS}" != "OK" ]]; then
  echo "❌ AUDIT INVARIANT FAILED: ${REASON}"
  exit 43
fi

echo "✅ AUDIT INVARIANT OK"
