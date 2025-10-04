# Makefile completo Sprint1+Sprint2+Sprint3
SHELL := /bin/bash

.PHONY: help tools build build-cache run test clean history diff report pack

# Default release (puedes sobreescribir con RELEASE=v1.2.3 make pack)
RELEASE ?= v1.0.0

help:
	@echo "Targets disponibles:"
	@echo "  make tools        -> verifica herramientas (dig, bats)"
	@echo "  make build        -> genera resoluciones (sin cache)"
	@echo "  make build-cache  -> genera resoluciones si inputs cambiaron (caché incremental)"
	@echo "  make run          -> alias de build-cache"
	@echo "  make history      -> guarda histórico out/history-<ts>.csv"
	@echo "  make diff         -> compara los 2 últimos históricos y genera reporte"
	@echo "  make report       -> alias de diff"
	@echo "  make pack         -> empaqueta proyecto en dist/proyecto2-$(RELEASE).tar.gz"
	@echo "  make test         -> ejecuta bats tests/"
	@echo "  make clean        -> limpia out/ y dist/"

# herramientas
tools:
	@command -v dig >/dev/null 2>&1 || { echo "dig no está instalado"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "bats no está instalado"; exit 1; }
	@echo "Herramientas verificadas."

# Sprint 1 basic build (sin cache)
build:
	@echo "Generando resoluciones (no cache)..."
	@./src/resolve.sh

# Sprint 3: build con caché incremental
build-cache:
	@echo "Generando resoluciones con verificación de caché..."
	@./src/build_with_cache.sh

# run es alias de build-cache
run: build-cache
	@echo "Ejecución completa de auditor DNS (run)."

# Sprint 2: history/diff/report (ya incluídos)
history:
	@echo "Guardando histórico actual..."
	@./src/save_history.sh out/resoluciones.csv

diff:
	@echo "Generando diff entre los dos últimos históricos..."
	@./src/diff_histories.sh

report: diff
	@echo "Reporte generado en carpeta out/"

# empaquetado reproducible
pack:
	@echo "Generando paquete dist/proyecto2-$(RELEASE).tar.gz ..."
	@RELEASE=$(RELEASE) ./src/pack.sh

test:
	@echo "Ejecutando pruebas con Bats..."
	@bats tests/

clean:
	@rm -rf out/*.csv out/diff-*.txt out/diff-*.csv out/history-*.csv out/.res_checksum dist/*
	@echo "Archivos temporales eliminados."
