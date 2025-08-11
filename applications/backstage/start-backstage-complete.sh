#!/bin/bash

# =============================================================================
# Iniciar Backstage Completo con Todas las Configuraciones
# =============================================================================

set -e

echo "🚀 IA-OPS Backstage - Inicio Completo"
echo "======================================"

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
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_ID no está definido en $MAIN_ENV_FILE"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:15}..."
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_SECRET no está definido en $MAIN_ENV_FILE"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:15}..."
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no está definido en $MAIN_ENV_FILE"
    exit 1
else
    echo "   ✅ GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."
fi

if [ -z "$AUTH_GITHUB_CALLBACK_URL" ]; then
    echo "❌ Error: AUTH_GITHUB_CALLBACK_URL no está definido en $MAIN_ENV_FILE"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"
fi

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

echo "📋 Paso 3: Verificando configuración de Backstage..."

# Verificar que app-config.yaml puede resolver las variables
echo "🔍 Verificando resolución de variables en app-config.yaml:"
if grep -q "\${AUTH_GITHUB_CLIENT_ID}" app-config.yaml; then
    echo "   ✅ Configuración de GitHub Auth encontrada en app-config.yaml"
else
    echo "   ❌ Error: No se encontró configuración de GitHub Auth en app-config.yaml"
    exit 1
fi

echo "📋 Paso 4: Iniciando Backstage..."

# Mostrar información de inicio
echo ""
echo "🎯 Configuración de inicio:"
echo "   • Directorio: $BACKSTAGE_DIR"
echo "   • Variables de entorno: Cargadas desde $MAIN_ENV_FILE"
echo "   • Puerto Backend: ${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   • Puerto Frontend: ${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "   • Base URL: ${BACKSTAGE_BASE_URL:-http://localhost:8080}"
echo ""

# Crear un archivo temporal con las variables de entorno para yarn
echo "📝 Creando archivo de entorno temporal para yarn..."
cat > .env.local << EOF
# Variables de entorno para Backstage
AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID
AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET
AUTH_GITHUB_CALLBACK_URL=$AUTH_GITHUB_CALLBACK_URL
GITHUB_TOKEN=$GITHUB_TOKEN
BACKEND_SECRET=$BACKEND_SECRET
POSTGRES_HOST=$POSTGRES_HOST
POSTGRES_PORT=$POSTGRES_PORT
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
EOF

echo "✅ Archivo .env.local creado"

# Iniciar Backstage con las variables de entorno cargadas
echo "🚀 Iniciando Backstage..."
echo "   Logs aparecerán a continuación..."
echo "   Presiona Ctrl+C para detener"
echo ""

# Ejecutar yarn dev con las variables de entorno
exec yarn dev --config app-config.yaml
