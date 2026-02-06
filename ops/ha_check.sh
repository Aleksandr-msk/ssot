#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/ha.status"

if [[ ! -f "$STATE" ]]; then
  echo "ha_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "ha_enabled=${ha_enabled}"
echo "replication=${replication}"
echo "mode=${mode}"
echo "reason=${reason}"
