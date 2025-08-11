#!/bin/bash

# =============================================================================
# Script Mejorado: Comando Original + Carga de Variables de Entorno
# =============================================================================
# Equivalente a: ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh
# Pero con carga correcta de variables de entorno
# =============================================================================

set -e

echo "🚀 IA-OPS Backstage - Inicio con Variables de Entorno"
echo "====================================================="

# =============================================================================
# PASO 1: CARGAR VARIABLES DE ENTORNO
# =============================================================================
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

echo "📋 Paso 1: Cargando variables de entorno..."

# Verificar que el archivo .env principal existe
if [ ! -f "$MAIN_ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env principal en $MAIN_ENV_FILE"
    exit 1
fi

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

echo "✅ Variables de entorno cargadas correctamente"

# =============================================================================
# PASO 2: EJECUTAR SECUENCIA ORIGINAL
# =============================================================================
echo "📋 Paso 2: Ejecutando secuencia de scripts..."

# 1. Limpiar puertos
echo "🔪 Ejecutando ./kill-ports.sh..."
if [ -f "./kill-ports.sh" ]; then
    ./kill-ports.sh
    echo "✅ Puertos limpiados"
else
    echo "⚠️  Script kill-ports.sh no encontrado - saltando"
fi

# 2. Generar archivos de catálogo
echo "📝 Ejecutando ./generate-catalog-files.sh..."
if [ -f "./generate-catalog-files.sh" ]; then
    ./generate-catalog-files.sh
    echo "✅ Archivos de catálogo generados"
else
    echo "⚠️  Script generate-catalog-files.sh no encontrado - saltando"
fi

# 3. Sincronizar configuración
echo "🔄 Ejecutando ./sync-env-config.sh..."
if [ -f "./sync-env-config.sh" ]; then
    ./sync-env-config.sh
    echo "✅ Configuración sincronizada"
else
    echo "⚠️  Script sync-env-config.sh no encontrado - saltando"
fi

# =============================================================================
# PASO 3: CREAR ARCHIVO DE ENTORNO LOCAL
# =============================================================================
echo "📋 Paso 3: Creando archivo de entorno local..."

# Crear archivo .env.local con las variables necesarias
cat > .env.local << EOF
# Variables de entorno para Backstage (generado automáticamente)
# Fecha: $(date)
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

# =============================================================================
# PASO 4: INICIAR BACKSTAGE
# =============================================================================
echo "📋 Paso 4: Iniciando Backstage..."

# Mostrar información de configuración
echo ""
echo "🎯 Configuración de inicio:"
echo "   • Directorio: $(pwd)"
echo "   • Variables de entorno: Cargadas desde $MAIN_ENV_FILE"
echo "   • Archivo local: .env.local creado"
echo "   • Backend: http://localhost:${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   • Frontend: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "   • Proxy: http://localhost:${PROXY_PORT:-8080}"
echo ""

# 4. Ejecutar start-robust.sh con variables ya cargadas
echo "🚀 Ejecutando ./start-robust.sh con variables de entorno..."
if [ -f "./start-robust.sh" ]; then
    echo "   Variables de entorno ya están cargadas en el shell actual"
    echo "   Iniciando Backstage..."
    echo ""
    exec ./start-robust.sh
else
    echo "❌ Error: Script start-robust.sh no encontrado"
    echo "🔄 Intentando iniciar directamente con yarn start..."
    exec yarn start
fi
