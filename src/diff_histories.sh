#!/usr/bin/env bash
set -euo pipefail

# Uso:
# src/diff_histories.sh old.csv new.csv
# o src/diff_histories.sh    (automático: toma los 2 history-* más recientes)

find_last_two_history() {
  ls -1t out/history-*.csv 2>/dev/null | head -n 2 || true
}

if [[ $# -eq 2 ]]; then
  OLD="$1"
  NEW="$2"
else
  mapfile -t files < <(find_last_two_history)
  if [[ ${#files[@]} -lt 2 ]]; then
    echo "ERROR: se requieren 2 archivos history-*.csv en out/ o pasar old new" >&2
    exit 1
  fi
  OLD="${files[1]}"   # segundo más reciente -> antiguo
  NEW="${files[0]}"   # más reciente -> nuevo
fi

if [[ ! -f "$OLD" || ! -f "$NEW" ]]; then
  echo "ERROR: archivos no encontrados: $OLD o $NEW" >&2
  exit 1
fi

ts="$(date -u +%Y%m%d_%H%M%S)"
OUT_TXT="out/diff-${ts}.txt"
OUT_CSV="out/diff-${ts}.csv"

# Normalizar: omitir encabezado, crear "key" = dominio|tipo|valor y ttl
# formato intermedio: key<TAB>ttl
awk -F, 'NR>1 {gsub(/^[ \t]+|[ \t]+$/,"",$1); gsub(/^[ \t]+|[ \t]+$/,"",$2); gsub(/^[ \t]+|[ \t]+$/,"",$3); gsub(/^[ \t]+|[ \t]+$/,"",$4); print $1 "|" $2 "|" $3 "\t" $4}' "$OLD" | sort > /tmp/old_kvs.txt
awk -F, 'NR>1 {gsub(/^[ \t]+|[ \t]+$/,"",$1); gsub(/^[ \t]+|[ \t]+$/,"",$2); gsub(/^[ \t]+|[ \t]+$/,"",$3); gsub(/^[ \t]+|[ \t]+$/,"",$4); print $1 "|" $2 "|" $3 "\t" $4}' "$NEW" | sort > /tmp/new_kvs.txt

# Extraer solo las keys
cut -f1 /tmp/old_kvs.txt > /tmp/old_keys.txt
cut -f1 /tmp/new_kvs.txt > /tmp/new_keys.txt

# AGREGADOS: keys en el nuevo pero no en el antiguo
comm -23 /tmp/new_keys.txt /tmp/old_keys.txt > /tmp/added_keys.txt

# ELIMINADOS: keys en el antiguo pero no en el nuevo
comm -13 /tmp/new_keys.txt /tmp/old_keys.txt > /tmp/removed_keys.txt

# CAMBIOS DE TTL: keys presentes en ambos pero con TTL diferente
# unimos para tener old_ttl y new_ttl
join -t $'\t' -j 1 /tmp/old_kvs.txt /tmp/new_kvs.txt > /tmp/joined_kvs.txt || true
# las líneas unidas son: key TAB oldttl TAB newttl
awk -F'\t' 'BEGIN{OFS="\t"} {if($2 != $3) print $1, $2, $3}' /tmp/joined_kvs.txt > /tmp/ttl_changes.txt

# Creamos encabezado CSV
echo "change_type,dominio,tipo,valor,ttl_old,ttl_new" > "$OUT_CSV"

# Escribimos filas add
while IFS= read -r key; do
  ttl="$(grep -P "^${key}\t" /tmp/new_kvs.txt | cut -f2 || echo "")"
  IFS='|' read -r dom typ val <<< "$key"
  echo "add,${dom},${typ},${val},,${ttl}" >> "$OUT_CSV"
done < /tmp/added_keys.txt

# Escribimos filas remove
while IFS= read -r key; do
  ttl="$(grep -P "^${key}\t" /tmp/old_kvs.txt | cut -f2 || echo "")"
  IFS='|' read -r dom typ val <<< "$key"
  echo "remove,${dom},${typ},${val},${ttl}," >> "$OUT_CSV"
done < /tmp/removed_keys.txt

# Escribimos cambios de TTL
while IFS=$'\t' read -r key oldttl newttl; do
  IFS='|' read -r dom typ val <<< "$key"
  echo "ttl_change,${dom},${typ},${val},${oldttl},${newttl}" >> "$OUT_CSV"
done < /tmp/ttl_changes.txt

# Resumen
{
  echo "Diff entre:"
  echo "  antiguo: $OLD"
  echo "  nuevo:   $NEW"
  echo
  echo "Resumen:"
  echo "  Altas (nuevas entradas): $(wc -l < /tmp/added_keys.txt || echo 0)"
  echo "  Bajas (entradas removidas): $(wc -l < /tmp/removed_keys.txt || echo 0)"
  echo "  Cambios de TTL: $(wc -l < /tmp/ttl_changes.txt || echo 0)"
  echo
  echo "Detalles en CSV: $OUT_CSV"
  echo
  if [[ -s /tmp/added_keys.txt ]]; then
    echo "== ALTAS =="
    while read -r k; do IFS='|' read dom typ val <<< "$k"; echo " + ${dom} ${typ} ${val}"; done < /tmp/added_keys.txt
    echo
  fi
  if [[ -s /tmp/removed_keys.txt ]]; then
    echo "== BAJAS =="
    while read -r k; do IFS='|' read dom typ val <<< "$k"; echo " - ${dom} ${typ} ${val}"; done < /tmp/removed_keys.txt
    echo
  fi
  if [[ -s /tmp/ttl_changes.txt ]]; then
    echo "== TTL CHANGES =="
    while IFS=$'\t' read -r k old new; do IFS='|' read dom typ val <<< "$k"; echo " * ${dom} ${typ} ${val} : ${old} -> ${new}"; done < /tmp/ttl_changes.txt
    echo
  fi
} > "$OUT_TXT"

echo "Reporte generado: $OUT_TXT"
echo "CSV detallado: $OUT_CSV"
