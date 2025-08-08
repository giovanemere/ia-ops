#!/bin/bash

# =============================================================================
# SCRIPT DE INICIO PARA BACKSTAGE IA-OPS
# =============================================================================

set -e

echo "🚀 Iniciando Backstage IA-OPS..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecuta este script desde el directorio de Backstage."
    exit 1
fi

# Cargar variables de entorno desde el archivo .env principal
ENV_FILE="../../.env"
if [ -f "$ENV_FILE" ]; then
    echo "✅ Cargando variables de entorno desde $ENV_FILE"
    export $(grep -v '^#' $ENV_FILE | xargs)
else
    echo "⚠️  Advertencia: No se encontró $ENV_FILE"
fi

# Verificar variables críticas
echo "🔍 Verificando configuración..."

if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "dummy-token-not-used" ]; then
    echo "⚠️  GITHUB_TOKEN no está configurado o usa valor dummy"
    echo "   La integración de GitHub será limitada"
fi

if [ -z "$BACKEND_SECRET" ]; then
    echo "⚠️  BACKEND_SECRET no está configurado"
    echo "   Generando uno temporal..."
    export BACKEND_SECRET=$(openssl rand -base64 32)
fi

# Mostrar configuración actual
echo "📋 Configuración actual:"
echo "   - BACKSTAGE_FRONTEND_URL: ${BACKSTAGE_FRONTEND_URL:-http://localhost:3000}"
echo "   - BACKSTAGE_BASE_URL: ${BACKSTAGE_BASE_URL:-http://localhost:7007}"
echo "   - GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}... (${#GITHUB_TOKEN} caracteres)"
echo "   - BACKEND_SECRET: ${BACKEND_SECRET:0:10}... (${#BACKEND_SECRET} caracteres)"
echo "   - NODE_ENV: ${NODE_ENV:-development}"

# Verificar dependencias
echo "📦 Verificando dependencias..."
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependencias..."
    yarn install
fi

# Limpiar cache si es necesario
if [ "$1" = "--clean" ]; then
    echo "🧹 Limpiando cache..."
    yarn clean
    yarn install
fi

# Iniciar Backstage
echo "🎯 Iniciando Backstage..."
echo "   Frontend: ${BACKSTAGE_FRONTEND_URL:-http://localhost:3000}"
echo "   Backend:  ${BACKSTAGE_BASE_URL:-http://localhost:7007}"
echo ""
echo "Presiona Ctrl+C para detener"
echo ""

# Usar dotenv-cli para asegurar que las variables se carguen
exec yarn start
