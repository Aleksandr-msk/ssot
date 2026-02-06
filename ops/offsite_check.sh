#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/offsite.status"

if [[ ! -f "$STATE" ]]; then
  echo "offsite_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "offsite_enabled=${offsite_enabled}"
echo "offsite_target=${target}"
