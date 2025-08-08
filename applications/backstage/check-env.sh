#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN DE VARIABLES DE ENTORNO - BACKSTAGE IA-OPS
# =============================================================================

echo "🔍 Verificando configuración de variables de entorno..."
echo ""

# Cargar variables de entorno
ENV_FILE="../../.env"
if [ -f "$ENV_FILE" ]; then
    echo "✅ Archivo .env encontrado: $ENV_FILE"
    export $(grep -v '^#' $ENV_FILE | xargs)
else
    echo "❌ No se encontró archivo .env en: $ENV_FILE"
    exit 1
fi

echo ""
echo "📋 Variables de entorno cargadas:"
echo "=================================="

# Variables críticas para Backstage
echo "🏛️  BACKSTAGE:"
echo "   BACKSTAGE_FRONTEND_URL: ${BACKSTAGE_FRONTEND_URL:-'❌ NO CONFIGURADO'}"
echo "   BACKSTAGE_BASE_URL: ${BACKSTAGE_BASE_URL:-'❌ NO CONFIGURADO'}"
echo "   BACKSTAGE_BACKEND_PORT: ${BACKSTAGE_BACKEND_PORT:-'❌ NO CONFIGURADO'}"
echo "   BACKEND_SECRET: ${BACKEND_SECRET:+✅ CONFIGURADO (${#BACKEND_SECRET} caracteres)}"
echo ""

echo "🔗 INTEGRACIONES:"
echo "   GITHUB_TOKEN: ${GITHUB_TOKEN:+✅ CONFIGURADO (${#GITHUB_TOKEN} caracteres)}"
if [ "$GITHUB_TOKEN" = "dummy-token-not-used" ]; then
    echo "   ⚠️  GITHUB_TOKEN usa valor dummy - integración limitada"
fi
echo "   AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:-'❌ NO CONFIGURADO'}"
echo "   AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:+✅ CONFIGURADO}"
echo ""

echo "💾 BASE DE DATOS:"
echo "   DATABASE_CLIENT: ${DATABASE_CLIENT:-'better-sqlite3 (por defecto)'}"
echo "   DATABASE_URL: ${DATABASE_URL:-':memory: (por defecto)'}"
echo "   POSTGRES_HOST: ${POSTGRES_HOST:-'❌ NO CONFIGURADO'}"
echo "   POSTGRES_PORT: ${POSTGRES_PORT:-'❌ NO CONFIGURADO'}"
echo ""

echo "🤖 OPENAI SERVICE:"
echo "   OPENAI_API_KEY: ${OPENAI_API_KEY:+✅ CONFIGURADO (${#OPENAI_API_KEY} caracteres)}"
echo "   OPENAI_SERVICE_URL: ${OPENAI_SERVICE_URL:-'❌ NO CONFIGURADO'}"
echo "   OPENAI_SERVICE_PORT: ${OPENAI_SERVICE_PORT:-'❌ NO CONFIGURADO'}"
echo ""

echo "📊 MONITOREO:"
echo "   PROMETHEUS_PORT: ${PROMETHEUS_PORT:-'❌ NO CONFIGURADO'}"
echo "   GRAFANA_PORT: ${GRAFANA_PORT:-'❌ NO CONFIGURADO'}"
echo ""

echo "🔧 DESARROLLO:"
echo "   NODE_ENV: ${NODE_ENV:-'❌ NO CONFIGURADO'}"
echo "   DEBUG_MODE: ${DEBUG_MODE:-'❌ NO CONFIGURADO'}"
echo "   LOG_LEVEL: ${LOG_LEVEL:-'❌ NO CONFIGURADO'}"
echo ""

# Verificar archivos de configuración
echo "📁 Archivos de configuración:"
echo "=============================="
configs=("app-config.yaml" "app-config.development.yaml" "app-config.local.yaml" "app-config.production.yaml")

for config in "${configs[@]}"; do
    if [ -f "$config" ]; then
        echo "   ✅ $config"
    else
        echo "   ❌ $config (no encontrado)"
    fi
done

echo ""

# Verificar conectividad de puertos
echo "🌐 Verificando puertos:"
echo "======================"

check_port() {
    local port=$1
    local service=$2
    if command -v nc >/dev/null 2>&1; then
        if nc -z localhost $port 2>/dev/null; then
            echo "   ✅ Puerto $port ($service) - OCUPADO"
        else
            echo "   🔓 Puerto $port ($service) - LIBRE"
        fi
    else
        echo "   ⚠️  Puerto $port ($service) - No se puede verificar (nc no disponible)"
    fi
}

check_port ${BACKSTAGE_BACKEND_PORT:-7007} "Backstage Backend"
check_port ${BACKSTAGE_FRONTEND_PORT:-3002} "Backstage Frontend"
check_port ${OPENAI_SERVICE_PORT:-8003} "OpenAI Service"
check_port ${PROMETHEUS_PORT:-9090} "Prometheus"
check_port ${GRAFANA_PORT:-3001} "Grafana"

echo ""

# Verificar dependencias
echo "📦 Verificando dependencias:"
echo "============================"

if [ -d "node_modules" ]; then
    echo "   ✅ node_modules existe"
else
    echo "   ❌ node_modules no existe - ejecutar 'yarn install'"
fi

if command -v docker >/dev/null 2>&1; then
    echo "   ✅ Docker disponible"
    if docker info >/dev/null 2>&1; then
        echo "   ✅ Docker daemon corriendo"
    else
        echo "   ⚠️  Docker daemon no está corriendo"
    fi
else
    echo "   ❌ Docker no disponible - requerido para TechDocs"
fi

if command -v yarn >/dev/null 2>&1; then
    echo "   ✅ Yarn disponible ($(yarn --version))"
else
    echo "   ❌ Yarn no disponible"
fi

echo ""

# Resumen
echo "📊 RESUMEN:"
echo "==========="

critical_vars=("BACKEND_SECRET" "GITHUB_TOKEN")
missing_critical=0

for var in "${critical_vars[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" = "dummy-token-not-used" ]; then
        missing_critical=$((missing_critical + 1))
    fi
done

if [ $missing_critical -eq 0 ]; then
    echo "   ✅ Todas las variables críticas están configuradas"
    echo "   🚀 Listo para iniciar Backstage"
else
    echo "   ⚠️  $missing_critical variable(s) crítica(s) faltante(s)"
    echo "   🔧 Configurar antes de iniciar"
fi

echo ""
echo "💡 Para iniciar Backstage:"
echo "   ./start.sh                    # Script personalizado"
echo "   yarn start                    # Con dotenv automático"
echo "   yarn start:dev               # Modo desarrollo"
echo ""
echo "🔧 Para configurar variables faltantes:"
echo "   nano ../../.env              # Editar archivo .env"
echo ""
