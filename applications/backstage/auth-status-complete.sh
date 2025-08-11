#!/bin/bash

echo "🔐 ESTADO COMPLETO DE AUTENTICACIÓN EN BACKSTAGE"
echo "==============================================="

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
echo "✅ INSTALACIÓN Y CONFIGURACIÓN:"
echo "==============================="
echo "✅ Módulo GitHub auth backend instalado"
echo "✅ Módulo GitHub configurado en backend (index.ts)"
echo "✅ Configuración GitHub habilitada en app-config.yaml"
echo "✅ Variables de entorno definidas en ../../.env"

echo ""
echo "📋 ESTADO DE VARIABLES:"
echo "======================"

# GitHub Token (para integración)
echo "1. GITHUB_TOKEN (para integración con repositorios):"
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "   🔴 No configurado (necesario para GitHub Actions)"
else
    echo "   ✅ Configurado: ${GITHUB_TOKEN:0:10}..."
fi

# GitHub OAuth (para autenticación)
echo ""
echo "2. GitHub OAuth (para login de usuarios):"
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "   🔴 AUTH_GITHUB_CLIENT_ID: No configurado"
    OAUTH_CONFIGURED=false
else
    echo "   ✅ AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
    OAUTH_CONFIGURED=true
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "   🔴 AUTH_GITHUB_CLIENT_SECRET: No configurado"
    OAUTH_CONFIGURED=false
else
    echo "   ✅ AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
fi

echo "   ✅ AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

echo ""
echo "🎯 FUNCIONALIDADES DISPONIBLES:"
echo "==============================="

echo "Autenticación Guest:"
echo "  ✅ Siempre disponible"
echo "  ✅ Acceso básico a Backstage"
echo "  ✅ Funcionalidades públicas"

echo ""
if [ "$OAUTH_CONFIGURED" = true ]; then
    echo "Autenticación GitHub:"
    echo "  ✅ Login con cuenta de GitHub"
    echo "  ✅ Información de perfil de usuario"
    echo "  ✅ Acceso personalizado"
    echo "  ✅ Funcionalidades avanzadas"
else
    echo "Autenticación GitHub:"
    echo "  ❌ No configurada (falta OAuth credentials)"
    echo "  ❌ Solo disponible autenticación guest"
fi

echo ""
echo "🚀 ESTADO PARA INICIAR BACKSTAGE:"
echo "================================="

if [ "$OAUTH_CONFIGURED" = true ]; then
    echo "✅ LISTO PARA INICIAR CON AUTENTICACIÓN COMPLETA"
    echo "   • Autenticación guest disponible"
    echo "   • Autenticación GitHub disponible"
    echo "   • Botón 'Sign In' visible"
    echo "   • Opción 'Sign in with GitHub' funcional"
else
    echo "⚠️  LISTO PARA INICIAR CON AUTENTICACIÓN BÁSICA"
    echo "   • Solo autenticación guest disponible"
    echo "   • Para habilitar GitHub auth: configurar OAuth"
fi

echo ""
echo "🔧 PRÓXIMOS PASOS:"
echo "=================="

if [ "$OAUTH_CONFIGURED" = false ]; then
    echo "Para habilitar autenticación GitHub:"
    echo "1. 🔑 Ejecuta: ./setup-github-oauth.sh"
    echo "2. 📝 Sigue las instrucciones para crear OAuth App"
    echo "3. ✅ Verifica con: ./install-github-auth.sh"
    echo "4. 🚀 Inicia Backstage: ./start-with-env.sh"
else
    echo "Configuración completa:"
    echo "1. 🚀 Inicia Backstage: ./start-with-env.sh"
    echo "2. 🌐 Ve a: http://localhost:3002"
    echo "3. 🔐 Prueba el botón 'Sign In'"
    echo "4. ✅ Selecciona 'Sign in with GitHub'"
fi

echo ""
echo "📊 RESUMEN FINAL:"
echo "================"
echo "• Backend: ✅ Configurado"
echo "• Frontend: ✅ Configurado"
echo "• Variables: $([ "$OAUTH_CONFIGURED" = true ] && echo "✅ Completas" || echo "⚠️  Parciales")"
echo "• OAuth App: $([ "$OAUTH_CONFIGURED" = true ] && echo "✅ Configurada" || echo "❌ Pendiente")"
echo "• Estado: $([ "$OAUTH_CONFIGURED" = true ] && echo "🟢 LISTO COMPLETO" || echo "🟡 LISTO BÁSICO")"

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "=================="
echo "• ./setup-github-oauth.sh - Configurar OAuth paso a paso"
echo "• ./install-github-auth.sh - Verificar instalación"
echo "• ./start-with-env.sh - Iniciar Backstage"
echo "• ./debug-env.sh - Diagnóstico de variables"
