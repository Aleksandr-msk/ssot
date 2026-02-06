#!/usr/bin/env bash
set -euo pipefail

echo "== SSOT AUDIT START =="

BASE_DIR="/opt/ssot"
STATE_DIR="${BASE_DIR}/state"
CONFIG="${BASE_DIR}/config.env"
SNAPSHOT_DIR="${BASE_DIR}/snapshots"
SNAPSHOT_LATEST="${SNAPSHOT_DIR}/latest"

PG_VERSION_FILE="${STATE_DIR}/pg_version.lock"
DB_SCHEMA_FILE="${STATE_DIR}/db.version"

mkdir -p "${STATE_DIR}"

if [[ ! -f "${CONFIG}" ]]; then
  echo "❌ config.env отсутствует"
  exit 1
fi

# shellcheck disable=SC1090
source "${CONFIG}"

# -----------------------------
# 3.1 Postgres version
# -----------------------------
echo "[3.1] Postgres version audit (SSOT only)"

[[ -z "${EXPECTED_PG_VERSION:-}" ]] && { echo "❌ EXPECTED_PG_VERSION не задан"; exit 1; }
[[ ! -f "${PG_VERSION_FILE}" ]] && { echo "❌ pg_version.lock отсутствует"; exit 1; }

FOUND_PG_VERSION="$(cat "${PG_VERSION_FILE}")"
[[ "${FOUND_PG_VERSION}" != "${EXPECTED_PG_VERSION}" ]] && { echo "❌ Версия Postgres НЕ СОВПАДАЕТ"; exit 1; }

echo "✅ Версия Postgres OK"

# -----------------------------
# 3.2 DB schema version
# -----------------------------
echo "[3.2] DB schema version audit (SSOT only)"

[[ -z "${EXPECTED_DB_SCHEMA_VERSION:-}" ]] && { echo "❌ EXPECTED_DB_SCHEMA_VERSION не задан"; exit 1; }
[[ ! -f "${DB_SCHEMA_FILE}" ]] && { echo "❌ db.version отсутствует"; exit 1; }

FOUND_DB_VERSION="$(cat "${DB_SCHEMA_FILE}")"
[[ "${FOUND_DB_VERSION}" != "${EXPECTED_DB_SCHEMA_VERSION}" ]] && { echo "❌ Версия схемы БД НЕ СОВПАДАЕТ"; exit 1; }

echo "✅ Версия схемы БД OK"

# -----------------------------
# 4.4 Snapshot audit
# -----------------------------
echo "[4.4] Snapshot audit"

[[ ! -L "${SNAPSHOT_LATEST}" ]] && { echo "❌ snapshot latest отсутствует"; exit 1; }

SNAPSHOT_FILE="$(readlink -f "${SNAPSHOT_LATEST}")"
[[ ! -f "${SNAPSHOT_FILE}" ]] && { echo "❌ snapshot файл не найден"; exit 1; }

SNAPSHOT_TS="$(stat -c %Y "${SNAPSHOT_FILE}")"
NOW_TS="$(date +%s)"
AGE_MIN=$(( (NOW_TS - SNAPSHOT_TS) / 60 ))

MAX_AGE_MIN=10

if (( AGE_MIN > MAX_AGE_MIN )); then
  echo "❌ snapshot устарел (${AGE_MIN} min)"
  exit 1
fi

echo "✅ Snapshot OK (${AGE_MIN} min)"

# -----------------------------
date +"%Y-%m-%d %H:%M:%S" > "${STATE_DIR}/last_audit.ts"
echo "OK" > "${STATE_DIR}/audit_status.txt"

echo "== SSOT AUDIT END =="
