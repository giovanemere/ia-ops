#!/bin/bash

# Script para iniciar Backstage con las variables del .env principal
# Fecha: $(date)

set -e

echo "🚀 Iniciando Backstage con configuración del .env principal..."

# Ruta al archivo .env principal
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

# Verificar que existe el archivo .env principal
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env principal en $ENV_FILE"
    exit 1
fi

echo "✅ Cargando variables de entorno desde $ENV_FILE"

# Cargar variables de entorno
set -a  # Exportar automáticamente todas las variables
source "$ENV_FILE"
set +a

# Verificar variables críticas
echo "🔍 Verificando variables críticas..."
if [ -z "$POSTGRES_HOST" ]; then
    echo "❌ Error: POSTGRES_HOST no está definido"
    exit 1
fi

if [ -z "$POSTGRES_USER" ]; then
    echo "❌ Error: POSTGRES_USER no está definido"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "❌ Error: POSTGRES_PASSWORD no está definido"
    exit 1
fi

if [ -z "$BACKEND_SECRET" ]; then
    echo "❌ Error: BACKEND_SECRET no está definido"
    exit 1
fi

echo "✅ Variables críticas verificadas"
echo "📊 Configuración actual:"
echo "   - PostgreSQL Host: $POSTGRES_HOST"
echo "   - PostgreSQL Port: $POSTGRES_PORT"
echo "   - PostgreSQL User: $POSTGRES_USER"
echo "   - PostgreSQL DB: $POSTGRES_DB"
echo "   - Backstage Backend Port: $BACKSTAGE_BACKEND_PORT"
echo "   - Backstage Frontend Port: $BACKSTAGE_FRONTEND_PORT"

# Instalar dependencias si es necesario
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    yarn install
fi

# Iniciar Backstage
echo "🎭 Iniciando Backstage..."
yarn dev
