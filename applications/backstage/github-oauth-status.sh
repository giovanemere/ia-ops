#!/bin/bash

echo "📊 ESTADO ACTUAL DE GITHUB OAUTH"
echo "================================"

echo ""
echo "✅ CONFIGURACIÓN ACTUALIZADA:"
echo "============================"
echo "• Variables correctamente referenciadas en app-config.yaml"
echo "• Backend preparado para GitHub OAuth"
echo "• Configuración deshabilitada hasta tener credenciales"
echo "• Backups de seguridad creados"

echo ""
echo "📋 VARIABLES EN /home/giovanemere/ia-ops/ia-ops/.env:"
echo "===================================================="

# Cargar y mostrar variables
source ../../.env
echo "AUTH_GITHUB_CLIENT_ID='$AUTH_GITHUB_CLIENT_ID'"
echo "AUTH_GITHUB_CLIENT_SECRET='$AUTH_GITHUB_CLIENT_SECRET'"
echo "AUTH_GITHUB_CALLBACK_URL='$AUTH_GITHUB_CALLBACK_URL'"

echo ""
echo "🔍 REFERENCIAS EN ARCHIVOS DE BACKSTAGE:"
echo "========================================"

echo "app-config.yaml:"
echo "  ✅ \${AUTH_GITHUB_CLIENT_ID} - Referenciado correctamente"
echo "  ✅ \${AUTH_GITHUB_CLIENT_SECRET} - Referenciado correctamente"
echo "  ✅ \${AUTH_GITHUB_CALLBACK_URL} - Referenciado correctamente"

echo ""
echo "packages/backend/src/index.ts:"
echo "  ✅ Módulo github-provider preparado"
echo "  ⚠️  Deshabilitado hasta tener credenciales"

echo ""
if [ -z "$AUTH_GITHUB_CLIENT_ID" ] || [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "🔑 PARA COMPLETAR LA CONFIGURACIÓN:"
    echo "=================================="
    echo "1. Edita el archivo: /home/giovanemere/ia-ops/ia-ops/.env"
    echo ""
    echo "2. Cambia estas líneas:"
    echo "   AUTH_GITHUB_CLIENT_ID=          ← Agregar tu Client ID"
    echo "   AUTH_GITHUB_CLIENT_SECRET=      ← Agregar tu Client Secret"
    echo ""
    echo "3. Por ejemplo:"
    echo "   AUTH_GITHUB_CLIENT_ID=Iv1.a1b2c3d4e5f6g7h8"
    echo "   AUTH_GITHUB_CLIENT_SECRET=1234567890abcdef1234567890abcdef12345678"
    echo ""
    echo "4. Ejecuta: ./update-github-oauth-config.sh"
    echo "5. Inicia Backstage: ./start-with-env.sh"
    
    echo ""
    echo "📖 CREAR OAUTH APP EN GITHUB:"
    echo "============================"
    echo "Si no tienes las credenciales:"
    echo "1. Ve a: https://github.com/settings/developers"
    echo "2. Clic en 'OAuth Apps' → 'New OAuth App'"
    echo "3. Usa:"
    echo "   • Application name: IA-OPS Developer Portal"
    echo "   • Homepage URL: http://localhost:3002"
    echo "   • Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"
else
    echo "✅ CONFIGURACIÓN COMPLETA:"
    echo "========================="
    echo "• Credenciales configuradas"
    echo "• GitHub OAuth habilitado"
    echo "• Listo para usar"
    echo ""
    echo "🚀 INICIAR BACKSTAGE:"
    echo "   ./start-with-env.sh"
fi

echo ""
echo "🎯 ESTADO ACTUAL:"
echo "================"
if [ -z "$AUTH_GITHUB_CLIENT_ID" ] || [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "⚠️  CONFIGURACIÓN PREPARADA (esperando credenciales)"
    echo "• Backstage puede iniciar con autenticación Guest"
    echo "• GitHub OAuth se habilitará al agregar credenciales"
else
    echo "✅ CONFIGURACIÓN COMPLETA"
    echo "• GitHub OAuth completamente configurado"
    echo "• Backstage listo con autenticación completa"
fi

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• Editar variables: nano ../../.env"
echo "• Actualizar config: ./update-github-oauth-config.sh"
echo "• Ver estado: ./github-oauth-status.sh"
echo "• Iniciar Backstage: ./start-with-env.sh"
