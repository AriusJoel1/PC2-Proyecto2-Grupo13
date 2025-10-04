#!/usr/bin/env bash
set -euo pipefail

DNS_SERVER="${DNS_SERVER:-8.8.8.8}"
DOMAINS_FILE="${DOMAINS_FILE:-docs/domains.txt}"
OUTPUT_FILE="out/resoluciones.csv"

mkdir -p out

# cabecera
echo "dominio,tipo,valor,ttl" > "$OUTPUT_FILE"

fail_flag=0

while IFS= read -r domain || [[ -n "$domain" ]]; do
  # saltar líneas vacías o comentarios
  domain="${domain%%#*}"
  domain="$(echo -n "$domain" | tr -d '[:space:]')"
  if [[ -z "$domain" ]]; then
    continue
  fi

  # intentar registros A
  aout="$(dig @"$DNS_SERVER" "$domain" A +noall +answer 2>/dev/null || true)"
  if [[ -n "$aout" ]]; then
    # cada línea: name ttl class type rdata
    echo "$aout" | awk -v dom="$domain" '{print dom","$4","$5","$2}' >> "$OUTPUT_FILE"
    continue
  fi

  # intentar CNAME
  cout="$(dig @"$DNS_SERVER" "$domain" CNAME +noall +answer 2>/dev/null || true)"
  if [[ -n "$cout" ]]; then
    echo "$cout" | awk -v dom="$domain" '{print dom","$4","$5","$2}' >> "$OUTPUT_FILE"
    continue
  fi

  # nada encontrado -> marcar fallo
  echo "ERROR: no se obtuvieron registros A/CNAME para $domain" >&2
  fail_flag=1
done < "$DOMAINS_FILE"

if [[ $fail_flag -ne 0 ]]; then
  echo "Al menos un dominio no pudo resolverse correctamente."
  exit 2
else
  echo "Todas las resoluciones ok. Archivo: $OUTPUT_FILE"
  exit 0
fi
