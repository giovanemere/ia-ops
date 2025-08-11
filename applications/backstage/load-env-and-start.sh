#!/bin/bash

# =============================================================================
# Cargar Variables de Entorno y Ejecutar Comando
# =============================================================================

set -e

# Ruta al archivo .env principal
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

echo "🔧 Cargando variables de entorno desde $ENV_FILE"

# Verificar que el archivo .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env en $ENV_FILE"
    exit 1
fi

# Cargar y exportar variables de entorno
set -a  # Exportar automáticamente todas las variables
source "$ENV_FILE"
set +a

# Mostrar variables críticas (solo primeros caracteres por seguridad)
echo "✅ Variables cargadas:"
echo "   • AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:15}..."
echo "   • AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:15}..."
echo "   • GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."

# Ejecutar el comando original
echo "🚀 Ejecutando comando de inicio..."
exec ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh
