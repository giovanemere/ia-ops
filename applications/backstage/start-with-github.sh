#!/bin/bash
# =============================================================================
# Script de inicio de Backstage con GitHub habilitado
# =============================================================================

set -e

echo "🚀 Iniciando Backstage con GitHub habilitado..."
echo "=============================================="

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
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_ID no está definido"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:15}..."
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_SECRET no está definido"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:15}..."
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no está definido"
    exit 1
else
    echo "   ✅ GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."
fi

if [ -z "$AUTH_GITHUB_CALLBACK_URL" ]; then
    echo "❌ Error: AUTH_GITHUB_CALLBACK_URL no está definido"
    exit 1
else
    echo "   ✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"
fi

echo "✅ Variables de entorno cargadas correctamente"

# =============================================================================
# PASO 2: PROBAR CONECTIVIDAD CON GITHUB
# =============================================================================
echo "📋 Paso 2: Probando conectividad con GitHub..."

# Probar el token de GitHub
echo "🔍 Probando GitHub token..."
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q "login"; then
    echo "✅ GitHub token válido"
else
    echo "❌ Error: GitHub token inválido"
    exit 1
fi

# Probar acceso a repositorio
echo "🔍 Probando acceso a repositorio..."
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/giovanemere/poc-billpay-back/contents/catalog-info.yaml?ref=trunk | grep -q "catalog-info.yaml"; then
    echo "✅ Acceso a repositorios confirmado"
else
    echo "❌ Error: No se puede acceder a los repositorios"
    exit 1
fi

# =============================================================================
# PASO 3: VERIFICAR SERVICIOS DE BASE DE DATOS
# =============================================================================
echo "📋 Paso 3: Verificando servicios de base de datos..."

# Verificar que los servicios de base de datos estén corriendo
cd ../../

# Verificar PostgreSQL
if ! docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
    echo "🚀 Iniciando PostgreSQL..."
    docker-compose up -d postgres
    echo "⏳ Esperando a que PostgreSQL esté listo..."
    
    # Esperar hasta que PostgreSQL esté listo
    for i in {1..20}; do
        if docker-compose exec postgres pg_isready -U ${POSTGRES_USER:-backstage_user} -d ${POSTGRES_DB:-backstage_db} >/dev/null 2>&1; then
            echo "✅ PostgreSQL está listo"
            break
        fi
        echo "⏳ Esperando PostgreSQL ($i/20)..."
        sleep 3
    done
else
    echo "✅ PostgreSQL ya está corriendo"
fi

cd applications/backstage

# =============================================================================
# PASO 4: VERIFICAR DEPENDENCIAS
# =============================================================================
echo "📋 Paso 4: Verificando dependencias..."

# Verificar que las dependencias estén instaladas
if [ ! -d "node_modules" ] || [ ! -f "yarn.lock" ]; then
    echo "📦 Instalando dependencias..."
    yarn install --frozen-lockfile
else
    echo "✅ Dependencias ya están instaladas"
fi

# Limpiar cache si es necesario
if [ -f ".eslintcache" ]; then
    echo "🧹 Limpiando cache de ESLint..."
    rm -f .eslintcache
fi

# =============================================================================
# PASO 5: SINCRONIZAR CONFIGURACIÓN
# =============================================================================
echo "📋 Paso 5: Sincronizando configuración..."

# Ejecutar sync-env-config.sh si existe
if [ -f "./sync-env-config.sh" ]; then
    echo "🔄 Ejecutando sync-env-config.sh..."
    if ./sync-env-config.sh; then
        echo "✅ Configuración sincronizada"
    else
        echo "⚠️  Error en sincronización - continuando..."
    fi
else
    echo "⚠️  Script sync-env-config.sh no encontrado"
fi

# =============================================================================
# PASO 6: INICIAR BACKSTAGE
# =============================================================================
echo "📋 Paso 6: Iniciando Backstage..."

# Mostrar información de puertos
echo ""
echo "🎯 Configuración de inicio:"
echo "   • Directorio: $(pwd)"
echo "   • Variables de entorno: Cargadas desde $MAIN_ENV_FILE"
echo "   • Backend: http://localhost:${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   • Frontend: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "   • Proxy: http://localhost:${PROXY_PORT:-8080}"
echo "   • GitHub Auth: Habilitado"
echo "   • GitHub Integration: Habilitado"
echo ""
echo "🔐 Autenticación disponible:"
echo "   • GitHub OAuth (recomendado)"
echo "   • Guest User (desarrollo)"
echo ""
echo "📋 Para detener: Ctrl+C"
echo ""

# Iniciar Backstage
echo "🚀 Ejecutando yarn start con GitHub habilitado..."
echo "   Logs aparecerán a continuación..."
echo ""

# Ejecutar yarn start con las variables de entorno ya cargadas
exec yarn start
