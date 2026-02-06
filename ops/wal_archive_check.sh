#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/wal_archive.status"

if [[ ! -f "$STATE" ]]; then
  echo "wal_archive_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "wal_archive_enabled=${wal_archive_enabled}"
echo "archive_mode=${archive_mode}"
echo "reason=${reason}"
