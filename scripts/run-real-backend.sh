#!/bin/bash

# =============================================================================
# SCRIPT PARA EJECUTAR BACKEND REAL DE BACKSTAGE
# =============================================================================
# Descripción: Ejecuta el backend real de Backstage localmente
# Uso: ./scripts/run-real-backend.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏛️ Ejecutando Backend Real de Backstage...${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio raíz del proyecto${NC}"
    exit 1
fi

# Cargar variables de entorno
if [ -f ".env" ]; then
    source .env
    echo -e "${GREEN}✅ Variables de entorno cargadas${NC}"
else
    echo -e "${RED}❌ Error: Archivo .env no encontrado${NC}"
    exit 1
fi

# Verificar que los servicios de base de datos estén corriendo
echo -e "${YELLOW}🔍 Verificando servicios de base de datos...${NC}"

if ! docker-compose ps postgres | grep -q "Up"; then
    echo -e "${YELLOW}Iniciando PostgreSQL...${NC}"
    docker-compose up -d postgres
    sleep 10
fi

if ! docker-compose ps redis | grep -q "Up"; then
    echo -e "${YELLOW}Iniciando Redis...${NC}"
    docker-compose up -d redis
    sleep 5
fi

echo -e "${GREEN}✅ Servicios de base de datos listos${NC}"

# Detener el backend actual si está corriendo
if docker-compose ps backstage-backend | grep -q "Up"; then
    echo -e "${YELLOW}Deteniendo backend actual...${NC}"
    docker-compose stop backstage-backend
fi

# Cambiar al directorio de Backstage
cd applications/backstage

echo -e "${BLUE}🚀 Iniciando backend real de Backstage...${NC}"
echo ""
echo -e "${YELLOW}📋 Configuración:${NC}"
echo "• Puerto: 7007"
echo "• Base de datos: PostgreSQL (${POSTGRES_HOST}:${POSTGRES_PORT})"
echo "• Cache: Redis (${REDIS_HOST}:${REDIS_PORT})"
echo "• GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo ""

# Configurar variables de entorno para el backend
export NODE_ENV=development
export LOG_LEVEL=info
export POSTGRES_HOST=${POSTGRES_HOST:-postgres}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
export POSTGRES_DB=${POSTGRES_DB}
export GITHUB_TOKEN=${GITHUB_TOKEN}
export AUTH_GITHUB_CLIENT_ID=${AUTH_GITHUB_CLIENT_ID}
export AUTH_GITHUB_CLIENT_SECRET=${AUTH_GITHUB_CLIENT_SECRET}
export BACKEND_SECRET=${BACKEND_SECRET}
export BACKSTAGE_BASE_URL=${BACKSTAGE_BASE_URL}
export BACKSTAGE_FRONTEND_URL=${BACKSTAGE_FRONTEND_URL}
export BACKSTAGE_INTERNAL_FRONTEND_URL=${BACKSTAGE_INTERNAL_FRONTEND_URL}
export BACKSTAGE_INTERNAL_BACKEND_URL=${BACKSTAGE_INTERNAL_BACKEND_URL}
export OPENAI_SERVICE_URL=${OPENAI_SERVICE_URL}
export OPENAI_API_KEY=${OPENAI_API_KEY}
export CATALOG_LOCATIONS=${CATALOG_LOCATIONS}

# Cambiar host de postgres para conexión local
export POSTGRES_HOST=localhost
export REDIS_HOST=localhost

echo -e "${GREEN}🎯 Iniciando backend real...${NC}"
echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
echo ""

# Ejecutar el backend
yarn workspace backend start

echo -e "${YELLOW}Backend detenido${NC}"
