#!/bin/bash

# Script para cargar variables .env y ejecutar yarn start
# Uso: ./start-with-env.sh

echo "🚀 Iniciando Backstage con configuración local..."

# Cargar variables de entorno principales
set -a
source /home/giovanemere/ia-ops/ia-ops/.env

# Override database host for local development (when running outside Docker)
export POSTGRES_HOST=localhost
export REDIS_HOST=localhost

# Cargar variables locales (sobrescriben las principales)
set +a

# Verificar que PostgreSQL esté ejecutándose
echo "🔍 Verificando PostgreSQL..."
if ! nc -z localhost 5432; then
    echo "⚠️  PostgreSQL no está ejecutándose en localhost:5432"
    echo "🐳 Iniciando PostgreSQL con Docker..."
    cd /home/giovanemere/ia-ops/ia-ops
    docker-compose up -d postgres redis
    echo "⏳ Esperando a que PostgreSQL esté listo..."
    sleep 5
fi

# Ir al directorio de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

echo "📊 Variables de entorno configuradas:"
echo "  POSTGRES_HOST: $POSTGRES_HOST"
echo "  REDIS_HOST: $REDIS_HOST"
echo "  BACKSTAGE_BASE_URL: $BACKSTAGE_BASE_URL"

# Ejecutar yarn start
echo "🏛️ Iniciando Backstage..."
yarn start
