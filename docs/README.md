# Sprint 1
Este proyecto contiene:
- Makefile con targets para tools, build, run, test, clean
- Scripts en src/
- Pruebas en tests/ usando Bats
- Documentación en docs/

## Instalar dependencias principales

```bash
sudo yum update -y
sudo yum install -y git make
```

## Instalar bats para los tests
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
which bats
```

## Clonar repositorio
```bash
git clone https://github.com/AriusJoel1/PC2-Proyecto2-Grupo13.git
cd PC2-Proyecto2-Grupo13
```

## Verificar dependencias
```bash
make tools
```

## Habilitar permisos de ejecución
```bash
chmod +x src/*.sh
```
## Uso de variables de entorno
El pipeline permite configurar algunas variables de entorno:

### Servidor DNS específico
`export DNS_SERVER=8.8.8.8`

### Ruta a la lista de dominios
`export DOMAINS_FILE=docs/domains.txt`

**Ejecutar pruebas**
```bash
make test
```

## Ejecutar pipeline principal
```bash
make run
# revisar resultados
less out/resoluciones.csv
```

## Ejecutar pipeline de history
```bash
make history
# revisar resultados en out
```

## Ejecutar pipeline de diff
```bash
make diff
# revisar resultados en out
```

**Videos:**

**Video-Sprint-1**:

**Video-Sprint-2**:

**Video-Sprint-3**: