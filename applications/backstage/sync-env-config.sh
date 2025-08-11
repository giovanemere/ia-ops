#!/bin/bash

# =============================================================================
# Sincronizar Configuración de Variables de Entorno
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

# Verificar TypeScript con timeout
echo "🔍 Verificando TypeScript..."
if timeout 30s yarn tsc --noEmit 2>&1 | tee /tmp/tsc_output.log; then
    echo "✅ TypeScript: Sin errores"
else
    echo "⚠️  TypeScript: Timeout o errores - continuando..."
    if [ -f /tmp/tsc_output.log ]; then
        echo "📄 Detalles:"
        cat /tmp/tsc_output.log | grep -E "(error|warning)" | head -10 || true
    fi
fi

# Verificar linting con timeout
echo "🔍 Verificando linting..."
if timeout 45s yarn lint:all 2>&1 | tee /tmp/lint_output.log; then
    if grep -q "error\|Error" /tmp/lint_output.log; then
        echo "⚠️  Linting: Hay warnings:"
        echo "📄 Detalles:"
        cat /tmp/lint_output.log | grep -E "(error|warning|Error|Warning)" | head -5
    else
        echo "✅ Linting: Sin errores críticos"
    fi
else
    echo "⚠️  Linting: Timeout después de 45s - continuando..."
    if [ -f /tmp/lint_output.log ]; then
        echo "📄 Salida parcial:"
        tail -5 /tmp/lint_output.log || true
    fi
fi

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
echo "✨ ¡Sincronización completada!"
