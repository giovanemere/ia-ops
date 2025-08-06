#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - ULTRA SIMPLE
# =============================================================================
# Usa docker run directo - SIN COMPILACIÓN - USA TUS VARIABLES .ENV

set -e

# Cargar variables de .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "🚀 IA-Ops Platform - Ultra Simple"
echo "✅ Variables cargadas desde .env"

# Crear red
docker network create ia-ops-network 2>/dev/null || true

# Limpiar contenedores existentes
echo "🧹 Limpiando contenedores existentes..."
docker rm -f ia-ops-postgres ia-ops-redis ia-ops-openai ia-ops-proxy 2>/dev/null || true

# 1. PostgreSQL
echo "🗄️ Iniciando PostgreSQL..."
docker run -d \
  --name ia-ops-postgres \
  --network ia-ops-network \
  -p 5432:5432 \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  -e POSTGRES_DB=${POSTGRES_DB} \
  postgres:15

# 2. Redis
echo "🔄 Iniciando Redis..."
docker run -d \
  --name ia-ops-redis \
  --network ia-ops-network \
  -p 6379:6379 \
  redis:7-alpine redis-server --requirepass ${REDIS_PASSWORD}

# Esperar que estén listos
echo "⏳ Esperando base de datos..."
sleep 10

# 3. OpenAI Service (si la imagen existe)
if docker images | grep -q "ia-ops-openai-service"; then
    echo "🤖 Iniciando OpenAI Service..."
    docker run -d \
      --name ia-ops-openai \
      --network ia-ops-network \
      -p 8000:8000 \
      -e OPENAI_API_KEY=${OPENAI_API_KEY} \
      -e OPENAI_MODEL=${OPENAI_MODEL} \
      -e LOG_LEVEL=${LOG_LEVEL} \
      edissonz8809/ia-ops-openai-service:${OPENAI_SERVICE_VERSION}
else
    echo "⚠️ OpenAI Service image not found, skipping..."
fi

# 4. Proxy Service (si la imagen existe)
if docker images | grep -q "ia-ops-proxy-service"; then
    echo "🌐 Iniciando Proxy Service..."
    docker run -d \
      --name ia-ops-proxy \
      --network ia-ops-network \
      -p 8080:8080 \
      -e NODE_ENV=${NODE_ENV} \
      -e LOG_LEVEL=${LOG_LEVEL} \
      -e PROXY_SERVICE_PORT=8080 \
      -e OPENAI_SERVICE_URL=http://ia-ops-openai:8000 \
      edissonz8809/ia-ops-proxy-service:${PROXY_SERVICE_VERSION}
else
    echo "⚠️ Proxy Service image not found, skipping..."
fi

echo ""
echo "🎉 Servicios básicos iniciados!"
echo ""
echo "📋 URLs disponibles:"
echo "   🗄️ PostgreSQL: localhost:5432"
echo "   🔄 Redis:       localhost:6379"
echo "   🤖 OpenAI:      http://localhost:8000"
echo "   🌐 Proxy:       http://localhost:8080"
echo ""
echo "🔍 Ver contenedores:"
echo "   docker ps"
echo ""

# Verificar servicios
echo "🔍 Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
