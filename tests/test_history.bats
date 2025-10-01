#!/usr/bin/env bats

setup() {
  mkdir -p out
  rm -f out/history-*.csv out/diff-*.csv out/diff-*.txt
}

teardown() {
  rm -f /tmp/hist_old.csv /tmp/hist_new.csv
}

@test "detecta IPs agregadas, eliminadas y cambios de TTL" {
  # historial antiguo
  cat > /tmp/hist_old.csv <<'EOF'
dominio,tipo,valor,ttl
example.com,A,1.1.1.1,3600
example.com,A,2.2.2.2,3600
foo.com,CNAME,alias.example.com,300
EOF

  # historial nuevo (eliminado 2.2.2.2, agregado 3.3.3.3, cambio de TTL en foo.com)
  cat > /tmp/hist_new.csv <<'EOF'
dominio,tipo,valor,ttl
example.com,A,1.1.1.1,3600
example.com,A,3.3.3.3,3600
foo.com,CNAME,alias.example.com,600
EOF

  cp /tmp/hist_old.csv out/history-OLD.csv
  cp /tmp/hist_new.csv out/history-NEW.csv

  run ./src/diff_histories.sh out/history-OLD.csv out/history-NEW.csv
  [ "$status" -eq 0 ]

  # verificar que las salidas existan
  ls out/diff-*.txt out/diff-*.csv >/dev/null 2>&1
  # verificar que el CSV contenga los marcadores esperados
  grep -q "add,example.com,A,3.3.3.3" out/diff-*.csv
  grep -q "remove,example.com,A,2.2.2.2" out/diff-*.csv
  grep -q "ttl_change,foo.com,CNAME,alias.example.com,300,600" out/diff-*.csv
}
