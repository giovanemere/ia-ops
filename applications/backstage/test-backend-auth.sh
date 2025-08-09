#!/bin/bash

echo "🔐 PRUEBA DE AUTENTICACIÓN DEL BACKEND"
echo "====================================="

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
echo "🔍 VERIFICANDO BACKEND_SECRET:"
echo "============================="
echo "Longitud: ${#BACKEND_SECRET} caracteres"
echo "Primeros 20 caracteres: ${BACKEND_SECRET:0:20}..."
echo "Últimos 10 caracteres: ...${BACKEND_SECRET: -10}"

if [ ${#BACKEND_SECRET} -ge 32 ]; then
    echo "✅ BACKEND_SECRET tiene longitud adecuada"
else
    echo "❌ BACKEND_SECRET es demasiado corto"
fi

echo ""
echo "🧪 PROBANDO CONFIGURACIÓN YAML:"
echo "==============================="

# Crear un archivo de configuración temporal para probar
cat > /tmp/test-auth-config.yaml << EOF
backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
  baseUrl: http://localhost:7007
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

echo "✅ Archivo de configuración de prueba creado"
echo "📁 Ubicación: /tmp/test-auth-config.yaml"

echo ""
echo "🔧 VARIABLES EXPORTADAS:"
echo "======================="
export BACKEND_SECRET
export POSTGRES_HOST
export POSTGRES_PORT
export POSTGRES_USER
export POSTGRES_PASSWORD
export POSTGRES_DB
export NODE_ENV=development

echo "BACKEND_SECRET: ${BACKEND_SECRET:0:20}..."
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "NODE_ENV: $NODE_ENV"

echo ""
echo "✅ Variables preparadas para Backstage"
echo "🚀 Ahora puedes ejecutar: ./start-with-env.sh"
