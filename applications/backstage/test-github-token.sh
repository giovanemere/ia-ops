#!/bin/bash

echo "🔍 PRUEBA COMPLETA DE CONFIGURACIÓN DE GITHUB"
echo "============================================="

# Load environment variables from main .env file
if [ -f "../../.env" ]; then
    echo "✅ Loading environment variables from ../../.env"
    set -a
    source ../../.env
    set +a
else
    echo "❌ Cannot find ../../.env file"
    exit 1
fi

echo ""
echo "📋 VERIFICANDO VARIABLES:"
echo "========================"

# 1. GitHub Token
echo "1. GitHub Personal Access Token:"
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "   ❌ GITHUB_TOKEN is not set or still has placeholder value"
    echo "   Current value: $GITHUB_TOKEN"
    GITHUB_TOKEN_OK=false
else
    echo "   ✅ GITHUB_TOKEN is set"
    echo "   🔧 Token: ${GITHUB_TOKEN:0:10}..."
    GITHUB_TOKEN_OK=true
fi

# 2. GitHub OAuth
echo ""
echo "2. GitHub OAuth Configuration:"
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "   ⚠️  AUTH_GITHUB_CLIENT_ID is not set (optional)"
    OAUTH_OK=false
else
    echo "   ✅ AUTH_GITHUB_CLIENT_ID is set"
    echo "   🔧 Client ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
    OAUTH_OK=true
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "   ⚠️  AUTH_GITHUB_CLIENT_SECRET is not set (optional)"
else
    echo "   ✅ AUTH_GITHUB_CLIENT_SECRET is set"
    echo "   🔧 Client Secret: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
fi

echo "   🔧 Callback URL: $AUTH_GITHUB_CALLBACK_URL"

if [ "$GITHUB_TOKEN_OK" = true ]; then
    echo ""
    echo "🌐 PROBANDO CONECTIVIDAD CON GITHUB API:"
    echo "======================================="
    
    # Test the token
    echo "Testing GitHub API access..."
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)

    if echo "$response" | grep -q '"login"'; then
        username=$(echo "$response" | grep '"login"' | cut -d'"' -f4)
        echo "✅ GitHub token is valid! Authenticated as: $username"
        
        # Get user info
        name=$(echo "$response" | grep '"name"' | cut -d'"' -f4)
        if [ "$name" != "null" ] && [ ! -z "$name" ]; then
            echo "👤 Name: $name"
        fi
        
        # Test repository access
        echo ""
        echo "Testing access to your repositories..."
        repos_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/repos?per_page=5)

        if echo "$repos_response" | grep -q '"name"'; then
            echo "✅ Can access your repositories"
            echo "📁 Recent repositories:"
            echo "$repos_response" | grep '"full_name"' | head -5 | cut -d'"' -f4 | sed 's/^/   • /'
        else
            echo "❌ Cannot access repositories"
        fi
        
        # Test workflow access
        echo ""
        echo "Testing GitHub Actions access..."
        # Get first repo to test workflows
        first_repo=$(echo "$repos_response" | grep '"full_name"' | head -1 | cut -d'"' -f4)
        if [ ! -z "$first_repo" ]; then
            workflows_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$first_repo/actions/workflows")
            if echo "$workflows_response" | grep -q '"workflows"'; then
                workflow_count=$(echo "$workflows_response" | grep -o '"total_count":[0-9]*' | cut -d':' -f2)
                echo "✅ GitHub Actions access working ($workflow_count workflows found in $first_repo)"
            else
                echo "⚠️  No workflows found or limited access to GitHub Actions"
            fi
        fi
        
    else
        echo "❌ GitHub token is invalid or expired"
        echo "Response: $response"
    fi
else
    echo ""
    echo "⚠️  Cannot test GitHub API - token not configured"
    echo "Please configure GITHUB_TOKEN first"
fi

echo ""
echo "📊 RESUMEN DE FUNCIONALIDADES:"
echo "============================="

if [ "$GITHUB_TOKEN_OK" = true ]; then
    echo "✅ GitHub Actions - FUNCIONARÁ"
    echo "✅ Repository integration - FUNCIONARÁ"
    echo "✅ Scaffolder with GitHub - FUNCIONARÁ"
    echo "✅ TechDocs from GitHub - FUNCIONARÁ"
else
    echo "❌ GitHub Actions - NO FUNCIONARÁ (falta token)"
    echo "❌ Repository integration - NO FUNCIONARÁ (falta token)"
    echo "❌ Scaffolder with GitHub - NO FUNCIONARÁ (falta token)"
    echo "❌ TechDocs from GitHub - NO FUNCIONARÁ (falta token)"
fi

if [ "$OAUTH_OK" = true ]; then
    echo "✅ GitHub Login - FUNCIONARÁ"
    echo "✅ User authentication - FUNCIONARÁ"
else
    echo "⚠️  GitHub Login - NO CONFIGURADO (opcional)"
    echo "⚠️  User authentication - USARÁ GUEST (por defecto)"
fi

echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "================="

if [ "$GITHUB_TOKEN_OK" = false ]; then
    echo "🔴 CRÍTICO: Configurar GITHUB_TOKEN"
    echo "   1. Ejecuta: ./setup-github-complete.sh"
    echo "   2. Sigue las instrucciones para crear Personal Access Token"
    echo "   3. Actualiza ../../.env con tu token"
    echo "   4. Vuelve a ejecutar este script para verificar"
else
    echo "✅ GitHub Token configurado correctamente"
    echo "🚀 Puedes iniciar Backstage: ./start-with-env.sh"
    
    if [ "$OAUTH_OK" = false ]; then
        echo ""
        echo "💡 OPCIONAL: Para habilitar login con GitHub:"
        echo "   1. Ejecuta: ./setup-github-complete.sh"
        echo "   2. Sigue las instrucciones de OAuth App"
    fi
fi
