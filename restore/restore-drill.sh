#!/usr/bin/env bash
set -Eeuo pipefail

# ================= META =================
TS=$(date +%Y%m%d-%H%M%S)
PGDATA="/var/lib/postgresql/data"
DUMPS_DIR="/opt/ssot-backup/dumps"

# ================= PRECHECK =================
DUMP_FILE=$(ls -1t "$DUMPS_DIR"/*.sql 2>/dev/null | head -n1 || true)

if [ -z "$DUMP_FILE" ]; then
  echo "NO DUMPS FOUND"
  exit 1
fi

echo "USING DUMP: $DUMP_FILE"

# ================= INIT DB =================
rm -rf "$PGDATA"
mkdir -p "$PGDATA"
chown -R postgres:postgres "$PGDATA"

su - postgres -c "initdb -D $PGDATA"

# ================= START POSTGRES =================
su - postgres -c "pg_ctl -D $PGDATA -o '-F -p 5432' -w start"

# ================= RESTORE =================
su - postgres -c "createdb trading"

su - postgres -c "psql -d trading < $DUMP_FILE"

echo "RESTORE SUCCESS"

# ================= STOP =================
su - postgres -c "pg_ctl -D $PGDATA -m fast stop"
