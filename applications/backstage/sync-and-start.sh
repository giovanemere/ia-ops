#!/bin/bash

# =============================================================================
# Sincronizar Configuración y Iniciar Backstage
# =============================================================================

set -e

echo "🚀 Iniciando proceso completo de sincronización y arranque..."

# Sincronizar configuración
echo "🔄 Paso 1: Sincronizando configuración..."
./sync-env-config.sh

echo ""
echo "🔄 Paso 2: Iniciando Backstage con variables de entorno..."

# Verificar que dotenv esté disponible
if ! command -v dotenv &> /dev/null; then
    echo "⚠️  dotenv no está instalado. Instalando..."
    npm install -g dotenv-cli
fi

# Iniciar Backstage con las variables del .env
echo "🌐 Iniciando Backstage en: http://localhost:3000"
echo "🤖 Chat de IA disponible en: http://localhost:8080/ai-chat"
echo ""
echo "📋 Configuración activa:"
echo "   • Modelo: $(grep OPENAI_MODEL ../../.env | cut -d'=' -f2)"
echo "   • Max Tokens: $(grep OPENAI_MAX_TOKENS ../../.env | cut -d'=' -f2)"
echo "   • Temperature: $(grep OPENAI_TEMPERATURE ../../.env | cut -d'=' -f2)"
echo ""
echo "🔄 Iniciando servicios..."

# Ejecutar con dotenv
exec dotenv -e ../../.env -- yarn start
