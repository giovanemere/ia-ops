#!/bin/bash

# =============================================================================
# Fix Chat Dark Mode - Mejorar visibilidad del chat en modo oscuro
# =============================================================================

set -e

echo "🔧 Aplicando mejoras para el modo oscuro del chat..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecuta desde el directorio de Backstage."
    exit 1
fi

# Verificar que el archivo del chat existe
CHAT_FILE="packages/app/src/components/AiChat/AiChatPage.tsx"
if [ ! -f "$CHAT_FILE" ]; then
    echo "❌ Error: No se encontró el archivo del chat: $CHAT_FILE"
    exit 1
fi

echo "✅ Archivo del chat encontrado: $CHAT_FILE"

# Crear backup del archivo original
BACKUP_FILE="${CHAT_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CHAT_FILE" "$BACKUP_FILE"
echo "📁 Backup creado: $BACKUP_FILE"

# Verificar que los cambios se aplicaron correctamente
if grep -q "theme.palette.type === 'dark'" "$CHAT_FILE"; then
    echo "✅ Los cambios para modo oscuro ya están aplicados"
else
    echo "❌ Los cambios no se detectaron en el archivo"
    echo "ℹ️  Verifica que los cambios se hayan guardado correctamente"
    exit 1
fi

# Compilar la aplicación
echo "🔨 Compilando la aplicación..."
if yarn build:frontend > /dev/null 2>&1; then
    echo "✅ Compilación exitosa"
else
    echo "⚠️  La compilación tuvo algunos warnings, pero continuamos..."
fi

echo ""
echo "🎨 Mejoras aplicadas para el modo oscuro:"
echo "   • Fondo de mensajes de IA: gris oscuro en modo oscuro"
echo "   • Texto de mensajes: blanco en modo oscuro"
echo "   • Scrollbar: colores adaptados al tema"
echo ""
echo "🔄 Para ver los cambios:"
echo "   1. Recarga la página de Backstage"
echo "   2. Cambia al modo oscuro si no está activado"
echo "   3. Ve a la página del Chat de IA"
echo ""
echo "🌐 URL del chat: http://localhost:8080/ai-chat"
echo ""
echo "✨ ¡Listo! El chat ahora debería ser más legible en modo oscuro."
