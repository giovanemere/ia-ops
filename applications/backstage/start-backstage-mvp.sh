#!/bin/bash

# =============================================================================
# INICIO RÁPIDO DE BACKSTAGE - MVP
# =============================================================================
# Script para iniciar Backstage rápidamente para demo MVP

set -e

echo "🚀 Iniciando Backstage MVP para demo..."

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    export $(grep -v '^#' ../../.env | xargs)
    echo "✅ Variables de entorno cargadas"
else
    echo "❌ No se encontró archivo .env"
    exit 1
fi

# Verificar Node.js
node_version=$(node --version)
echo "📦 Node.js version: $node_version"

# Verificar Yarn
if ! command -v yarn &> /dev/null; then
    echo "❌ Yarn no está instalado"
    exit 1
fi

yarn_version=$(yarn --version)
echo "📦 Yarn version: $yarn_version"

# Verificar que las dependencias estén instaladas
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    yarn install --frozen-lockfile
else
    echo "✅ Dependencias ya instaladas"
fi

# Verificar servicios requeridos
echo "🔍 Verificando servicios requeridos..."

# PostgreSQL
if curl -s http://localhost:5432 > /dev/null 2>&1; then
    echo "✅ PostgreSQL disponible"
else
    echo "❌ PostgreSQL no disponible en puerto 5432"
    echo "   Iniciando servicios de base de datos..."
    cd ../../ && docker-compose up -d postgres redis
    sleep 5
    cd applications/backstage
fi

# OpenAI Service
if curl -s http://localhost:8003/health > /dev/null 2>&1; then
    echo "✅ OpenAI Service disponible"
else
    echo "❌ OpenAI Service no disponible"
    echo "   Iniciando OpenAI Service..."
    cd ../../ && docker-compose up -d openai-service
    sleep 3
    cd applications/backstage
fi

# Crear archivo de configuración local si no existe
if [ ! -f "app-config.local.yaml" ]; then
    cat > app-config.local.yaml << EOF
# Configuración local para MVP
app:
  title: IA-Ops MVP Demo
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  
# Configuración simplificada para demo
catalog:
  locations:
    - type: file
      target: ./catalog-mvp-demo.yaml
EOF
    echo "✅ Configuración local creada"
fi

echo ""
echo "🎯 Iniciando Backstage en modo desarrollo..."
echo "   Frontend: http://localhost:3000"
echo "   Backend: http://localhost:7007"
echo ""
echo "⏳ Esto puede tomar 1-2 minutos la primera vez..."

# Iniciar Backstage
yarn dev &

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que Backstage esté listo..."
sleep 30

# Verificar que esté funcionando
for i in {1..12}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo "✅ Backstage Frontend listo en http://localhost:3000"
        break
    fi
    if [ $i -eq 12 ]; then
        echo "❌ Timeout esperando Backstage Frontend"
        exit 1
    fi
    echo "   Intento $i/12 - esperando..."
    sleep 10
done

for i in {1..12}; do
    if curl -s http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
        echo "✅ Backstage Backend listo en http://localhost:7007"
        break
    fi
    if [ $i -eq 12 ]; then
        echo "❌ Timeout esperando Backstage Backend"
        exit 1
    fi
    echo "   Intento $i/12 - esperando backend..."
    sleep 10
done

echo ""
echo "🎉 Backstage MVP iniciado exitosamente!"
echo ""
echo "🌐 URLs disponibles:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:7007"
echo "   Catálogo: http://localhost:3000/catalog"
echo "   AI Analysis: http://localhost:8003"
echo ""
echo "📋 Para ver la aplicación analizada por IA:"
echo "   1. Abrir http://localhost:3000/catalog"
echo "   2. Buscar 'BillPay Backend (AI Demo)'"
echo "   3. Ver detalles de análisis automático"
echo ""
echo "🛑 Para detener: Ctrl+C"

# Mantener el script corriendo
wait
