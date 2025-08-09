#!/bin/bash

echo "🔐 CONFIGURAR GITHUB OAUTH CREDENTIALS"
echo "======================================"

echo ""
echo "📋 ESTADO ACTUAL:"
echo "================"

# Verificar estado actual
source ../../.env
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "❌ AUTH_GITHUB_CLIENT_ID: Vacío"
else
    echo "✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "❌ AUTH_GITHUB_CLIENT_SECRET: Vacío"
else
    echo "✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
fi

echo "✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

echo ""
echo "🔑 CONFIGURACIÓN INTERACTIVA:"
echo "============================"

read -p "¿Ya tienes el Client ID de GitHub? (y/n): " has_client_id

if [ "$has_client_id" = "y" ] || [ "$has_client_id" = "Y" ]; then
    echo ""
    read -p "Ingresa tu GitHub Client ID: " client_id
    
    if [ ! -z "$client_id" ]; then
        echo ""
        read -p "¿Ya tienes el Client Secret de GitHub? (y/n): " has_client_secret
        
        if [ "$has_client_secret" = "y" ] || [ "$has_client_secret" = "Y" ]; then
            echo ""
            read -s -p "Ingresa tu GitHub Client Secret: " client_secret
            echo ""
            
            if [ ! -z "$client_secret" ]; then
                echo ""
                echo "🔧 ACTUALIZANDO ARCHIVO .env:"
                echo "============================"
                
                # Crear backup
                cp ../../.env ../../.env.backup.$(date +%Y%m%d_%H%M%S)
                echo "✅ Backup creado: ../../.env.backup.*"
                
                # Actualizar las variables
                sed -i "s/^AUTH_GITHUB_CLIENT_ID=.*/AUTH_GITHUB_CLIENT_ID=$client_id/" ../../.env
                sed -i "s/^AUTH_GITHUB_CLIENT_SECRET=.*/AUTH_GITHUB_CLIENT_SECRET=$client_secret/" ../../.env
                
                echo "✅ Variables actualizadas en ../../.env"
                
                # Verificar actualización
                echo ""
                echo "🧪 VERIFICANDO ACTUALIZACIÓN:"
                echo "============================"
                source ../../.env
                echo "✅ CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:15}..."
                echo "✅ CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:15}..."
                
                echo ""
                echo "🚀 PRÓXIMOS PASOS:"
                echo "=================="
                echo "1. Habilitar GitHub OAuth:"
                echo "   ./enable-github-oauth.sh"
                echo ""
                echo "2. Iniciar Backstage:"
                echo "   ./start-with-env.sh"
                echo ""
                echo "3. Probar login en:"
                echo "   http://localhost:3002"
                
            else
                echo "❌ Client Secret vacío. Configuración cancelada."
            fi
        else
            echo ""
            echo "📖 NECESITAS EL CLIENT SECRET:"
            echo "============================="
            echo "1. Ve a tu OAuth App en GitHub"
            echo "2. Clic en 'Generate a new client secret'"
            echo "3. Copia el secret (solo se muestra una vez)"
            echo "4. Ejecuta este script nuevamente"
        fi
    else
        echo "❌ Client ID vacío. Configuración cancelada."
    fi
else
    echo ""
    echo "📖 CREAR OAUTH APP EN GITHUB:"
    echo "============================"
    echo "1. Ve a: https://github.com/settings/developers"
    echo "2. Clic en 'OAuth Apps' → 'New OAuth App'"
    echo "3. Usa esta configuración:"
    echo ""
    echo "   Application name: IA-OPS Developer Portal"
    echo "   Homepage URL: http://localhost:3002"
    echo "   Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"
    echo ""
    echo "4. Después de crear la app, ejecuta este script nuevamente"
fi

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• Ver archivo .env: cat ../../.env | grep AUTH_GITHUB"
echo "• Editar manualmente: nano ../../.env"
echo "• Verificar estado: ./auth-status-complete.sh"
