#!/bin/bash

# =============================================================================
# Verificar Configuración de Variables de Entorno
# =============================================================================

set -e

echo "🔍 Verificando configuración de variables de entorno..."

# Rutas de archivos
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
CONFIG_FILE="packages/app/src/config/env.ts"

echo ""
echo "📋 Configuración en .env:"
echo "=========================="
grep "OPENAI_MODEL=" "$ENV_FILE" | head -1
grep "OPENAI_MAX_TOKENS=" "$ENV_FILE" | head -1
grep "OPENAI_TEMPERATURE=" "$ENV_FILE" | head -1

echo ""
echo "📋 Configuración en env.ts:"
echo "============================"
grep "MODEL:" "$CONFIG_FILE"
grep "MAX_TOKENS:" "$CONFIG_FILE"
grep "TEMPERATURE:" "$CONFIG_FILE"

echo ""
echo "🔍 Verificando consistencia..."

# Leer variables del .env
source "$ENV_FILE"

# Verificar que coincidan
ENV_MODEL=$(grep "MODEL:" "$CONFIG_FILE" | cut -d"'" -f2)
ENV_TOKENS=$(grep "MAX_TOKENS:" "$CONFIG_FILE" | cut -d" " -f4 | tr -d ',')
ENV_TEMP=$(grep "TEMPERATURE:" "$CONFIG_FILE" | cut -d" " -f4 | tr -d ',')

echo ""
if [ "$OPENAI_MODEL" = "$ENV_MODEL" ]; then
    echo "✅ Modelo: $OPENAI_MODEL (coincide)"
else
    echo "❌ Modelo: .env=$OPENAI_MODEL vs env.ts=$ENV_MODEL (NO coincide)"
fi

if [ "$OPENAI_MAX_TOKENS" = "$ENV_TOKENS" ]; then
    echo "✅ Max Tokens: $OPENAI_MAX_TOKENS (coincide)"
else
    echo "❌ Max Tokens: .env=$OPENAI_MAX_TOKENS vs env.ts=$ENV_TOKENS (NO coincide)"
fi

if [ "$OPENAI_TEMPERATURE" = "$ENV_TEMP" ]; then
    echo "✅ Temperature: $OPENAI_TEMPERATURE (coincide)"
else
    echo "❌ Temperature: .env=$OPENAI_TEMPERATURE vs env.ts=$ENV_TEMP (NO coincide)"
fi

echo ""
echo "🌐 Para verificar en la web:"
echo "   1. Ve a: http://localhost:8080/ai-chat"
echo "   2. Haz clic en el ícono de configuración (⚙️)"
echo "   3. Verifica que los valores mostrados sean:"
echo "      • Modelo: $OPENAI_MODEL"
echo "      • Max Tokens: $OPENAI_MAX_TOKENS"
echo "      • Temperature: $OPENAI_TEMPERATURE"

echo ""
echo "🔄 Si los valores no coinciden en la web:"
echo "   1. Recarga la página (Ctrl+F5)"
echo "   2. Limpia la caché del navegador"
echo "   3. Ejecuta: ./sync-env-config.sh"

echo ""
echo "✨ Verificación completada!"
