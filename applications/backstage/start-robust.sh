#!/bin/bash
# Script de inicio robusto que verifica configuración antes de iniciar

set -e

echo "🚀 Iniciando Backstage de forma robusta..."
echo "========================================="

# Verificar configuración
if ! ./verify-config.sh; then
    echo "❌ Error en la configuración. Ejecuta ./setup-persistent-config.sh"
    exit 1
fi

# Sincronizar variables de entorno
echo "🔄 Sincronizando variables de entorno..."
if ! ./sync-env-config.sh; then
    echo "⚠️  Error en sincronización - continuando..."
fi

# Verificar que los servicios de base de datos estén corriendo
echo "🔍 Verificando servicios..."
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
            if docker-compose exec postgres pg_isready -U backstage_user -d backstage_db >/dev/null 2>&1; then
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

# Verificar que las dependencias estén instaladas
echo "🔍 Verificando dependencias..."
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

# Mostrar información de puertos
echo ""
echo "🎯 Iniciando Backstage..."
echo "   • Backend: http://localhost:7007"
echo "   • Frontend: http://localhost:3002"
echo "   • Proxy: http://localhost:8080"
echo ""
echo "📋 Para detener: Ctrl+C"
echo ""

# Iniciar Backstage
echo "🚀 Ejecutando yarn start..."
source ../../.env
exec yarn start
