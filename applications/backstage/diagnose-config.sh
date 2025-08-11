#!/bin/bash

# =============================================================================
# Diagnóstico de Configuración OpenAI
# =============================================================================

set -e

echo "🔍 Diagnosticando configuración de OpenAI..."

# Rutas de archivos
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
CONFIG_FILE="packages/app/src/config/env.ts"

echo ""
echo "📋 1. Configuración en .env:"
echo "=========================="
grep "OPENAI_MODEL=" "$ENV_FILE" | head -1
grep "OPENAI_MAX_TOKENS=" "$ENV_FILE" | head -1  
grep "OPENAI_TEMPERATURE=" "$ENV_FILE" | head -1
grep "REACT_APP_OPENAI_MODEL=" "$ENV_FILE" | head -1

echo ""
echo "📋 2. Configuración en env.ts:"
echo "=============================="
grep "MODEL:" "$CONFIG_FILE"
grep "MAX_TOKENS:" "$CONFIG_FILE"
grep "TEMPERATURE:" "$CONFIG_FILE"

echo ""
echo "📋 3. Fecha de última actualización:"
echo "===================================="
grep "Actualizado el:" "$CONFIG_FILE"

echo ""
echo "📋 4. Verificando proceso de compilación:"
echo "=========================================="
echo "🔍 Verificando TypeScript..."
if yarn tsc --noEmit > /dev/null 2>&1; then
    echo "✅ TypeScript: Sin errores"
else
    echo "❌ TypeScript: Hay errores"
fi

echo ""
echo "📋 5. Verificando archivos de build:"
echo "===================================="
if [ -d "packages/app/dist" ]; then
    echo "✅ Directorio dist existe"
    echo "📅 Última modificación: $(stat -c %y packages/app/dist 2>/dev/null || echo 'No disponible')"
else
    echo "⚠️  Directorio dist no existe - necesita compilación"
fi

echo ""
echo "📋 6. Verificando variables de entorno en runtime:"
echo "=================================================="
source "$ENV_FILE"
echo "✅ OPENAI_MODEL desde .env: $OPENAI_MODEL"
echo "✅ OPENAI_MAX_TOKENS desde .env: $OPENAI_MAX_TOKENS"
echo "✅ OPENAI_TEMPERATURE desde .env: $OPENAI_TEMPERATURE"

echo ""
echo "🎯 Resumen del diagnóstico:"
echo "=========================="
ENV_MODEL=$(grep "OPENAI_MODEL=" "$ENV_FILE" | head -1 | cut -d'=' -f2)
TS_MODEL=$(grep "MODEL:" "$CONFIG_FILE" | cut -d"'" -f2)

if [ "$ENV_MODEL" = "$TS_MODEL" ]; then
    echo "✅ Configuración consistente: $ENV_MODEL"
else
    echo "❌ Inconsistencia detectada:"
    echo "   .env: $ENV_MODEL"
    echo "   env.ts: $TS_MODEL"
fi

echo ""
echo "💡 Posibles soluciones si la web no muestra la configuración correcta:"
echo "1. Limpiar caché del navegador (Ctrl+Shift+Del)"
echo "2. Recargar con Ctrl+F5 (hard refresh)"
echo "3. Abrir en ventana privada/incógnito"
echo "4. Limpiar localStorage del navegador"
echo "5. Re-sincronizar: ./sync-env-config.sh"
echo ""
echo "✨ Diagnóstico completado!"
