#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/basebackup.status"

if [[ ! -f "$STATE" ]]; then
  echo "basebackup_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "basebackup_enabled=${basebackup_enabled}"
echo "reason=${reason}"
