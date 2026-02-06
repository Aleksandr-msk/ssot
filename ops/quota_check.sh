#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/quota.status"

if [[ ! -f "$STATE" ]]; then
  echo "quota_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "quota_enabled=${quota_enabled}"
echo "scope=${scope}"
echo "paths=${paths}"
echo "reason=${reason}"
