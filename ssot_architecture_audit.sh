#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
AUDIT="ssot_arch_audit_$TS"
TMP="/tmp/$AUDIT"
OUT="/media/sf_vm-share/$AUDIT.tar.gz"

mkdir -p "$TMP"

log() {
  echo "[$(date '+%F %T')] $1" | tee -a "$TMP/report.txt"
}

log "=== SSOT ARCHITECTURE AUDIT START ==="
log "Timestamp: $TS"

#######################################
# STAGE 1–7 : FIXATION / STATE / SNAPSHOT
#######################################

log "--- STAGE 1–7: SSOT CORE CHECKS ---"

# Active PVC list
if [ -f /opt/ssot/state/active_pvc.list ]; then
  log "OK: active_pvc.list exists"
  cp /opt/ssot/state/active_pvc.list "$TMP/"
else
  log "FAIL: active_pvc.list missing"
fi

# Postgres PVC mount
PGDATA=$(kubectl exec -n trading postgres-0 -- printenv PGDATA 2>/dev/null || true)

if [ -n "$PGDATA" ]; then
  log "OK: PGDATA=$PGDATA"
else
  log "FAIL: PGDATA not detected"
fi

#######################################
# WAL CHECK (existence + growth risk)
#######################################

log "--- WAL CHECK ---"

WAL_DIR=$(kubectl exec -n trading postgres-0 -- bash -c 'ls -d $PGDATA/pg_wal 2>/dev/null' || true)

if [ -n "$WAL_DIR" ]; then
  log "OK: WAL directory exists: $WAL_DIR"
  kubectl exec -n trading postgres-0 -- du -sh "$WAL_DIR" > "$TMP/wal_size.txt" 2>/dev/null || true
else
  log "FAIL: WAL directory missing"
fi

# WAL config limits
log "Checking WAL limits"
kubectl exec -n trading postgres-0 -- psql -U postgres -Atc "SHOW max_wal_size;" > "$TMP/max_wal_size.txt" 2>/dev/null || true
kubectl exec -n trading postgres-0 -- psql -U postgres -Atc "SHOW min_wal_size;" > "$TMP/min_wal_size.txt" 2>/dev/null || true

#######################################
# STAGE 8 : BACKUP
#######################################

log "--- STAGE 8: BACKUP CHECK ---"

BACKUP_DIR="/opt/ssot-backup"

if [ -d "$BACKUP_DIR" ]; then
  log "OK: backup dir exists: $BACKUP_DIR"
  du -sh "$BACKUP_DIR" > "$TMP/backup_dir_size.txt" 2>/dev/null || true
else
  log "FAIL: backup dir missing"
fi

# Dumps
if [ -d "$BACKUP_DIR/dumps" ]; then
  log "OK: dumps directory exists"
  ls -lh "$BACKUP_DIR/dumps" > "$TMP/dumps_list.txt" 2>/dev/null || true
else
  log "FAIL: dumps directory missing"
fi

# Retention script
if [ -f "$BACKUP_DIR/ssot_retention.sh" ]; then
  log "OK: retention script exists"
else
  log "WARN: retention script missing"
fi

#######################################
# Disk pressure (host level)
#######################################

log "--- DISK PRESSURE CHECK ---"

df -h > "$TMP/df_host.txt"
df -ih > "$TMP/df_inode.txt"

#######################################
# STAGE 9 : HA / REPLICATION
#######################################

log "--- STAGE 9: HA / REPLICATION CHECK ---"

REPLICA_COUNT=$(kubectl get pods -n trading | grep postgres | wc -l || true)

if [ "$REPLICA_COUNT" -eq 1 ]; then
  log "OK: single Postgres pod (SSOT preserved)"
else
  log "WARN: multiple Postgres pods detected ($REPLICA_COUNT)"
fi

#######################################
# STAGE 10 : OBSERVABILITY
#######################################

log "--- STAGE 10: OBSERVABILITY CHECK ---"

# Prometheus
if kubectl get svc -n monitoring | grep -q prometheus; then
  log "OK: Prometheus service exists"
else
  log "FAIL: Prometheus service missing"
fi

# Grafana
if kubectl get svc -n monitoring | grep -q grafana; then
  log "OK: Grafana service exists"
else
  log "FAIL: Grafana service missing"
fi

# Restore drill marker
if kubectl get cm ssot-restore-drill -n trading >/dev/null 2>&1; then
  log "OK: restore-drill ConfigMap exists"
else
  log "WARN: restore-drill ConfigMap missing"
fi

#######################################
# FINALIZE
#######################################

log "=== AUDIT COMPLETE ==="

tar -czf "$OUT" -C /tmp "$AUDIT"

log "Archive created: $OUT"
