#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/pitr.status"

if [[ ! -f "$STATE" ]]; then
  echo "pitr_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "pitr_enabled=${pitr_enabled}"
echo "archive_mode=${archive_mode}"
