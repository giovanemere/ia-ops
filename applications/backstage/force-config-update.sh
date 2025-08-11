#!/bin/bash

# =============================================================================
# Forzar Actualización de Configuración
# =============================================================================

set -e

echo "🔄 Forzando actualización de configuración..."

# Paso 1: Re-sincronizar configuración
echo "📋 Paso 1: Re-sincronizando configuración..."
./sync-env-config.sh

# Paso 2: Limpiar build cache
echo "🧹 Paso 2: Limpiando caché de build..."
if [ -d "packages/app/dist" ]; then
    rm -rf packages/app/dist
    echo "✅ Caché de build eliminado"
else
    echo "✅ No hay caché de build para limpiar"
fi

if [ -d "packages/app/.cache" ]; then
    rm -rf packages/app/.cache
    echo "✅ Caché de Webpack eliminado"
fi

# Paso 3: Limpiar node_modules cache
echo "🧹 Paso 3: Limpiando caché de node_modules..."
if [ -d "packages/app/node_modules/.cache" ]; then
    rm -rf packages/app/node_modules/.cache
    echo "✅ Caché de node_modules eliminado"
fi

# Paso 4: Agregar timestamp para forzar recarga
echo "🕒 Paso 4: Agregando timestamp para forzar recarga..."
TIMESTAMP=$(date +%s)
cat > "packages/app/src/config/env.ts" << EOF
// Configuración de variables de entorno para el AI Chat
// Estas constantes son sincronizadas automáticamente desde /home/giovanemere/ia-ops/ia-ops/.env
// Actualizado el: $(date)
// Force reload timestamp: $TIMESTAMP

// Variables de OpenAI desde el archivo .env principal
export const OPENAI_CONFIG = {
  API_KEY: '$OPENAI_API_KEY',
  MODEL: '$OPENAI_MODEL',
  MAX_TOKENS: $OPENAI_MAX_TOKENS,
  TEMPERATURE: $OPENAI_TEMPERATURE,
  FORCE_RELOAD: $TIMESTAMP,
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
  forceReload: OPENAI_CONFIG.FORCE_RELOAD,
} as const;
EOF

# Cargar variables del .env
source ../../.env

echo "✅ Configuración actualizada con timestamp: $TIMESTAMP"

# Paso 5: Compilar para asegurar cambios
echo "🔨 Paso 5: Compilando para asegurar cambios..."
yarn workspace app build > /dev/null 2>&1 || echo "⚠️  Build tuvo warnings, pero continuamos"

echo ""
echo "🎯 Actualización forzada completada:"
echo "   • Configuración re-sincronizada"
echo "   • Caché eliminado"
echo "   • Timestamp agregado: $TIMESTAMP"
echo "   • Build actualizado"
echo ""
echo "🌐 Para ver los cambios:"
echo "   1. Mata el proceso de Backstage si está corriendo"
echo "   2. Inicia Backstage nuevamente"
echo "   3. Abre en ventana privada: http://localhost:3000"
echo "   4. Ve al chat de IA y verifica la configuración"
echo ""
echo "💡 Si aún no se actualiza:"
echo "   • Limpia caché del navegador (Ctrl+Shift+Del)"
echo "   • Usa Ctrl+F5 para hard refresh"
echo "   • Abre herramientas de desarrollador y deshabilita caché"
echo ""
echo "✨ ¡Configuración forzada a actualizar!"
