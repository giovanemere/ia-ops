#!/bin/bash
# =============================================================================
# Script de inicio robusto con carga correcta de variables de entorno
# =============================================================================

set -e

echo "🚀 Iniciando Backstage de forma robusta..."
echo "========================================="

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

echo "✅ Variables de entorno cargadas correctamente desde $MAIN_ENV_FILE"

# =============================================================================
# PASO 2: VERIFICAR CONFIGURACIÓN
# =============================================================================
echo "📋 Paso 2: Verificando configuración..."

# Verificar configuración (opcional, continuar si falla)
if command -v ./verify-config.sh >/dev/null 2>&1 && [ -f "./verify-config.sh" ]; then
    if ./verify-config.sh; then
        echo "✅ Configuración verificada"
    else
        echo "⚠️  Advertencia en configuración - continuando..."
    fi
else
    echo "⚠️  Script verify-config.sh no encontrado - saltando verificación"
fi

# Sincronizar variables de entorno
echo "🔄 Sincronizando variables de entorno..."
if [ -f "./sync-env-config.sh" ]; then
    if ./sync-env-config.sh; then
        echo "✅ Variables sincronizadas"
    else
        echo "⚠️  Error en sincronización - continuando..."
    fi
else
    echo "⚠️  Script sync-env-config.sh no encontrado - saltando sincronización"
fi

# =============================================================================
# PASO 3: VERIFICAR SERVICIOS DE BASE DE DATOS
# =============================================================================
echo "📋 Paso 3: Verificando servicios de base de datos..."

# Verificar que los servicios de base de datos estén corriendo
cd ../../

# Verificar si Docker Compose está disponible
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "⚠️  docker-compose no encontrado - saltando verificación de servicios"
else
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

    # Verificar Redis
    if ! docker-compose ps redis 2>/dev/null | grep -q "Up"; then
        echo "🚀 Iniciando Redis..."
        docker-compose up -d redis
        echo "⏳ Esperando a que Redis esté listo..."
        sleep 5
    else
        echo "✅ Redis ya está corriendo"
    fi
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
# PASO 5: CREAR ARCHIVO DE ENTORNO LOCAL
# =============================================================================
echo "📋 Paso 5: Creando archivo de entorno local..."

# Crear un archivo temporal con las variables de entorno para yarn
cat > .env.local << EOF
# Variables de entorno para Backstage (generado automáticamente)
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

echo "✅ Archivo .env.local creado con variables de entorno"

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
echo ""
echo "📋 Para detener: Ctrl+C"
echo ""

# Iniciar Backstage
echo "🚀 Ejecutando yarn start con variables de entorno cargadas..."
echo "   Logs aparecerán a continuación..."
echo ""

# Ejecutar yarn start con las variables de entorno ya cargadas
exec yarn start
