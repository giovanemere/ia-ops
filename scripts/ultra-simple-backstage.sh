#!/bin/bash

# =============================================================================
# SOLUCIÓN ULTRA SIMPLE PARA BACKSTAGE
# =============================================================================

set -e

echo "🚀 Iniciando solución ultra simple para Backstage..."

# Cargar variables
source .env

# Detener servicios existentes
echo "⏹️  Deteniendo servicios..."
docker-compose down 2>/dev/null || true

# Iniciar solo PostgreSQL
echo "🗄️  Iniciando PostgreSQL..."
docker run -d \
  --name ia-ops-postgres \
  --network host \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -p 5432:5432 \
  postgres:15

echo "⏳ Esperando PostgreSQL..."
sleep 15

# Verificar PostgreSQL
echo "✅ Verificando PostgreSQL..."
if ! docker exec ia-ops-postgres pg_isready -U $POSTGRES_USER; then
    echo "❌ PostgreSQL no está listo"
    exit 1
fi

# Crear y ejecutar Backstage en un contenedor simple
echo "🎭 Creando contenedor de Backstage..."

docker run -d \
  --name ia-ops-backstage \
  --network host \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -e BACKEND_SECRET=$BACKEND_SECRET \
  -e AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID \
  -e AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  -e GITHUB_ORG=$GITHUB_ORG \
  -p 3000:3000 \
  -p 7007:7007 \
  -v $(pwd)/app-config.yaml:/app/app-config.yaml:ro \
  -v $(pwd)/catalog-info.yaml:/app/catalog-info.yaml:ro \
  -v $(pwd)/users.yaml:/app/users.yaml:ro \
  --workdir /app \
  node:18-bullseye-slim \
  bash -c "
    apt-get update && apt-get install -y python3 g++ make git curl netcat && \
    npm install -g @backstage/create-app@latest && \
    npx @backstage/create-app@latest --skip-install backstage-app && \
    cd backstage-app && \
    yarn install && \
    cp /app/app-config.yaml . && \
    cp /app/catalog-info.yaml . && \
    cp /app/users.yaml . && \
    echo 'Esperando PostgreSQL...' && \
    while ! nc -z localhost 5432; do sleep 1; done && \
    echo 'Iniciando Backstage...' && \
    yarn dev
  "

echo "⏳ Esperando Backstage (esto puede tomar varios minutos)..."
sleep 90

# Verificar servicios
echo "✅ Verificando servicios..."

if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:7007"
else
    echo "⚠️  Backend puede estar iniciando..."
fi

if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend puede estar iniciando..."
fi

echo ""
echo "🎉 Backstage debería estar funcionando en:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:7007"
echo ""
echo "Para ver logs:"
echo "   docker logs -f ia-ops-backstage"
echo ""
echo "Para detener:"
echo "   docker stop ia-ops-backstage ia-ops-postgres"
echo "   docker rm ia-ops-backstage ia-ops-postgres"
