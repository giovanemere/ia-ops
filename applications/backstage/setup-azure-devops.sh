#!/bin/bash

echo "🔧 CONFIGURACIÓN DE AZURE DEVOPS PARA BACKSTAGE"
echo "==============================================="

echo ""
echo "📋 ESTADO ACTUAL:"
echo "================"
echo "❌ Azure DevOps está DESHABILITADO temporalmente"
echo "✅ Esto previene el error 'Missing project name'"
echo "⚠️  Para habilitarlo, necesitas configurar las credenciales"

echo ""
echo "🔑 PARA HABILITAR AZURE DEVOPS:"
echo "==============================="
echo "1. Obtén un Personal Access Token de Azure DevOps:"
echo "   - Ve a https://dev.azure.com"
echo "   - User Settings → Personal Access Tokens"
echo "   - Crea un token con permisos de lectura para:"
echo "     • Code (read)"
echo "     • Build (read)"
echo "     • Release (read)"
echo "     • Work Items (read)"

echo ""
echo "2. Agrega las variables al archivo ../../.env:"
echo "   AZURE_TOKEN=tu_token_aqui"
echo "   AZURE_ORG=tu_organizacion"
echo "   AZURE_PROJECT=tu_proyecto"

echo ""
echo "3. Descomenta la configuración en app-config.yaml:"
cat << 'EOF'
azureDevOps:
  host: dev.azure.com
  token: ${AZURE_TOKEN}
  organization: ${AZURE_ORG}
  projects:
    - ${AZURE_PROJECT}
EOF

echo ""
echo "4. Habilita el plugin en el frontend:"
echo "   - Descomenta las líneas en packages/app/src/App.tsx"
echo "   - Descomenta las líneas en packages/app/src/components/Root/Root.tsx"

echo ""
echo "📁 ARCHIVOS MODIFICADOS (TEMPORALMENTE DESHABILITADOS):"
echo "======================================================="
echo "• app-config.yaml - Configuración de Azure DevOps comentada"
echo "• packages/app/src/App.tsx - Import y ruta comentados"
echo "• packages/app/src/components/Root/Root.tsx - Sidebar item comentado"

echo ""
echo "✅ SOLUCIÓN TEMPORAL APLICADA:"
echo "============================="
echo "• Azure DevOps deshabilitado para prevenir errores"
echo "• Backstage puede iniciar sin problemas"
echo "• GitHub Actions sigue funcionando"
echo "• Otros plugins no se ven afectados"

echo ""
echo "🚀 AHORA PUEDES INICIAR BACKSTAGE:"
echo "================================="
echo "   ./start-with-env.sh"

echo ""
echo "💡 NOTA:"
echo "======="
echo "Azure DevOps se puede habilitar más tarde cuando tengas:"
echo "• Acceso a una organización de Azure DevOps"
echo "• Personal Access Token configurado"
echo "• Proyectos específicos para mostrar"
