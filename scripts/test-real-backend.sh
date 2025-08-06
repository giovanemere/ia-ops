#!/bin/bash

# =============================================================================
# SCRIPT DE PRUEBA - BACKEND REAL DE BACKSTAGE
# =============================================================================
# Descripción: Prueba rápida del backend real de Backstage
# Uso: ./scripts/test-real-backend.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Probando Backend Real de Backstage...${NC}"
echo ""

# Cargar variables de entorno
if [ -f ".env" ]; then
    source .env
else
    echo -e "${RED}❌ Error: Archivo .env no encontrado${NC}"
    exit 1
fi

# Verificar servicios de base de datos
echo -e "${YELLOW}🔍 Verificando servicios...${NC}"

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

# Cambiar al directorio de Backstage
cd applications/backstage

# Configurar variables de entorno
export NODE_ENV=development
export POSTGRES_HOST=localhost
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
export POSTGRES_DB=${POSTGRES_DB}
export REDIS_HOST=localhost
export REDIS_PORT=${REDIS_PORT:-6379}

echo -e "${GREEN}✅ Servicios listos${NC}"
echo ""

echo -e "${BLUE}🏗️ Información del Backend Real:${NC}"
echo "• Directorio: $(pwd)"
echo "• Node version: $(node --version)"
echo "• Yarn version: $(yarn --version)"
echo ""

echo -e "${BLUE}📦 Dependencias instaladas:${NC}"
if [ -d "node_modules/@backstage" ]; then
    echo "✅ Backstage packages instalados"
    ls node_modules/@backstage | head -5 | sed 's/^/  • /'
    echo "  • ... y más"
else
    echo "❌ Backstage packages no encontrados"
fi

echo ""
echo -e "${BLUE}🔧 Scripts disponibles:${NC}"
yarn run --silent | grep -E "(start|build|dev)" | sed 's/^/  • /'

echo ""
echo -e "${BLUE}📋 Configuración actual:${NC}"
echo "• Backend construido: $([ -d "packages/backend/dist" ] && echo "✅ Sí" || echo "❌ No")"
echo "• App construida: $([ -d "packages/app/dist" ] && echo "✅ Sí" || echo "❌ No")"

echo ""
echo -e "${YELLOW}💡 Para ejecutar el backend real:${NC}"
echo "1. En una terminal separada:"
echo "   cd applications/backstage"
echo "   yarn workspace backend start"
echo ""
echo "2. O usar el script:"
echo "   ./scripts/run-real-backend.sh"
echo ""
echo -e "${GREEN}✅ Backend real listo para ejecutar${NC}"
