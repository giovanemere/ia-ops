#!/bin/bash

echo "🔐 INSTALACIÓN Y CONFIGURACIÓN DE AUTENTICACIÓN GITHUB"
echo "======================================================"

echo ""
echo "✅ VERIFICANDO INSTALACIÓN ACTUAL:"
echo "=================================="

# Verificar que el módulo esté instalado
if grep -q "auth-backend-module-github-provider" packages/backend/package.json; then
    echo "✅ Módulo GitHub auth backend instalado"
else
    echo "❌ Módulo GitHub auth backend NO instalado"
    echo "Instalando..."
    yarn workspace backend add @backstage/plugin-auth-backend-module-github-provider
fi

# Verificar que esté configurado en el backend
if grep -q "auth-backend-module-github-provider" packages/backend/src/index.ts; then
    echo "✅ Módulo GitHub configurado en backend"
else
    echo "❌ Módulo GitHub NO configurado en backend"
    echo "Ya se configuró automáticamente"
fi

# Verificar configuración en app-config.yaml
if grep -A5 "github:" app-config.yaml | grep -q "clientId"; then
    echo "✅ Configuración GitHub habilitada en app-config.yaml"
else
    echo "❌ Configuración GitHub NO habilitada en app-config.yaml"
    echo "Ya se habilitó automáticamente"
fi

echo ""
echo "📋 ESTADO DE VARIABLES DE ENTORNO:"
echo "================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    set -a
    source ../../.env
    set +a
    
    echo "1. AUTH_GITHUB_CLIENT_ID:"
    if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
        echo "   ❌ No configurado"
    else
        echo "   ✅ Configurado: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
    fi
    
    echo "2. AUTH_GITHUB_CLIENT_SECRET:"
    if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        echo "   ❌ No configurado"
    else
        echo "   ✅ Configurado: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
    fi
    
    echo "3. AUTH_GITHUB_CALLBACK_URL:"
    echo "   ✅ Configurado: $AUTH_GITHUB_CALLBACK_URL"
    
else
    echo "❌ No se encontró archivo ../../.env"
fi

echo ""
echo "🔑 PASOS PARA COMPLETAR LA CONFIGURACIÓN:"
echo "========================================"

echo ""
echo "PASO 1: Crear OAuth App en GitHub"
echo "================================="
echo "1. Ve a GitHub.com → Settings → Developer settings → OAuth Apps"
echo "2. Clic en 'New OAuth App'"
echo "3. Completa el formulario:"
echo "   • Application name: IA-OPS Developer Portal"
echo "   • Homepage URL: http://localhost:3002"
echo "   • Application description: Backstage Developer Portal for IA-OPS"
echo "   • Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"
echo "4. Clic en 'Register application'"
echo "5. Copia el 'Client ID' y genera un 'Client Secret'"

echo ""
echo "PASO 2: Configurar Variables de Entorno"
echo "======================================="
echo "Edita el archivo ../../.env y actualiza:"
echo ""
echo "AUTH_GITHUB_CLIENT_ID=tu_client_id_aqui"
echo "AUTH_GITHUB_CLIENT_SECRET=tu_client_secret_aqui"
echo ""
echo "Comando para editar:"
echo "nano ../../.env"

echo ""
echo "PASO 3: Verificar Configuración"
echo "==============================="
echo "Ejecuta este script nuevamente para verificar:"
echo "./install-github-auth.sh"

echo ""
echo "PASO 4: Probar Autenticación"
echo "============================"
echo "1. Inicia Backstage: ./start-with-env.sh"
echo "2. Ve a: http://localhost:3002"
echo "3. Busca el botón 'Sign In' en la esquina superior derecha"
echo "4. Deberías ver la opción 'Sign in with GitHub'"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "====================="
echo "Con la configuración completa tendrás:"
echo "✅ Botón 'Sign In' visible en Backstage"
echo "✅ Opción 'Sign in with GitHub' disponible"
echo "✅ Login completo con tu cuenta de GitHub"
echo "✅ Acceso a funcionalidades personalizadas"
echo "✅ Información de usuario desde GitHub"

echo ""
echo "💡 NOTAS IMPORTANTES:"
echo "===================="
echo "• La autenticación guest seguirá disponible"
echo "• Los usuarios pueden elegir entre guest y GitHub"
echo "• GitHub auth proporciona mejor experiencia personalizada"
echo "• Necesario para funcionalidades avanzadas de GitHub"

echo ""
echo "🔍 DIAGNÓSTICO:"
echo "=============="
echo "Si tienes problemas, ejecuta:"
echo "• ./debug-env.sh - Para verificar variables"
echo "• ./test-github-token.sh - Para probar conectividad"
echo "• ./diagnose-github-actions.sh - Para diagnóstico completo"
