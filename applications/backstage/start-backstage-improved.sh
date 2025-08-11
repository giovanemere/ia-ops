#!/bin/bash
# Script de inicio mejorado para Backstage

set -e

echo "🚀 Iniciando Backstage (versión mejorada)..."
echo "============================================"

# Función para limpiar al salir
cleanup() {
    echo ""
    echo "🛑 Deteniendo Backstage..."
    jobs -p | xargs -r kill 2>/dev/null || true
    exit 0
}

# Configurar trap para limpiar al salir
trap cleanup SIGINT SIGTERM

# Verificar configuración
echo "🔍 Verificando configuración..."
if ! ./verify-config.sh; then
    echo "❌ Error en la configuración. Ejecuta ./setup-persistent-config.sh"
    exit 1
fi

# Sincronizar variables de entorno
echo "🔄 Sincronizando variables de entorno..."
if ! ./sync-env-config.sh; then
    echo "⚠️  Error en sincronización - continuando..."
fi

# Verificar servicios de Docker
echo "🔍 Verificando servicios Docker..."
cd ../../

if command -v docker-compose >/dev/null 2>&1; then
    # Verificar PostgreSQL
    if ! docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
        echo "🚀 Iniciando PostgreSQL..."
        docker-compose up -d postgres
        echo "⏳ Esperando PostgreSQL..."
        
        # Esperar hasta que PostgreSQL esté listo
        for i in {1..30}; do
            if docker-compose exec postgres pg_isready -U backstage_user -d backstage_db >/dev/null 2>&1; then
                echo "✅ PostgreSQL está listo"
                break
            fi
            echo "⏳ Esperando PostgreSQL ($i/30)..."
            sleep 2
        done
    else
        echo "✅ PostgreSQL ya está corriendo"
    fi

    # Verificar Redis
    if ! docker-compose ps redis 2>/dev/null | grep -q "Up"; then
        echo "🚀 Iniciando Redis..."
        docker-compose up -d redis
        sleep 5
        echo "✅ Redis iniciado"
    else
        echo "✅ Redis ya está corriendo"
    fi
else
    echo "⚠️  docker-compose no encontrado - saltando verificación de servicios"
fi

cd applications/backstage

# Verificar dependencias
echo "🔍 Verificando dependencias..."
if [ ! -d "node_modules" ] || [ ! -f "yarn.lock" ]; then
    echo "📦 Instalando dependencias..."
    yarn install --frozen-lockfile
fi

# Limpiar cache
echo "🧹 Limpiando cache..."
rm -f .eslintcache 2>/dev/null || true
rm -rf node_modules/.cache 2>/dev/null || true

# Verificar variables de entorno
echo "🔍 Verificando variables de entorno..."
source ../../.env

if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN no está configurado"
fi

if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "⚠️  AUTH_GITHUB_CLIENT_ID no está configurado"
fi

# Mostrar información de inicio
echo ""
echo "🎯 Iniciando Backstage..."
echo "   • Backend: http://localhost:7007"
echo "   • Frontend: http://localhost:3002"
echo "   • Proxy: http://localhost:8080"
echo ""
echo "📋 Para detener: Ctrl+C"
echo "📋 Para ver logs: tail -f backstage-startup-test.log"
echo ""

# Iniciar Backstage
echo "🚀 Ejecutando yarn start..."
exec yarn start
