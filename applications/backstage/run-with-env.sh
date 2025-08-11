#!/bin/bash

# =============================================================================
# Ejecutar Comando con Variables de Entorno Cargadas
# =============================================================================

# Cargar variables de entorno
set -a
source /home/giovanemere/ia-ops/ia-ops/.env
set +a

# Ejecutar el comando original
./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh
