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
./sync-env-config.sh 2>/dev/null || true

# Verificar que los servicios de base de datos estén corriendo
echo "🔍 Verificando servicios..."
cd ../../
if ! docker-compose ps postgres | grep -q "Up"; then
    echo "🚀 Iniciando PostgreSQL..."
    docker-compose up -d postgres
    sleep 5
fi

if ! docker-compose ps redis | grep -q "Up"; then
    echo "🚀 Iniciando Redis..."
    docker-compose up -d redis
    sleep 3
fi

cd applications/backstage

# Iniciar Backstage
echo "🎯 Iniciando Backstage..."
source ../../.env
yarn start
