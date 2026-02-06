#!/usr/bin/env bash
set -euo pipefail

STATE="/opt/ssot/state/sla_rpo.status"

if [[ ! -f "$STATE" ]]; then
  echo "sla_rpo_status=UNKNOWN"
  exit 0
fi

source "$STATE"

echo "sla_defined=${sla_defined}"
echo "rpo_defined=${rpo_defined}"
echo "rto_defined=${rto_defined}"
echo "guarantees=${guarantees}"
echo "reason=${reason}"
