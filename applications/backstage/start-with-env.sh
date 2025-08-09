#!/bin/bash

# Script para iniciar Backstage con variables de entorno
echo "🚀 Iniciando Backstage con configuración de entorno..."

# Cargar variables de entorno desde el archivo principal
if [ -f "../../.env" ]; then
    echo "✅ Cargando variables de entorno desde ../../.env"
    set -a  # automatically export all variables
    source ../../.env
    set +a  # stop automatically exporting
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

# Verificar variables críticas
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN no está configurado correctamente"
    echo "Continuando con funcionalidad limitada..."
fi

if [ -z "$BACKEND_SECRET" ]; then
    echo "❌ BACKEND_SECRET no está configurado"
    exit 1
fi

# Verificar longitud del BACKEND_SECRET
if [ ${#BACKEND_SECRET} -lt 32 ]; then
    echo "❌ BACKEND_SECRET es demasiado corto (mínimo 32 caracteres)"
    echo "Generando un nuevo BACKEND_SECRET..."
    NEW_SECRET=$(openssl rand -base64 64 | tr -d '\n')
    export BACKEND_SECRET="$NEW_SECRET"
    echo "✅ Nuevo BACKEND_SECRET generado temporalmente"
    echo "🔧 Para hacer permanente, actualiza ../../.env con:"
    echo "BACKEND_SECRET=$NEW_SECRET"
fi

echo "✅ Variables de entorno cargadas correctamente"
echo "🔧 GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "🔧 Backend Secret: ${BACKEND_SECRET:0:10}..."
echo "🔧 Postgres DB: $POSTGRES_DB"

# Exportar variables explícitamente para Backstage
export BACKEND_SECRET
export POSTGRES_HOST
export POSTGRES_PORT
export POSTGRES_USER
export POSTGRES_PASSWORD
export POSTGRES_DB
export GITHUB_TOKEN
export BACKSTAGE_BACKEND_PORT
export BACKSTAGE_FRONTEND_PORT
export NODE_ENV=development

echo "🚀 Iniciando Backstage..."

# Iniciar Backstage con variables exportadas
yarn start
