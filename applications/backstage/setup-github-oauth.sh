#!/bin/bash

echo "🔐 CONFIGURACIÓN PASO A PASO DE GITHUB OAUTH"
echo "============================================="

echo ""
echo "📋 INFORMACIÓN NECESARIA PARA GITHUB OAUTH APP:"
echo "==============================================="
echo "Application name: IA-OPS Developer Portal"
echo "Homepage URL: http://localhost:3002"
echo "Application description: Backstage Developer Portal for IA-OPS"
echo "Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"

echo ""
echo "🌐 PASOS DETALLADOS:"
echo "==================="
echo "1. Abre tu navegador y ve a: https://github.com/settings/developers"
echo "2. Clic en 'OAuth Apps' en el menú lateral"
echo "3. Clic en 'New OAuth App'"
echo "4. Completa el formulario con la información de arriba"
echo "5. Clic en 'Register application'"
echo "6. Copia el 'Client ID'"
echo "7. Clic en 'Generate a new client secret'"
echo "8. Copia el 'Client Secret' (solo se muestra una vez)"

echo ""
echo "⚠️  IMPORTANTE: Guarda las credenciales de forma segura"

echo ""
read -p "¿Ya tienes el Client ID y Client Secret? (y/n): " has_credentials

if [ "$has_credentials" = "y" ] || [ "$has_credentials" = "Y" ]; then
    echo ""
    echo "📝 CONFIGURANDO VARIABLES DE ENTORNO:"
    echo "===================================="
    
    read -p "Ingresa tu GitHub OAuth Client ID: " client_id
    read -s -p "Ingresa tu GitHub OAuth Client Secret: " client_secret
    echo ""
    
    if [ ! -z "$client_id" ] && [ ! -z "$client_secret" ]; then
        # Actualizar el archivo .env
        echo "Actualizando archivo ../../.env..."
        
        # Backup del archivo original
        cp ../../.env ../../.env.backup.$(date +%Y%m%d_%H%M%S)
        
        # Actualizar las variables
        sed -i "s/AUTH_GITHUB_CLIENT_ID=.*/AUTH_GITHUB_CLIENT_ID=$client_id/" ../../.env
        sed -i "s/AUTH_GITHUB_CLIENT_SECRET=.*/AUTH_GITHUB_CLIENT_SECRET=$client_secret/" ../../.env
        
        echo "✅ Variables actualizadas en ../../.env"
        echo "✅ Backup creado: ../../.env.backup.*"
        
        echo ""
        echo "🧪 VERIFICANDO CONFIGURACIÓN:"
        echo "============================"
        
        # Cargar y verificar variables
        set -a
        source ../../.env
        set +a
        
        echo "Client ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
        echo "Client Secret: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
        echo "Callback URL: $AUTH_GITHUB_CALLBACK_URL"
        
        echo ""
        echo "✅ CONFIGURACIÓN COMPLETADA"
        echo "=========================="
        echo "Ahora puedes:"
        echo "1. Ejecutar: ./install-github-auth.sh (para verificar)"
        echo "2. Ejecutar: ./start-with-env.sh (para iniciar Backstage)"
        echo "3. Ir a: http://localhost:3002"
        echo "4. Buscar el botón 'Sign In' y probar 'Sign in with GitHub'"
        
    else
        echo "❌ Client ID o Client Secret vacíos. Configuración cancelada."
    fi
else
    echo ""
    echo "📖 INSTRUCCIONES DETALLADAS:"
    echo "============================"
    echo "1. Ve a: https://github.com/settings/developers"
    echo "2. Clic en 'OAuth Apps'"
    echo "3. Clic en 'New OAuth App'"
    echo "4. Usa esta configuración:"
    echo ""
    echo "   Application name: IA-OPS Developer Portal"
    echo "   Homepage URL: http://localhost:3002"
    echo "   Application description: Backstage Developer Portal for IA-OPS"
    echo "   Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"
    echo ""
    echo "5. Después de crear la app, ejecuta este script nuevamente"
    echo ""
    echo "💡 TIP: Puedes ejecutar este script las veces que necesites"
fi

echo ""
echo "🔍 SCRIPTS DE DIAGNÓSTICO:"
echo "========================="
echo "• ./install-github-auth.sh - Verificar instalación completa"
echo "• ./test-github-token.sh - Probar conectividad con GitHub"
echo "• ./debug-env.sh - Verificar todas las variables de entorno"
