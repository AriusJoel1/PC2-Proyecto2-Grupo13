#!/usr/bin/env bats

setup() {
  mkdir -p out
  # limpiar salidas previas
  rm -f out/resoluciones.csv
}

teardown() {
  # opcional: limpiar archivos temporales si se crearon
  rm -f /tmp/dom_ok.txt /tmp/dom_bad.txt
}

@test "caso verde: dominio válido (solo google.com) -> exit 0 y CSV contiene google.com" {
  printf "google.com\n" > /tmp/dom_ok.txt
  export DOMAINS_FILE="/tmp/dom_ok.txt"
  run ./src/resolve.sh
  [ "$status" -eq 0 ]
  grep -q "^google.com," out/resoluciones.csv
}

@test "caso rojo: dominio inexistente -> exit != 0 y no hay entrada en CSV" {
  printf "noexiste123456-example-test.com\n" > /tmp/dom_bad.txt
  export DOMAINS_FILE="/tmp/dom_bad.txt"
  run ./src/resolve.sh
  [ "$status" -ne 0 ]
  ! grep -q "^noexiste123456-example-test.com," out/resoluciones.csv || true
}
