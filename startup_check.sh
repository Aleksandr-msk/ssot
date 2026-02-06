#!/usr/bin/env bash
# =====================================================================
# SSOT STARTUP CONTRACT — GATE ONLY
# Единственная задача: НЕ ПУСТИТЬ СИСТЕМУ СТАРТОВАТЬ
# если SSOT не разрешил запуск.
# =====================================================================

set -euo pipefail

STOP_FILE="/run/ssot/STOP"

echo "== SSOT STARTUP CONTRACT =="
echo "[ ] startup НЕ знает про kubectl"
echo "[ ] startup НЕ знает про postgres"
echo "[ ] startup НЕ знает про schema"
echo "[ ] startup НЕ знает про WAL"
echo "[ ] startup НЕ знает про snapshot"
echo "[ ] startup читает ТОЛЬКО STOP-файл"
echo "--------------------------------"

# =====================================================================
# ЕДИНСТВЕННЫЙ БЛОКЕР — STOP
# =====================================================================
if [[ -f "${STOP_FILE}" ]]; then
  echo "❌ STARTUP BLOCKED: STOP-файл существует (${STOP_FILE})"
  exit 1
fi

echo "✅ STARTUP ALLOWED: STOP-файл отсутствует"
echo "== SSOT STARTUP GATE PASSED =="

exit 0
