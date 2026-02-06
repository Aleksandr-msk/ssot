#!/usr/bin/env bash
set -euo pipefail

# ===============================
# SSOT Disk Retention Cleanup
# STAGE 15.2
# ===============================

BACKUP_DIR="/opt/ssot-backup/dumps"
SNAPSHOT_DIR="/opt/ssot/snapshots"

BACKUP_KEEP_DAYS=7
SNAPSHOT_KEEP_DAYS=3

STATE_DIR="/opt/ssot/state"
OUT_STATE="${STATE_DIR}/retention.status"

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$STATE_DIR"

BACKUP_DELETED=0
if [[ -d "$BACKUP_DIR" ]]; then
  while IFS= read -r f; do
    rm -f "$f"
    BACKUP_DELETED=$((BACKUP_DELETED+1))
  done < <(find "$BACKUP_DIR" -type f -mtime +"$BACKUP_KEEP_DAYS")
fi

SNAPSHOT_DELETED=0
if [[ -d "$SNAPSHOT_DIR" ]]; then
  while IFS= read -r f; do
    rm -f "$f"
    SNAPSHOT_DELETED=$((SNAPSHOT_DELETED+1))
  done < <(find "$SNAPSHOT_DIR" -type f -mtime +"$SNAPSHOT_KEEP_DAYS")
fi

cat > "$OUT_STATE" <<EOT
retention_status=OK
backup_deleted=${BACKUP_DELETED}
snapshot_deleted=${SNAPSHOT_DELETED}
backup_keep_days=${BACKUP_KEEP_DAYS}
snapshot_keep_days=${SNAPSHOT_KEEP_DAYS}
checked_at=${NOW}
EOT
