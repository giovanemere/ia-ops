#!/bin/bash

# Desarrollo local sin Docker
set -e

echo "🔧 Iniciando desarrollo local de Backstage..."

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado. Instala Node.js 18+"
    exit 1
fi

# Verificar PostgreSQL local
if ! command -v psql &> /dev/null; then
    echo "🐘 Iniciando PostgreSQL con Docker..."
    docker run -d \
        --name postgres-backstage \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres123 \
        -e POSTGRES_DB=backstage \
        -p 5432:5432 \
        postgres:15-alpine
    
    echo "⏳ Esperando PostgreSQL..."
    sleep 10
fi

# Ir al directorio de Backstage
cd applications/backstage-generated 2>/dev/null || {
    echo "📦 Backstage no encontrado. Ejecutando setup..."
    ../scripts/setup-backstage.sh
    cd applications/backstage-generated
}

# Configurar variables de entorno
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres123
export POSTGRES_DB=backstage

echo "🚀 Iniciando Backstage en modo desarrollo..."
yarn dev
