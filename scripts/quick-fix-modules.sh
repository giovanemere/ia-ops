#!/bin/bash

# =============================================================================
# QUICK FIX - MÓDULOS FALTANTES EN BACKSTAGE
# =============================================================================

set -e

echo "🔧 Solucionando módulos faltantes en Backstage..."

# Cargar variables
source .env

# Detener servicios
echo "⏹️  Deteniendo servicios..."
docker-compose down 2>/dev/null || true

# Limpiar contenedores
echo "🧹 Limpiando contenedores..."
docker container prune -f >/dev/null 2>&1 || true

# Usar imagen oficial de Backstage como solución temporal
echo "🚀 Iniciando con imagen oficial de Backstage..."

# Crear docker-compose temporal
cat > docker-compose.backstage-fix.yml << EOF
version: '3.8'

networks:
  ia-ops-network:
    driver: bridge

services:
  postgres:
    image: postgres:15
    container_name: ia-ops-postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "5432:5432"
    networks:
      - ia-ops-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backstage:
    image: backstage/backstage:latest
    container_name: ia-ops-backstage
    environment:
      POSTGRES_HOST: postgres
      POSTGRES_PORT: 5432
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
      BACKEND_SECRET: ${BACKEND_SECRET}
      AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID}
      AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET}
      GITHUB_TOKEN: ${GITHUB_TOKEN}
      GITHUB_ORG: ${GITHUB_ORG}
    ports:
      - "3000:3000"
      - "7007:7007"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - ia-ops-network
    volumes:
      - ./app-config.yaml:/app/app-config.yaml:ro
      - ./catalog-info.yaml:/app/catalog-info.yaml:ro
      - ./users.yaml:/app/users.yaml:ro
EOF

# Iniciar servicios
echo "🗄️  Iniciando PostgreSQL..."
docker-compose -f docker-compose.backstage-fix.yml up -d postgres

echo "⏳ Esperando PostgreSQL..."
sleep 15

echo "🎭 Iniciando Backstage..."
docker-compose -f docker-compose.backstage-fix.yml up -d backstage

echo "⏳ Esperando Backstage..."
sleep 30

# Verificar
echo "✅ Verificando servicios..."

if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:7007"
else
    echo "❌ Backend no responde"
fi

if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend iniciando..."
fi

echo ""
echo "🎉 Backstage debería estar funcionando en:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:7007"
echo ""
echo "Para ver logs: docker-compose -f docker-compose.backstage-fix.yml logs -f"
