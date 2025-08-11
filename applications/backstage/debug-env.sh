#!/bin/bash

echo "🔍 DIAGNÓSTICO DE VARIABLES DE ENTORNO"
echo "====================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    echo "✅ Archivo de entorno encontrado: ../../.env"
    set -a
    source ../../.env
    set +a
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

echo ""
echo "🔑 VARIABLES CRÍTICAS PARA BACKSTAGE:"
echo "===================================="

echo "1. BACKEND_SECRET:"
if [ -z "$BACKEND_SECRET" ]; then
    echo "   ❌ BACKEND_SECRET no está configurado"
else
    echo "   ✅ BACKEND_SECRET está configurado"
    echo "   🔧 Longitud: ${#BACKEND_SECRET} caracteres"
    echo "   🔧 Primeros 10 caracteres: ${BACKEND_SECRET:0:10}..."
fi

echo ""
echo "2. Variables de Base de Datos:"
echo "   🔧 POSTGRES_HOST: $POSTGRES_HOST"
echo "   🔧 POSTGRES_PORT: $POSTGRES_PORT"
echo "   🔧 POSTGRES_USER: $POSTGRES_USER"
echo "   🔧 POSTGRES_DB: $POSTGRES_DB"
echo "   🔧 Password configurado: $([ -n "$POSTGRES_PASSWORD" ] && echo "✅ Sí" || echo "❌ No")"

echo ""
echo "3. Variables de Backstage:"
echo "   🔧 BACKSTAGE_BACKEND_PORT: ${BACKSTAGE_BACKEND_PORT:-7007}"
echo "   🔧 BACKSTAGE_FRONTEND_PORT: ${BACKSTAGE_FRONTEND_PORT:-3002}"

echo ""
echo "4. GitHub Token:"
if [ -z "$GITHUB_TOKEN" ]; then
    echo "   ❌ GITHUB_TOKEN no está configurado"
elif [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "   ⚠️  GITHUB_TOKEN tiene valor placeholder"
else
    echo "   ✅ GITHUB_TOKEN está configurado"
    echo "   🔧 Primeros 10 caracteres: ${GITHUB_TOKEN:0:10}..."
fi

echo ""
echo "🧪 PROBANDO CONFIGURACIÓN DE BACKSTAGE:"
echo "======================================="

# Crear un archivo temporal con las variables para probar
cat > /tmp/test-backstage-config.yaml << EOF
backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
      ssl: false
EOF

echo "✅ Configuración de prueba creada en /tmp/test-backstage-config.yaml"

# Verificar que las variables se expanden correctamente
echo ""
echo "🔍 VERIFICACIÓN DE EXPANSIÓN DE VARIABLES:"
echo "========================================="
echo "BACKEND_SECRET expandido: ${BACKEND_SECRET}"
echo "POSTGRES_HOST expandido: ${POSTGRES_HOST}"
echo "POSTGRES_USER expandido: ${POSTGRES_USER}"
echo "POSTGRES_DB expandido: ${POSTGRES_DB}"

echo ""
echo "📝 RECOMENDACIONES:"
echo "=================="

if [ -z "$BACKEND_SECRET" ]; then
    echo "❌ Generar un nuevo BACKEND_SECRET:"
    echo "   openssl rand -base64 64"
fi

if [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "⚠️  Configurar GITHUB_TOKEN real"
fi

echo ""
echo "🚀 Para iniciar Backstage con debug:"
echo "   NODE_ENV=development ./start-with-env.sh"
