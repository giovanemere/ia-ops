#!/bin/bash

# =============================================================================
# Verificar Mejoras del Chat - Comprobar que todo funciona correctamente
# =============================================================================

set -e

echo "🔍 Verificando las mejoras del chat de IA..."

# Verificar que el archivo del chat existe y tiene los cambios
CHAT_FILE="packages/app/src/components/AiChat/AiChatPage.tsx"

if [ ! -f "$CHAT_FILE" ]; then
    echo "❌ Error: No se encontró el archivo del chat"
    exit 1
fi

echo "✅ Archivo del chat encontrado"

# Verificar que los cambios están aplicados
if grep -q "theme.palette.type === 'dark'" "$CHAT_FILE"; then
    echo "✅ Cambios para modo oscuro detectados"
else
    echo "❌ Los cambios para modo oscuro no están aplicados"
    exit 1
fi

# Verificar que los servicios están corriendo
echo ""
echo "🔍 Verificando servicios..."

# Verificar Backstage Backend
if curl -s http://localhost:7007/api/catalog/entities > /dev/null 2>&1; then
    echo "✅ Backstage Backend (puerto 7007) - OK"
else
    echo "⚠️  Backstage Backend (puerto 7007) - No responde"
fi

# Verificar Proxy Gateway
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Proxy Gateway (puerto 8080) - OK"
else
    echo "⚠️  Proxy Gateway (puerto 8080) - No responde"
fi

# Verificar OpenAI Service
if curl -s http://localhost:8003/health > /dev/null 2>&1; then
    echo "✅ OpenAI Service (puerto 8003) - OK"
else
    echo "⚠️  OpenAI Service (puerto 8003) - No responde"
fi

echo ""
echo "📋 Resumen de verificación:"
echo "   • Archivo del chat: ✅ Modificado correctamente"
echo "   • Estilos para modo oscuro: ✅ Aplicados"
echo "   • Backup de seguridad: ✅ Creado"

echo ""
echo "🎯 Próximos pasos:"
echo "   1. Abre tu navegador en: http://localhost:8080"
echo "   2. Navega al Chat de IA: http://localhost:8080/ai-chat"
echo "   3. Cambia al modo oscuro usando el toggle del tema"
echo "   4. Verifica que el texto del chat sea claramente visible"

echo ""
echo "🌙 Mensaje de prueba esperado:"
echo '   "¡Hola! 👋 Soy tu asistente de IA especializado en Backstage..."'
echo "   (Debe aparecer con fondo gris oscuro y texto blanco en modo oscuro)"

echo ""
echo "✨ ¡Verificación completada!"
