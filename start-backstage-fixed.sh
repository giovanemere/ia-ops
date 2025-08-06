#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - BACKSTAGE ARREGLADO
# =============================================================================

set -e

# Cargar variables de .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "🚀 IA-Ops Platform - Backstage Arreglado"

# Crear red
docker network create ia-ops-network 2>/dev/null || true

# Limpiar contenedores de Backstage
echo "🧹 Limpiando Backstage anterior..."
docker rm -f ia-ops-backstage-frontend ia-ops-backstage-backend 2>/dev/null || true

# Verificar que otros servicios estén corriendo
echo "🔍 Verificando servicios base..."
if ! docker ps | grep -q ia-ops-postgres; then
    echo "❌ PostgreSQL no está corriendo. Ejecuta primero: ./start-ultra-simple.sh"
    exit 1
fi

# Crear directorio temporal para Backstage
echo "📁 Preparando archivos de Backstage..."
mkdir -p /tmp/backstage-backend
cp -r applications/backstage/packages/backend/dist/* /tmp/backstage-backend/
cd /tmp/backstage-backend && tar -xzf bundle.tar.gz 2>/dev/null || true

# Backstage Backend (con archivos copiados)
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
  -v /tmp/backstage-backend:/app/packages/backend:rw \
  --workdir /app \
  node:18-bullseye-slim \
  bash -c "
    echo '🔧 Instalando dependencias básicas...'
    apt-get update -qq && apt-get install -y -qq curl postgresql-client
    echo '🚀 Iniciando Backstage Backend...'
    cd /app/packages/backend
    node index.cjs.js --config /app/app-config.yaml
  "

# Esperar que el backend esté listo
echo "⏳ Esperando Backstage Backend..."
for i in {1..30}; do
    if curl -s http://localhost:7007/health >/dev/null 2>&1; then
        echo "✅ Backstage Backend listo!"
        break
    fi
    echo "   Intento $i/30..."
    sleep 2
done

# Backstage Frontend (simple con nginx)
echo "🖥️ Iniciando Backstage Frontend..."
docker run -d \
  --name ia-ops-backstage-frontend \
  --network ia-ops-network \
  -p 3000:3000 \
  -v $(pwd)/applications/backstage/packages/app/dist:/usr/share/nginx/html:ro \
  nginx:alpine \
  sh -c '
    echo "server {
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
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        location /health {
            return 200 \"Frontend OK\";
            add_header Content-Type text/plain;
        }
    }" > /etc/nginx/conf.d/default.conf
    
    echo "🚀 Iniciando Nginx..."
    nginx -g "daemon off;"
  '

echo ""
echo "🎉 Backstage agregado a la plataforma!"
echo ""
echo "📋 URLs actualizadas:"
echo "   🌐 Proxy (Principal): http://localhost:8080"
echo "   🏛️ Backstage:         http://localhost:3000"
echo "   🔧 Backstage API:     http://localhost:7007"
echo "   🤖 OpenAI Service:    http://localhost:8000"
echo ""

# Verificar servicios
echo "⏳ Verificando servicios..."
sleep 10

echo "🧪 Estado final:"
echo -n "   Backstage Backend: " && curl -s http://localhost:7007/health >/dev/null 2>&1 && echo "✅" || echo "❌"
echo -n "   Backstage Frontend: " && curl -s http://localhost:3000/health >/dev/null 2>&1 && echo "✅" || echo "❌"

echo ""
echo "🚀 ¡Backstage listo! Accede a http://localhost:3000"
