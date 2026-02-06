#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
REPORT="disk_usage_ssot_$TS"
TMP="/tmp/$REPORT"
OUT="/media/sf_vm-share/$REPORT.tar.gz"

SSOT_DIR="/opt/ssot"

mkdir -p "$TMP"

# 1. Общий размер SSOT
du -sh "$SSOT_DIR" > "$TMP/00_total_size.txt"

# 2. Размер по верхнему уровню
du -sh "$SSOT_DIR"/* > "$TMP/01_top_level_sizes.txt"

# 3. Все крупные файлы (>10M)
find "$SSOT_DIR" -type f -size +10M -exec du -h {} \; \
  | sort -hr > "$TMP/02_large_files.txt"

# 4. Логи, бэкапы, старые файлы
find "$SSOT_DIR" -type f \( \
  -name "*.log" -o \
  -name "*.bak" -o \
  -name "*.old" \
\) -exec du -h {} \; \
  | sort -hr > "$TMP/03_logs_and_backups.txt"

# 5. tmp / debug если существуют
if [ -d "$SSOT_DIR/tmp" ]; then
  du -sh "$SSOT_DIR/tmp" > "$TMP/04_tmp_dir.txt"
fi

if [ -d "$SSOT_DIR/debug" ]; then
  du -sh "$SSOT_DIR/debug" > "$TMP/05_debug_dir.txt"
fi

# 6. Полный список файлов с размерами (для forensic)
find "$SSOT_DIR" -type f -exec du -h {} \; \
  | sort -hr > "$TMP/06_all_files_sorted.txt"

# Архивация
tar -czf "$OUT" -C /tmp "$REPORT"

echo "OK: disk usage report created"
echo "ARCHIVE: $OUT"
