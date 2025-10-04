#!/usr/bin/env bash
set -euo pipefail

SRC_FILE="${1:-out/resoluciones.csv}"
mkdir -p out

if [[ ! -f "$SRC_FILE" ]]; then
  echo "ERROR: no existe $SRC_FILE" >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%d_%H%M%S)"
HIST_FILE="out/history-${timestamp}.csv"

cp "$SRC_FILE" "$HIST_FILE"
echo "Histórico guardado en $HIST_FILE"
