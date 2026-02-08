#!/usr/bin/env bash
set -eu

STATUS_FILE="/opt/ssot/state/wal.status"

[ -f "$STATUS_FILE" ] || {
  echo "FATAL: wal.status missing"
  exit 42
}

status=$(grep '^status=' "$STATUS_FILE" | cut -d= -f2)

case "$status" in
  OK)
    exit 0
    ;;
  NEAR_LIMIT)
    echo "BLOCKED: WAL near limit"
    exit 43
    ;;
  ERROR)
    echo "BLOCKED: WAL critical"
    exit 44
    ;;
  *)
    echo "BLOCKED: unknown WAL status"
    exit 45
    ;;
esac
