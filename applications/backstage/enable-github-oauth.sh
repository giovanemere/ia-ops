#!/bin/bash

echo "🔐 HABILITAR GITHUB OAUTH EN BACKSTAGE"
echo "======================================"

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    set -a
    source ../../.env
    set +a
else
    echo "❌ No se encontró archivo ../../.env"
    exit 1
fi

echo ""
echo "📋 VERIFICANDO CREDENCIALES OAUTH:"
echo "================================="

if [ -z "$AUTH_GITHUB_CLIENT_ID" ] || [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "❌ Las credenciales OAuth no están configuradas"
    echo ""
    echo "🔑 NECESITAS CONFIGURAR PRIMERO:"
    echo "==============================="
    echo "1. Ejecuta: ./setup-github-oauth.sh"
    echo "2. O edita manualmente ../../.env con:"
    echo "   AUTH_GITHUB_CLIENT_ID=tu_client_id"
    echo "   AUTH_GITHUB_CLIENT_SECRET=tu_client_secret"
    echo ""
    echo "3. Después ejecuta este script nuevamente"
    exit 1
fi

echo "✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
echo "✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
echo "✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

echo ""
echo "🔧 HABILITANDO GITHUB OAUTH:"
echo "============================"

# 1. Habilitar en app-config.yaml
echo "1. Habilitando configuración en app-config.yaml..."

# Crear backup
cp app-config.yaml app-config.yaml.backup.$(date +%Y%m%d_%H%M%S)

# Descomentar la configuración de GitHub
sed -i 's/^    # GitHub OAuth Authentication (disabled until credentials are configured)/    # GitHub OAuth Authentication/' app-config.yaml
sed -i 's/^    # Uncomment and configure when you have GitHub OAuth credentials//' app-config.yaml
sed -i 's/^    # github:/    github:/' app-config.yaml
sed -i 's/^    #   development:/      development:/' app-config.yaml
sed -i 's/^    #     clientId: \${AUTH_GITHUB_CLIENT_ID}/        clientId: \${AUTH_GITHUB_CLIENT_ID}/' app-config.yaml
sed -i 's/^    #     clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}/        clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}/' app-config.yaml
sed -i 's/^    #     callbackUrl: \${AUTH_GITHUB_CALLBACK_URL}/        callbackUrl: \${AUTH_GITHUB_CALLBACK_URL}/' app-config.yaml

echo "✅ Configuración habilitada en app-config.yaml"

# 2. Habilitar en backend
echo "2. Habilitando módulo en backend..."

# Crear backup
cp packages/backend/src/index.ts packages/backend/src/index.ts.backup.$(date +%Y%m%d_%H%M%S)

# Descomentar el módulo de GitHub
sed -i 's|^// GitHub auth provider (disabled until OAuth credentials are configured)|// GitHub auth provider|' packages/backend/src/index.ts
sed -i 's|^// backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));|backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));|' packages/backend/src/index.ts

echo "✅ Módulo habilitado en backend"

echo ""
echo "✅ GITHUB OAUTH HABILITADO COMPLETAMENTE"
echo "======================================="
echo "• Configuración activada en app-config.yaml"
echo "• Módulo activado en backend"
echo "• Credenciales OAuth configuradas"

echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="
echo "1. Reinicia Backstage: ./start-with-env.sh"
echo "2. Ve a: http://localhost:3002"
echo "3. Busca el botón 'Sign In'"
echo "4. Deberías ver 'Sign in with GitHub'"

echo ""
echo "🧪 PARA VERIFICAR:"
echo "=================="
echo "• ./auth-status-complete.sh - Ver estado completo"
echo "• ./test-github-token.sh - Probar conectividad"

echo ""
echo "💾 BACKUPS CREADOS:"
echo "=================="
echo "• app-config.yaml.backup.*"
echo "• packages/backend/src/index.ts.backup.*"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "====================="
echo "✅ Botón 'Sign In' visible"
echo "✅ Opción 'Sign in with GitHub' disponible"
echo "✅ Login funcional con GitHub"
echo "✅ Autenticación guest como alternativa"
