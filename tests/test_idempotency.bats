#!/usr/bin/env bats

setup() {
  mkdir -p out dist
  rm -f out/.res_checksum out/resoluciones.csv dist/*.tar.gz
  # preparar domains base
  printf "example.com\n" > /tmp/dom_base.txt
  cp /tmp/dom_base.txt docs/domains.txt
}

teardown() {
  rm -f /tmp/dom_base.txt
  rm -f docs/domains.txt
  rm -f out/.res_checksum out/resoluciones.csv dist/*.tar.gz
}

@test "build-cache es idempotente cuando no hay cambios" {
  # primer build -> debe crear out/resoluciones.csv y cache
  run make build-cache
  [ "$status" -eq 0 ]
  [ -f out/resoluciones.csv ]
  [ -f out/.res_checksum ]
  checksum1="$(cat out/.res_checksum)"

  # segundo build sin cambios -> debe saltar (exit 0) y no modificar checksum
  sleep 1
  run make build-cache
  [ "$status" -eq 0 ]
  checksum2="$(cat out/.res_checksum)"
  [ "$checksum1" = "$checksum2" ]
}

@test "build-cache detecta cambios en docs/domains.txt" {
  # primer build
  run make build-cache
  [ "$status" -eq 0 ]
  checksum1="$(cat out/.res_checksum)"

  # modificar lista de dominios -> agregar otro dominio
  printf "example.org\n" >> docs/domains.txt

  # segundo build -> debe actualizar cache y generar nuevo checksum
  run make build-cache
  [ "$status" -eq 0 ]
  checksum2="$(cat out/.res_checksum)"
  [ "$checksum1" != "$checksum2" ]
}

@test "pack genera tar.gz con RELEASE" {
  run make pack RELEASE=v9.9.9
  [ "$status" -eq 0 ]
  ls dist/proyecto2-v9.9.9.tar.gz >/dev/null
}
