#!/bin/bash

echo "🔧 LIMPIANDO IMPORTS DUPLICADOS EN APP.TSX"
echo "=========================================="

echo ""
echo "❌ PROBLEMA DETECTADO:"
echo "====================="
echo "Múltiples imports duplicados de AiChatPage en App.tsx"

# Crear backup
cp packages/app/src/App.tsx packages/app/src/App.tsx.backup.$(date +%Y%m%d_%H%M%S)
echo "💾 Backup creado: packages/app/src/App.tsx.backup.*"

echo ""
echo "🔧 LIMPIANDO IMPORTS DUPLICADOS:"
echo "==============================="

# Remover todas las líneas duplicadas de AiChatPage import
sed -i '/import { AiChatPage } from '\''\.\/components\/AiChat'\'';/d' packages/app/src/App.tsx

# Agregar el import una sola vez en el lugar correcto (después de los imports de @backstage)
sed -i '/import.*from.*@backstage\/plugin-api-docs/a import { AiChatPage } from '\''./components/AiChat'\'';' packages/app/src/App.tsx

echo "✅ Imports duplicados removidos"
echo "✅ Import único agregado en posición correcta"

echo ""
echo "🔍 VERIFICANDO RUTA EN APP.TSX:"
echo "==============================="

# Verificar si la ruta ya existe
if grep -q "path=\"/ai-chat\"" packages/app/src/App.tsx; then
    echo "✅ Ruta /ai-chat ya existe"
else
    echo "🔧 Agregando ruta /ai-chat..."
    # Agregar ruta antes de NotFoundErrorPage
    sed -i '/NotFoundErrorPage/i\        <Route path="/ai-chat" element={<AiChatPage />} />' packages/app/src/App.tsx
    echo "✅ Ruta /ai-chat agregada"
fi

echo ""
echo "📋 VERIFICANDO RESULTADO:"
echo "======================="

echo "Imports de AiChatPage encontrados:"
grep -n "AiChatPage" packages/app/src/App.tsx | head -5

echo ""
echo "Rutas de ai-chat encontradas:"
grep -n "ai-chat" packages/app/src/App.tsx

echo ""
echo "✅ LIMPIEZA COMPLETADA:"
echo "======================"
echo "• ✅ Imports duplicados removidos"
echo "• ✅ Import único en posición correcta"
echo "• ✅ Ruta /ai-chat configurada"
echo "• ✅ Backup de seguridad creado"

echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="
echo "1. 🔄 Reiniciar Backstage:"
echo "   ./start-with-env.sh"
echo ""
echo "2. 🌐 Probar la página AI Chat:"
echo "   http://localhost:3002/ai-chat"
echo ""
echo "3. ✅ Verificar que no hay errores de compilación"

echo ""
echo "💡 FUNCIONALIDADES DE AI CHAT:"
echo "============================="
echo "• 🤖 Interfaz de chat simulada"
echo "• 💬 Envío de mensajes"
echo "• 📱 Diseño responsive"
echo "• 🎨 Integrado con tema de Backstage"
echo "• 🔧 Listo para integrar con API real de IA"
