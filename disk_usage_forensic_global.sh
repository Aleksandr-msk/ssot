#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
REPORT="disk_usage_global_$TS"
TMP="/tmp/$REPORT"
OUT="/media/sf_vm-share/$REPORT.tar.gz"

ROOT="/"

mkdir -p "$TMP"

# 0. Общая информация по дискам
df -h > "$TMP/00_df_h.txt"

# 1. Топ каталогов в /
du -xh --max-depth=1 "$ROOT" 2>/dev/null | sort -hr > "$TMP/01_root_top_dirs.txt"

# 2. Часто проблемные места
for d in \
  /var/lib/docker \
  /var/lib/containerd \
  /var/lib/kubelet \
  /var/log \
  /tmp \
  /var/tmp \
  /media \
  /mnt
do
  if [ -d "$d" ]; then
    du -sh "$d" 2>/dev/null > "$TMP/02_$(echo "$d" | sed 's|/|_|g').txt"
  fi
done

# 3. Топ-100 самых больших файлов на системе (>100M)
find "$ROOT" -xdev -type f -size +100M -exec du -h {} \; 2>/dev/null \
  | sort -hr | head -n 100 > "$TMP/03_top_large_files.txt"

# 4. Логи (var/log) — детализация
if [ -d /var/log ]; then
  du -h /var/log 2>/dev/null | sort -hr > "$TMP/04_var_log_details.txt"
fi

# 5. Docker / containerd детализация
if [ -d /var/lib/docker ]; then
  du -h /var/lib/docker 2>/dev/null | sort -hr > "$TMP/05_docker_details.txt"
fi

if [ -d /var/lib/containerd ]; then
  du -h /var/lib/containerd 2>/dev/null | sort -hr > "$TMP/06_containerd_details.txt"
fi

# 6. kubelet / PVC / local-path
if [ -d /var/lib/kubelet ]; then
  du -h /var/lib/kubelet 2>/dev/null | sort -hr > "$TMP/07_kubelet_details.txt"
fi

# Архивация
tar -czf "$OUT" -C /tmp "$REPORT"

echo "OK: global disk usage forensic report created"
echo "ARCHIVE: $OUT"
