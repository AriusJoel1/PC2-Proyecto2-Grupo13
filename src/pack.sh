#!/usr/bin/env bash
set -euo pipefail

RELEASE="${RELEASE:-v1.0.0}"
PKG_NAME="proyecto2-${RELEASE}.tar.gz"
DIST_DIR="dist"

mkdir -p "$DIST_DIR"

# Archivos incluidos en el paquete (ajusta según necesites)
tar -czf "${DIST_DIR}/${PKG_NAME}" \
  --transform "s|^|proyecto2-${RELEASE}/|" \
  docs/ \
  src/ \
  tests/ \
  Makefile \
  out/ || { echo "Error creando paquete"; exit 1; }

echo "Paquete creado: ${DIST_DIR}/${PKG_NAME}"
