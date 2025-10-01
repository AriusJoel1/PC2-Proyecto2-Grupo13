# Variables
SHELL := /bin/bash

.PHONY: tools build run test clean history diff report

tools:
	@command -v dig >/dev/null 2>&1 || { echo "dig no está instalado"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "bats no está instalado"; exit 1; }
	@echo "Herramientas verificadas."

build:
	@echo "Generando resoluciones..."
	@./src/resolve.sh

run: build
	@echo "Ejecución completa de auditor DNS finalizada."

test:
	@echo "Ejecutando pruebas con Bats..."
	@bats tests/

clean:
	@rm -rf out/*.csv out/diff-*.txt out/diff-*.csv out/history-*.csv
	@echo "Archivos temporales eliminados."

history:
	@echo "Guardando histórico actual..."
	@./src/save_history.sh out/resoluciones.csv

diff:
	@echo "Generando diff entre los dos últimos históricos..."
	@./src/diff_histories.sh

report: diff
	@echo "Reporte generado en carpeta out/"
