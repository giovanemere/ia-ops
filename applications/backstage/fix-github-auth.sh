#!/bin/bash

# =============================================================================
# CORRECCIÓN DE AUTENTICACIÓN GITHUB
# =============================================================================

set -e

echo "🔧 Corrigiendo autenticación de GitHub..."
echo "========================================"

# Cargar variables de entorno
BASE_DIR="/home/giovanemere/ia-ops/ia-ops"
source "$BASE_DIR/.env"

echo "✅ Variables cargadas:"
echo "   • AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
echo "   • AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
echo "   • AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

# 1. Detener procesos actuales
echo ""
echo "1. Deteniendo procesos actuales..."
echo "================================="
pkill -f "yarn.*backstage" 2>/dev/null || true
pkill -f "yarn.*backend" 2>/dev/null || true
pkill -f "yarn.*start" 2>/dev/null || true
sleep 3
echo "✅ Procesos detenidos"

# 2. Verificar configuración en app-config.yaml
echo ""
echo "2. Verificando configuración..."
echo "=============================="

if grep -q "clientId: \${AUTH_GITHUB_CLIENT_ID}" app-config.yaml; then
    echo "✅ Configuración de clientId encontrada"
else
    echo "❌ Configuración de clientId no encontrada"
fi

if grep -q "clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}" app-config.yaml; then
    echo "✅ Configuración de clientSecret encontrada"
else
    echo "❌ Configuración de clientSecret no encontrada"
fi

# 3. Crear archivo de configuración temporal con valores explícitos
echo ""
echo "3. Creando configuración temporal..."
echo "==================================="

cat > app-config.temp.yaml << EOF
# Configuración temporal para GitHub Auth
auth:
  providers:
    guest: {}
    github:
      development:
        clientId: $AUTH_GITHUB_CLIENT_ID
        clientSecret: $AUTH_GITHUB_CLIENT_SECRET
        callbackUrl: $AUTH_GITHUB_CALLBACK_URL
EOF

echo "✅ Configuración temporal creada"

# 4. Iniciar solo el backend para probar
echo ""
echo "4. Probando backend con configuración explícita..."
echo "================================================="

# Exportar variables explícitamente
export AUTH_GITHUB_CLIENT_ID="$AUTH_GITHUB_CLIENT_ID"
export AUTH_GITHUB_CLIENT_SECRET="$AUTH_GITHUB_CLIENT_SECRET"
export AUTH_GITHUB_CALLBACK_URL="$AUTH_GITHUB_CALLBACK_URL"
export BACKEND_SECRET="$BACKEND_SECRET"
export GITHUB_TOKEN="$GITHUB_TOKEN"

# Iniciar backend con timeout para probar
echo "🚀 Iniciando backend de prueba..."
timeout 30s yarn workspace backend start --config app-config.yaml --config app-config.temp.yaml 2>&1 | grep -E "(auth|github|error|warn)" | head -10 || true

echo ""
echo "5. Limpiando archivos temporales..."
echo "=================================="
rm -f app-config.temp.yaml
echo "✅ Archivos temporales eliminados"

echo ""
echo "6. Iniciando con configuración corregida..."
echo "=========================================="

# Iniciar en segundo plano con todas las variables exportadas
nohup bash -c "
export AUTH_GITHUB_CLIENT_ID='$AUTH_GITHUB_CLIENT_ID'
export AUTH_GITHUB_CLIENT_SECRET='$AUTH_GITHUB_CLIENT_SECRET'
export AUTH_GITHUB_CALLBACK_URL='$AUTH_GITHUB_CALLBACK_URL'
export BACKEND_SECRET='$BACKEND_SECRET'
export GITHUB_TOKEN='$GITHUB_TOKEN'
export POSTGRES_HOST='$POSTGRES_HOST'
export POSTGRES_PORT='$POSTGRES_PORT'
export POSTGRES_USER='$POSTGRES_USER'
export POSTGRES_PASSWORD='$POSTGRES_PASSWORD'
export POSTGRES_DB='$POSTGRES_DB'
yarn start
" > github-auth-fix.log 2>&1 &

echo "✅ Backstage iniciado con variables exportadas"
echo ""
echo "🔍 Para verificar el estado:"
echo "   tail -f github-auth-fix.log | grep -E '(auth|github|error|warn)'"
echo ""
echo "🌐 Una vez iniciado, accede a:"
echo "   http://localhost:3002"
echo ""
echo "✨ La autenticación de GitHub debería funcionar ahora"
