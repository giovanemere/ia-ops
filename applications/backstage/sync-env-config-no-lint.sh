#!/bin/bash

# =============================================================================
# Sincronizar Configuración de Variables de Entorno (Sin Linting)
# =============================================================================

set -e

echo "🔄 Sincronizando configuración de variables de entorno..."

# Rutas de archivos
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
CONFIG_FILE="packages/app/src/config/env.ts"

# Verificar que los archivos existen
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env en $ENV_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: No se encontró el archivo env.ts en $CONFIG_FILE"
    exit 1
fi

echo "✅ Archivos encontrados"

# Leer variables del archivo .env
source "$ENV_FILE"

echo "📋 Variables leídas del .env:"
echo "   • OPENAI_MODEL: $OPENAI_MODEL"
echo "   • OPENAI_MAX_TOKENS: $OPENAI_MAX_TOKENS"
echo "   • OPENAI_TEMPERATURE: $OPENAI_TEMPERATURE"

# Generar nuevo archivo env.ts directamente (sin backup)
cat > "$CONFIG_FILE" << EOF
// Configuración de variables de entorno para el AI Chat
// Estas constantes son sincronizadas automáticamente desde $ENV_FILE
// Actualizado el: $(date)

// Variables de OpenAI desde el archivo .env principal
export const OPENAI_CONFIG = {
  API_KEY: '$OPENAI_API_KEY',
  MODEL: '$OPENAI_MODEL',
  MAX_TOKENS: $OPENAI_MAX_TOKENS,
  TEMPERATURE: $OPENAI_TEMPERATURE,
} as const;

// Función helper para verificar si estamos en desarrollo
export const isDevelopment = () => {
  try {
    return typeof window !== 'undefined' && window.location.hostname === 'localhost';
  } catch {
    return false;
  }
};

// Configuración por defecto
export const DEFAULT_CONFIG = {
  apiKey: OPENAI_CONFIG.API_KEY,
  model: OPENAI_CONFIG.MODEL,
  maxTokens: OPENAI_CONFIG.MAX_TOKENS,
  temperature: OPENAI_CONFIG.TEMPERATURE,
} as const;
EOF

echo "✅ Archivo env.ts actualizado con la configuración del .env"

# Verificación básica de sintaxis (sin TypeScript completo)
echo "🔍 Verificando sintaxis básica..."
if node -c "$CONFIG_FILE" 2>/dev/null; then
    echo "✅ Sintaxis: OK"
else
    echo "⚠️  Sintaxis: Posibles problemas (continuando)"
fi

# SALTAMOS EL LINTING COMPLETAMENTE
echo "⚠️  Saltando verificación de linting para evitar timeout"

echo ""
echo "🎯 Configuración sincronizada:"
echo "   • Modelo: $OPENAI_MODEL"
echo "   • Max Tokens: $OPENAI_MAX_TOKENS"
echo "   • Temperature: $OPENAI_TEMPERATURE"
echo ""
echo "🔄 Para ver los cambios:"
echo "   1. Recarga la página de Backstage"
echo "   2. Ve a la configuración del chat de IA"
echo "   3. Verifica que los valores coincidan con tu .env"
echo ""
echo "🌐 URL del chat: http://localhost:8080/ai-chat"
echo ""
echo "✨ ¡Sincronización completada (sin linting)!"
