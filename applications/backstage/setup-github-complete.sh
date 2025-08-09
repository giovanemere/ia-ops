#!/bin/bash

echo "🔧 CONFIGURACIÓN COMPLETA DE GITHUB PARA BACKSTAGE"
echo "=================================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    echo "✅ Cargando variables de entorno desde ../../.env"
    set -a
    source ../../.env
    set +a
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

echo ""
echo "📋 ESTADO ACTUAL DE GITHUB:"
echo "=========================="

# 1. Verificar GitHub Token (para integración con repositorios)
echo "1. GitHub Personal Access Token (para integración):"
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "   ❌ GITHUB_TOKEN no está configurado"
    echo "   📝 NECESARIO para: GitHub Actions, repositorios, integración"
else
    echo "   ✅ GITHUB_TOKEN está configurado"
    echo "   🔧 Token: ${GITHUB_TOKEN:0:10}..."
fi

# 2. Verificar GitHub OAuth (para autenticación de usuarios)
echo ""
echo "2. GitHub OAuth (para autenticación de usuarios):"
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "   ⚠️  AUTH_GITHUB_CLIENT_ID no está configurado"
    echo "   📝 OPCIONAL para: Login con GitHub"
else
    echo "   ✅ AUTH_GITHUB_CLIENT_ID está configurado"
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "   ⚠️  AUTH_GITHUB_CLIENT_SECRET no está configurado"
    echo "   📝 OPCIONAL para: Login con GitHub"
else
    echo "   ✅ AUTH_GITHUB_CLIENT_SECRET está configurado"
fi

echo "   🔧 Callback URL: $AUTH_GITHUB_CALLBACK_URL"

echo ""
echo "🔑 CONFIGURACIÓN REQUERIDA:"
echo "=========================="

echo ""
echo "PASO 1: Personal Access Token (OBLIGATORIO para GitHub Actions)"
echo "================================================================"
echo "1. Ve a GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)"
echo "2. Clic en 'Generate new token (classic)'"
echo "3. Nombre: 'Backstage Integration'"
echo "4. Selecciona estos permisos:"
echo "   ☐ repo (Full control of private repositories)"
echo "   ☐ workflow (Update GitHub Action workflows)"
echo "   ☐ read:org (Read org and team membership)"
echo "   ☐ read:user (Read user profile data)"
echo "   ☐ user:email (Access user email addresses)"
echo "5. Copia el token generado (empieza con 'ghp_')"
echo ""
echo "6. Actualiza ../../.env:"
echo "   GITHUB_TOKEN=tu_token_personal_aqui"

echo ""
echo "PASO 2: OAuth App (OPCIONAL para login con GitHub)"
echo "=================================================="
echo "1. Ve a GitHub.com → Settings → Developer settings → OAuth Apps"
echo "2. Clic en 'New OAuth App'"
echo "3. Configuración:"
echo "   • Application name: IA-OPS Developer Portal"
echo "   • Homepage URL: http://localhost:3002"
echo "   • Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame"
echo "4. Copia Client ID y Client Secret"
echo ""
echo "5. Actualiza ../../.env:"
echo "   AUTH_GITHUB_CLIENT_ID=tu_client_id_aqui"
echo "   AUTH_GITHUB_CLIENT_SECRET=tu_client_secret_aqui"

echo ""
echo "🧪 PRUEBAS DISPONIBLES:"
echo "======================"
echo "• Probar Personal Access Token:"
echo "  ./test-github-token.sh"
echo ""
echo "• Diagnóstico completo de GitHub:"
echo "  ./diagnose-github-actions.sh"

echo ""
echo "📊 FUNCIONALIDADES POR CONFIGURACIÓN:"
echo "===================================="
echo "Solo con GITHUB_TOKEN:"
echo "  ✅ GitHub Actions"
echo "  ✅ Integración con repositorios"
echo "  ✅ Scaffolder con GitHub"
echo "  ✅ TechDocs desde GitHub"
echo ""
echo "Con GITHUB_TOKEN + OAuth:"
echo "  ✅ Todo lo anterior"
echo "  ✅ Login con GitHub"
echo "  ✅ Autenticación de usuarios"

echo ""
echo "🚀 DESPUÉS DE CONFIGURAR:"
echo "========================"
echo "1. Ejecuta: ./test-github-token.sh (para verificar)"
echo "2. Ejecuta: ./start-with-env.sh (para iniciar Backstage)"
echo "3. Ve a: http://localhost:3002"

echo ""
echo "💡 PRIORIDADES:"
echo "=============="
echo "1. 🔴 CRÍTICO: Configurar GITHUB_TOKEN (para GitHub Actions)"
echo "2. 🟡 OPCIONAL: Configurar OAuth (para login con GitHub)"
echo "3. 🟢 LISTO: Todo lo demás ya está configurado"
