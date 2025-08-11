#!/bin/bash

echo "🔧 ACTUALIZANDO CONFIGURACIÓN DE GITHUB OAUTH"
echo "============================================="

echo ""
echo "📋 VERIFICANDO VARIABLES EN ../../.env:"
echo "======================================="

# Cargar variables del archivo .env
if [ -f "../../.env" ]; then
    source ../../.env
    echo "✅ Archivo .env cargado"
else
    echo "❌ No se encontró ../../.env"
    exit 1
fi

echo "🔍 Variables encontradas:"
echo "  AUTH_GITHUB_CLIENT_ID: '${AUTH_GITHUB_CLIENT_ID}'"
echo "  AUTH_GITHUB_CLIENT_SECRET: '${AUTH_GITHUB_CLIENT_SECRET}'"
echo "  AUTH_GITHUB_CALLBACK_URL: '${AUTH_GITHUB_CALLBACK_URL}'"

echo ""
echo "🔧 ACTUALIZANDO app-config.yaml:"
echo "================================"

# Crear backup del archivo
cp app-config.yaml app-config.yaml.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup creado: app-config.yaml.backup.*"

# Verificar si GitHub OAuth está habilitado o comentado
if grep -q "^    # github:" app-config.yaml; then
    echo "⚠️  GitHub OAuth está comentado en app-config.yaml"
    
    if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        echo "✅ Credenciales encontradas, habilitando GitHub OAuth..."
        
        # Descomentar y habilitar GitHub OAuth
        sed -i 's/^    # GitHub OAuth Authentication (disabled until credentials are configured)/    # GitHub OAuth Authentication/' app-config.yaml
        sed -i 's/^    # Uncomment and configure when you have GitHub OAuth credentials//' app-config.yaml
        sed -i 's/^    # github:/    github:/' app-config.yaml
        sed -i 's/^    #   development:/      development:/' app-config.yaml
        sed -i 's/^    #     clientId: \${AUTH_GITHUB_CLIENT_ID}/        clientId: \${AUTH_GITHUB_CLIENT_ID}/' app-config.yaml
        sed -i 's/^    #     clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}/        clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}/' app-config.yaml
        sed -i 's/^    #     callbackUrl: \${AUTH_GITHUB_CALLBACK_URL}/        callbackUrl: \${AUTH_GITHUB_CALLBACK_URL}/' app-config.yaml
        
        echo "✅ GitHub OAuth habilitado en app-config.yaml"
    else
        echo "⚠️  Credenciales vacías, manteniendo GitHub OAuth deshabilitado"
        echo "💡 Para habilitar: agrega credenciales en ../../.env y ejecuta este script nuevamente"
    fi
elif grep -q "^    github:" app-config.yaml; then
    echo "✅ GitHub OAuth ya está habilitado en app-config.yaml"
else
    echo "❌ No se encontró configuración de GitHub OAuth en app-config.yaml"
    echo "🔧 Agregando configuración de GitHub OAuth..."
    
    # Buscar la línea de guest y agregar GitHub después
    if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        # Agregar configuración habilitada
        sed -i '/guest: {}/a\    # GitHub OAuth Authentication\n    github:\n      development:\n        clientId: ${AUTH_GITHUB_CLIENT_ID}\n        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}\n        callbackUrl: ${AUTH_GITHUB_CALLBACK_URL}' app-config.yaml
        echo "✅ Configuración de GitHub OAuth agregada y habilitada"
    else
        # Agregar configuración comentada
        sed -i '/guest: {}/a\    # GitHub OAuth Authentication (disabled until credentials are configured)\n    # github:\n    #   development:\n    #     clientId: ${AUTH_GITHUB_CLIENT_ID}\n    #     clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}\n    #     callbackUrl: ${AUTH_GITHUB_CALLBACK_URL}' app-config.yaml
        echo "✅ Configuración de GitHub OAuth agregada (deshabilitada)"
    fi
fi

echo ""
echo "🔧 ACTUALIZANDO packages/backend/src/index.ts:"
echo "=============================================="

# Crear backup del backend
cp packages/backend/src/index.ts packages/backend/src/index.ts.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup creado: packages/backend/src/index.ts.backup.*"

# Verificar si el módulo de GitHub está habilitado
if grep -q "^// backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));" packages/backend/src/index.ts; then
    echo "⚠️  Módulo GitHub OAuth está comentado en backend"
    
    if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        echo "✅ Credenciales encontradas, habilitando módulo GitHub OAuth..."
        sed -i 's|^// backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));|backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));|' packages/backend/src/index.ts
        echo "✅ Módulo GitHub OAuth habilitado en backend"
    else
        echo "⚠️  Credenciales vacías, manteniendo módulo deshabilitado"
    fi
elif grep -q "^backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));" packages/backend/src/index.ts; then
    echo "✅ Módulo GitHub OAuth ya está habilitado en backend"
else
    echo "❌ No se encontró módulo GitHub OAuth en backend"
    echo "🔧 Agregando módulo GitHub OAuth..."
    
    # Buscar la línea del guest provider y agregar GitHub después
    if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        sed -i '/plugin-auth-backend-module-guest-provider/a backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));' packages/backend/src/index.ts
        echo "✅ Módulo GitHub OAuth agregado y habilitado"
    else
        sed -i '/plugin-auth-backend-module-guest-provider/a // backend.add(import('\''@backstage/plugin-auth-backend-module-github-provider'\''));' packages/backend/src/index.ts
        echo "✅ Módulo GitHub OAuth agregado (deshabilitado)"
    fi
fi

echo ""
echo "📊 VERIFICANDO CONFIGURACIÓN FINAL:"
echo "==================================="

# Verificar configuración en app-config.yaml
echo "app-config.yaml:"
if grep -A5 "github:" app-config.yaml | grep -q "clientId"; then
    echo "  ✅ GitHub OAuth configurado"
    echo "  🔧 clientId: \${AUTH_GITHUB_CLIENT_ID}"
    echo "  🔧 clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}"
    echo "  🔧 callbackUrl: \${AUTH_GITHUB_CALLBACK_URL}"
else
    echo "  ⚠️  GitHub OAuth deshabilitado (esperando credenciales)"
fi

# Verificar módulo en backend
echo ""
echo "packages/backend/src/index.ts:"
if grep -q "^backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));" packages/backend/src/index.ts; then
    echo "  ✅ Módulo GitHub OAuth habilitado"
else
    echo "  ⚠️  Módulo GitHub OAuth deshabilitado (esperando credenciales)"
fi

echo ""
echo "🎯 ESTADO FINAL:"
echo "==============="

if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "✅ CONFIGURACIÓN COMPLETA"
    echo "  • Variables definidas en ../../.env"
    echo "  • GitHub OAuth habilitado en app-config.yaml"
    echo "  • Módulo habilitado en backend"
    echo ""
    echo "🚀 PRÓXIMOS PASOS:"
    echo "  1. Iniciar Backstage: ./start-with-env.sh"
    echo "  2. Ir a: http://localhost:3002"
    echo "  3. Buscar botón 'Sign In'"
    echo "  4. Probar 'Sign in with GitHub'"
else
    echo "⚠️  CONFIGURACIÓN PREPARADA"
    echo "  • Variables definidas en ../../.env (vacías)"
    echo "  • GitHub OAuth deshabilitado hasta tener credenciales"
    echo "  • Configuración lista para habilitar"
    echo ""
    echo "🔑 PARA COMPLETAR:"
    echo "  1. Agregar credenciales en ../../.env:"
    echo "     AUTH_GITHUB_CLIENT_ID=tu_client_id"
    echo "     AUTH_GITHUB_CLIENT_SECRET=tu_client_secret"
    echo "  2. Ejecutar este script nuevamente"
    echo "  3. Iniciar Backstage: ./start-with-env.sh"
fi

echo ""
echo "💾 BACKUPS CREADOS:"
echo "=================="
echo "• app-config.yaml.backup.*"
echo "• packages/backend/src/index.ts.backup.*"
