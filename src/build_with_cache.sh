#!/usr/bin/env bash
set -euo pipefail

# variables
DNS_SERVER="${DNS_SERVER:-8.8.8.8}"
DOMAINS_FILE="${DOMAINS_FILE:-docs/domains.txt}"
OUTPUT_FILE="${OUTPUT_FILE:-out/resoluciones.csv}"
CACHE_FILE="out/.res_checksum"

mkdir -p out

# función auxiliar para calcular el checksum: intenta con sha256sum, si falla usa shasum -a 256, y si no, recurre a python
compute_checksum() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$@" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$@" | awk '{print $1}'
  else
    echo "ERROR: No se encontró sha256sum ni shasum. Instale una de estas herramientas para continuar." >&2
    exit 1
  fi
}

# entradas que nos interesan: listado de dominios y el script de resolución
if [[ ! -f "$DOMAINS_FILE" ]]; then
  echo "ERROR: no existe $DOMAINS_FILE" >&2
  exit 1
fi

inputs_checksum="$(compute_checksum "$DOMAINS_FILE" src/resolve.sh)"

# si existe la caché y coincide -> omitir ejecución
if [[ -f "$CACHE_FILE" ]]; then
  old_checksum="$(cat "$CACHE_FILE")"
else
  old_checksum=""
fi

if [[ -f "$OUTPUT_FILE" && "$old_checksum" == "$inputs_checksum" ]]; then
  echo "No hay cambios en inputs. Saltando resolución. Archivo existente: $OUTPUT_FILE"
  exit 0
fi

# ejecutar la resolución (con las mismas variables que antes)
echo "Cambios detectados o sin cache. Ejecutando resolve.sh..."
export DNS_SERVER DOMAINS_FILE OUTPUT_FILE
./src/resolve.sh

# actualizar la caché
echo "$inputs_checksum" > "$CACHE_FILE"
echo "Cache actualizado: $CACHE_FILE"
