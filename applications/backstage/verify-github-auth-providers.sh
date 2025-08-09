#!/bin/bash

echo "🔍 VERIFICACIÓN DE AUTH PROVIDERS - GITHUB"
echo "=========================================="

echo ""
echo "📋 VERIFICANDO app-config.yaml:"
echo "==============================="

# Verificar sección auth.providers
echo "Sección auth.providers:"
if grep -A10 "auth:" app-config.yaml | grep -A8 "providers:" | grep -q "github:"; then
    echo "  ✅ GitHub configurado en auth.providers"
else
    echo "  ❌ GitHub NO configurado en auth.providers"
fi

# Mostrar configuración actual
echo ""
echo "Configuración actual:"
echo "--------------------"
grep -A15 "providers:" app-config.yaml | head -15

echo ""
echo "📋 VERIFICANDO packages/backend/src/index.ts:"
echo "============================================="

# Verificar módulo en backend
if grep -q "^backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));" packages/backend/src/index.ts; then
    echo "  ✅ Módulo GitHub habilitado en backend"
else
    echo "  ❌ Módulo GitHub NO habilitado en backend"
fi

echo ""
echo "📋 VERIFICANDO VARIABLES DE ENTORNO:"
echo "==================================="

# Cargar variables
source ../../.env

echo "AUTH_GITHUB_CLIENT_ID: '${AUTH_GITHUB_CLIENT_ID}'"
echo "AUTH_GITHUB_CLIENT_SECRET: '${AUTH_GITHUB_CLIENT_SECRET}'"
echo "AUTH_GITHUB_CALLBACK_URL: '${AUTH_GITHUB_CALLBACK_URL}'"

echo ""
echo "🎯 ESTADO DE CONFIGURACIÓN:"
echo "=========================="

# Verificar estado completo
GITHUB_IN_CONFIG=$(grep -A10 "auth:" app-config.yaml | grep -A8 "providers:" | grep -c "github:")
GITHUB_MODULE_ENABLED=$(grep -c "^backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));" packages/backend/src/index.ts)

if [ "$GITHUB_IN_CONFIG" -gt 0 ] && [ "$GITHUB_MODULE_ENABLED" -gt 0 ]; then
    echo "✅ GITHUB OAUTH COMPLETAMENTE CONFIGURADO"
    echo "  • Presente en auth.providers"
    echo "  • Módulo habilitado en backend"
    echo "  • Variables referenciadas correctamente"
    
    if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
        echo "  • Credenciales configuradas"
        echo ""
        echo "🚀 LISTO PARA USAR:"
        echo "  ./start-with-env.sh"
    else
        echo "  • Credenciales pendientes"
        echo ""
        echo "⚠️  NECESITA CREDENCIALES:"
        echo "  1. Editar ../../.env"
        echo "  2. Agregar CLIENT_ID y CLIENT_SECRET"
        echo "  3. Iniciar: ./start-with-env.sh"
    fi
else
    echo "❌ GITHUB OAUTH INCOMPLETO"
    if [ "$GITHUB_IN_CONFIG" -eq 0 ]; then
        echo "  • Falta en auth.providers"
    fi
    if [ "$GITHUB_MODULE_ENABLED" -eq 0 ]; then
        echo "  • Módulo no habilitado en backend"
    fi
fi

echo ""
echo "📊 RESUMEN TÉCNICO:"
echo "=================="
echo "• auth.providers.github: $([ "$GITHUB_IN_CONFIG" -gt 0 ] && echo "✅ Configurado" || echo "❌ Faltante")"
echo "• backend module: $([ "$GITHUB_MODULE_ENABLED" -gt 0 ] && echo "✅ Habilitado" || echo "❌ Deshabilitado")"
echo "• variables: $([ -n "$AUTH_GITHUB_CALLBACK_URL" ] && echo "✅ Definidas" || echo "❌ Faltantes")"
echo "• credenciales: $([ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ] && echo "✅ Configuradas" || echo "⚠️  Pendientes")"
