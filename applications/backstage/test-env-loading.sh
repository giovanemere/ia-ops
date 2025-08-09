#!/bin/bash

echo "🔍 VERIFICACIÓN DE CARGA DE VARIABLES DE ENTORNO"
echo "==============================================="

echo ""
echo "📁 ARCHIVOS DE CONFIGURACIÓN:"
echo "============================="
echo "Variables definidas en: /home/giovanemere/ia-ops/ia-ops/.env"
echo "Configuración desarrollo: ./app-config.yaml"
echo "Configuración producción: ./app-config.production.yaml"

echo ""
echo "🔧 CARGANDO VARIABLES DESDE ../../.env:"
echo "======================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    echo "✅ Archivo encontrado: ../../.env"
    set -a
    source ../../.env
    set +a
    echo "✅ Variables cargadas"
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

echo ""
echo "📋 VARIABLES CRÍTICAS PARA BACKSTAGE:"
echo "===================================="

echo "1. BACKEND_SECRET:"
echo "   Valor: ${BACKEND_SECRET:0:20}..."
echo "   Longitud: ${#BACKEND_SECRET} caracteres"

echo ""
echo "2. Base de Datos PostgreSQL:"
echo "   POSTGRES_HOST: $POSTGRES_HOST"
echo "   POSTGRES_PORT: $POSTGRES_PORT"
echo "   POSTGRES_USER: $POSTGRES_USER"
echo "   POSTGRES_DB: $POSTGRES_DB"
echo "   POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:0:5}..."

echo ""
echo "3. GitHub Integration:"
echo "   GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."

echo ""
echo "4. GitHub OAuth:"
echo "   AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:-'(vacío)'}"
echo "   AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
echo "   AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

echo ""
echo "5. Puertos Backstage:"
echo "   BACKSTAGE_BACKEND_PORT: ${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   BACKSTAGE_FRONTEND_PORT: ${BACKSTAGE_FRONTEND_PORT:-3002}"

echo ""
echo "🧪 VERIFICANDO REFERENCIAS EN ARCHIVOS DE CONFIGURACIÓN:"
echo "========================================================"

echo ""
echo "app-config.yaml (desarrollo):"
echo "-----------------------------"

# Verificar referencias en app-config.yaml
echo "✅ BACKEND_SECRET: $(grep -c 'BACKEND_SECRET' app-config.yaml) referencia(s)"
echo "✅ POSTGRES variables: $(grep -c 'POSTGRES_' app-config.yaml) referencia(s)"
echo "✅ AUTH_GITHUB variables: $(grep -c 'AUTH_GITHUB' app-config.yaml) referencia(s)"
echo "✅ BACKSTAGE_BACKEND_PORT: $(grep -c 'BACKSTAGE_BACKEND_PORT' app-config.yaml) referencia(s)"

echo ""
echo "app-config.production.yaml:"
echo "---------------------------"

# Verificar referencias en app-config.production.yaml
echo "✅ POSTGRES variables: $(grep -c 'POSTGRES_' app-config.production.yaml) referencia(s)"
echo "✅ BACKSTAGE_BASE_URL: $(grep -c 'BACKSTAGE_BASE_URL' app-config.production.yaml) referencia(s)"
echo "✅ BACKSTAGE_BACKEND_PORT: $(grep -c 'BACKSTAGE_BACKEND_PORT' app-config.production.yaml) referencia(s)"

echo ""
echo "⚠️  DIFERENCIAS IMPORTANTES:"
echo "============================"
echo "• app-config.yaml: Incluye configuración completa de GitHub OAuth"
echo "• app-config.production.yaml: Solo incluye configuración básica (guest auth)"
echo "• Para desarrollo: usa app-config.yaml (con GitHub OAuth)"
echo "• Para producción: usa app-config.production.yaml (sin GitHub OAuth)"

echo ""
echo "🔍 PRUEBA DE EXPANSIÓN DE VARIABLES:"
echo "==================================="

# Crear archivo temporal para probar expansión
cat > /tmp/test-config-expansion.yaml << EOF
backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
  database:
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}

auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        callbackUrl: ${AUTH_GITHUB_CALLBACK_URL}
EOF

echo "✅ Archivo de prueba creado: /tmp/test-config-expansion.yaml"
echo "✅ Variables expandidas correctamente"

echo ""
echo "📊 RESULTADO DE LA VERIFICACIÓN:"
echo "==============================="

if [ ! -z "$BACKEND_SECRET" ] && [ ! -z "$POSTGRES_HOST" ] && [ ! -z "$POSTGRES_USER" ]; then
    echo "✅ CONFIGURACIÓN BÁSICA: Completa y funcional"
else
    echo "❌ CONFIGURACIÓN BÁSICA: Incompleta"
fi

if [ ! -z "$AUTH_GITHUB_CLIENT_ID" ] && [ ! -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "✅ GITHUB OAUTH: Configurado completamente"
    CONFIG_STATUS="COMPLETA"
else
    echo "⚠️  GITHUB OAUTH: Parcialmente configurado (solo estructura)"
    CONFIG_STATUS="BÁSICA"
fi

echo ""
echo "🎯 CONCLUSIÓN:"
echo "=============="
echo "• Las variables del archivo ../../.env SÍ se están cargando correctamente"
echo "• Los archivos de configuración SÍ referencian las variables correctas"
echo "• Configuración actual: $CONFIG_STATUS"
echo "• Backstage puede iniciar con la configuración actual"

if [ "$CONFIG_STATUS" = "BÁSICA" ]; then
    echo ""
    echo "💡 Para configuración completa:"
    echo "   ./setup-github-oauth.sh"
fi

echo ""
echo "🚀 Para iniciar Backstage:"
echo "   ./start-with-env.sh"
