#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - CON BACKSTAGE SIMPLE
# =============================================================================
# Usa docker run directo + Backstage ya construido - USA TUS VARIABLES .ENV

set -e

# Cargar variables de .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "🚀 IA-Ops Platform - Con Backstage"
echo "✅ Variables cargadas desde .env"

# Crear red
docker network create ia-ops-network 2>/dev/null || true

# Limpiar contenedores existentes
echo "🧹 Limpiando contenedores existentes..."
docker rm -f ia-ops-postgres ia-ops-redis ia-ops-openai ia-ops-proxy ia-ops-backstage-frontend ia-ops-backstage-backend 2>/dev/null || true

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
sleep 15

# 3. Backstage Backend (usando archivos ya construidos)
echo "🏛️ Iniciando Backstage Backend..."
docker run -d \
  --name ia-ops-backstage-backend \
  --network ia-ops-network \
  -p 7007:7007 \
  -e NODE_ENV=${NODE_ENV} \
  -e LOG_LEVEL=${LOG_LEVEL} \
  -e BACKEND_SECRET=${BACKEND_SECRET} \
  -e POSTGRES_HOST=ia-ops-postgres \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  -e POSTGRES_DB=${POSTGRES_DB} \
  -e REDIS_HOST=ia-ops-redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=${REDIS_PASSWORD} \
  -e REDIS_DB=${REDIS_DB} \
  -e GITHUB_TOKEN=${GITHUB_TOKEN} \
  -e AUTH_GITHUB_CLIENT_ID=${AUTH_GITHUB_CLIENT_ID} \
  -e AUTH_GITHUB_CLIENT_SECRET=${AUTH_GITHUB_CLIENT_SECRET} \
  -e OPENAI_API_KEY=${OPENAI_API_KEY} \
  -e OPENAI_MODEL=${OPENAI_MODEL} \
  -v $(pwd)/applications/backstage/app-config.yaml:/app/app-config.yaml:ro \
  -v $(pwd)/applications/backstage/packages/backend/dist:/app/packages/backend/dist:ro \
  -v $(pwd)/applications/backstage/catalog:/app/catalog:ro \
  --workdir /app \
  node:18-bullseye-slim \
  bash -c "cd /app && tar -xzf packages/backend/dist/bundle.tar.gz && node packages/backend --config app-config.yaml"

# Esperar Backstage Backend
echo "⏳ Esperando Backstage Backend..."
sleep 20

# 4. Backstage Frontend (usando archivos ya construidos)
echo "🖥️ Iniciando Backstage Frontend..."
docker run -d \
  --name ia-ops-backstage-frontend \
  --network ia-ops-network \
  -p 3000:3000 \
  -v $(pwd)/applications/backstage/packages/app/dist:/usr/share/nginx/html:ro \
  nginx:alpine \
  sh -c 'echo "server {
    listen 3000;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://ia-ops-backstage-backend:7007/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}" > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"'

# 5. OpenAI Service
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
fi

# 6. Proxy Service
if docker images | grep -q "ia-ops-proxy-service"; then
    echo "🌐 Iniciando Proxy Service..."
    docker run -d \
      --name ia-ops-proxy \
      --network ia-ops-network \
      -p 8080:8080 \
      -e NODE_ENV=${NODE_ENV} \
      -e LOG_LEVEL=${LOG_LEVEL} \
      -e PROXY_SERVICE_PORT=8080 \
      -e PROXY_BACKSTAGE_FRONTEND_URL=http://ia-ops-backstage-frontend:3000 \
      -e PROXY_BACKSTAGE_BACKEND_URL=http://ia-ops-backstage-backend:7007 \
      -e PROXY_OPENAI_SERVICE_URL=http://ia-ops-openai:8000 \
      edissonz8809/ia-ops-proxy-service:${PROXY_SERVICE_VERSION}
fi

echo ""
echo "🎉 IA-Ops Platform completa iniciada!"
echo ""
echo "📋 URLs disponibles:"
echo "   🌐 Proxy (Principal): http://localhost:8080"
echo "   🏛️ Backstage:         http://localhost:3000"
echo "   🔧 Backstage API:     http://localhost:7007"
echo "   🤖 OpenAI Service:    http://localhost:8000"
echo "   🗄️ PostgreSQL:        localhost:5432"
echo "   🔄 Redis:             localhost:6379"
echo ""
echo "🔍 Ver contenedores:"
echo "   docker ps"
echo ""

# Verificar servicios
echo "🔍 Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "⏳ Esperando que todos los servicios estén listos..."
sleep 10

echo "🧪 Probando servicios:"
echo -n "   PostgreSQL: " && docker exec ia-ops-postgres pg_isready -U postgres 2>/dev/null && echo "✅" || echo "❌"
echo -n "   Redis: " && docker exec ia-ops-redis redis-cli -a ${REDIS_PASSWORD} ping 2>/dev/null | grep -q PONG && echo "✅" || echo "❌"
echo -n "   Backstage Backend: " && curl -s http://localhost:7007/health >/dev/null 2>&1 && echo "✅" || echo "❌"
echo -n "   Backstage Frontend: " && curl -s http://localhost:3000 >/dev/null 2>&1 && echo "✅" || echo "❌"
echo -n "   OpenAI Service: " && curl -s http://localhost:8000/health >/dev/null 2>&1 && echo "✅" || echo "❌"
echo -n "   Proxy Service: " && curl -s http://localhost:8080/health >/dev/null 2>&1 && echo "✅" || echo "❌"

echo ""
echo "🚀 ¡Listo! Accede a http://localhost:8080 para usar la plataforma"
