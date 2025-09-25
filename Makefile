# Variables
SHELL := /bin/bash

tools:
	@command -v dig >/dev/null 2>&1 || { echo "dig no está instalado"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "bats no está instalado"; exit 1; }
	@echo "Herramientas verificadas."

build:
	@echo "Generando resoluciones..."
	@./src/resolve.sh

run:
	@echo "Ejecutando auditor DNS..."
	@./src/resolve.sh

test:
	@echo "Ejecutando pruebas con Bats..."
	@bats tests/

clean:
	@rm -rf out/*.csv
	@echo "Archivos temporales eliminados."
