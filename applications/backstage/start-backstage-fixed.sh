#!/bin/bash

# =============================================================================
# Iniciar Backstage con Configuración Correcta
# =============================================================================

set -e

echo "🚀 IA-OPS Backstage - Inicio con Configuración Corregida"
echo "========================================================"

# Rutas importantes
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
BACKSTAGE_DIR="/home/giovanemere/ia-ops/ia-ops/applications/backstage"

# Cambiar al directorio de Backstage
cd "$BACKSTAGE_DIR"

# Verificar que el archivo .env principal existe
if [ ! -f "$MAIN_ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env principal en $MAIN_ENV_FILE"
    exit 1
fi

echo "📋 Paso 1: Cargando variables de entorno..."

# Cargar y exportar variables de entorno
set -a  # Exportar automáticamente todas las variables
source "$MAIN_ENV_FILE"
set +a

# Verificar variables críticas para GitHub Auth
echo "🔍 Verificando configuración de GitHub Auth:"
echo "   ✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:15}..."
echo "   ✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:15}..."
echo "   ✅ GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."
echo "   ✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

echo "📋 Paso 2: Preparando servicios..."

# Matar puertos ocupados
echo "🔪 Liberando puertos..."
./kill-ports.sh

# Generar archivos de catálogo
echo "📝 Generando archivos de catálogo..."
./generate-catalog-files.sh

# Sincronizar configuración de entorno
echo "🔄 Sincronizando configuración..."
./sync-env-config.sh

echo "📋 Paso 3: Iniciando Backstage..."

# Mostrar información de inicio
echo ""
echo "🎯 Configuración de inicio:"
echo "   • Directorio: $BACKSTAGE_DIR"
echo "   • Variables de entorno: Cargadas desde $MAIN_ENV_FILE"
echo "   • Puerto Backend: ${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   • Puerto Frontend: ${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "   • Base URL: ${BACKSTAGE_BASE_URL:-http://localhost:8080}"
echo ""

# Iniciar Backstage con las variables de entorno cargadas
echo "🚀 Iniciando Backstage con 'yarn start'..."
echo "   Logs aparecerán a continuación..."
echo "   Presiona Ctrl+C para detener"
echo ""

# Ejecutar yarn start con las variables de entorno
exec yarn start
