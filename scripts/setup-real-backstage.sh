#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR BACKEND REAL DE BACKSTAGE
# =============================================================================
# Descripción: Configura y ejecuta el backend real de Backstage
# Uso: ./scripts/setup-real-backstage.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏛️ Configurando Backend Real de Backstage...${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio raíz del proyecto${NC}"
    exit 1
fi

# Función para mostrar progreso
show_progress() {
    echo -e "${BLUE}🔄 $1...${NC}"
}

# Función para mostrar éxito
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar advertencia
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Paso 1: Detener servicios actuales
show_progress "Deteniendo servicios actuales"
docker-compose stop backstage-backend backstage-frontend
show_success "Servicios detenidos"

# Paso 2: Verificar estructura de Backstage
show_progress "Verificando estructura de Backstage"
if [ ! -d "applications/backstage/packages/backend" ]; then
    echo -e "${RED}❌ No se encontró el backend real de Backstage${NC}"
    exit 1
fi

if [ ! -f "applications/backstage/packages/backend/src/index.ts" ]; then
    echo -e "${RED}❌ No se encontró el código fuente del backend${NC}"
    exit 1
fi

show_success "Estructura de Backstage verificada"

# Paso 3: Instalar dependencias
show_progress "Instalando dependencias de Backstage"
cd applications/backstage

# Verificar si yarn está instalado
if ! command -v yarn &> /dev/null; then
    echo -e "${YELLOW}Yarn no está instalado, instalando...${NC}"
    npm install -g yarn
fi

# Instalar dependencias
yarn install --immutable
show_success "Dependencias instaladas"

# Paso 4: Construir el proyecto
show_progress "Construyendo Backstage"
yarn tsc
yarn build:backend
show_success "Backstage construido"

cd ../..

# Paso 5: Crear nuevo docker-compose override
show_progress "Creando configuración para backend real"

cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  backstage-backend:
    build:
      context: ./applications/backstage
      dockerfile: ../../Dockerfile.backend.real
    volumes:
      - ./applications/backstage:/app:ro
      - ./config/backstage:/app/config:ro
      - ./logs:/app/logs
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=info
      - BACKSTAGE_BACKEND_SECRET=\${BACKEND_SECRET}
      # Database
      - POSTGRES_HOST=\${POSTGRES_HOST}
      - POSTGRES_PORT=\${POSTGRES_PORT}
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_DB=\${POSTGRES_DB}
      # Auth
      - GITHUB_TOKEN=\${GITHUB_TOKEN}
      - AUTH_GITHUB_CLIENT_ID=\${AUTH_GITHUB_CLIENT_ID}
      - AUTH_GITHUB_CLIENT_SECRET=\${AUTH_GITHUB_CLIENT_SECRET}
      # URLs
      - BACKSTAGE_BASE_URL=\${BACKSTAGE_BASE_URL}
      - BACKSTAGE_FRONTEND_URL=\${BACKSTAGE_FRONTEND_URL}
      - BACKSTAGE_INTERNAL_FRONTEND_URL=\${BACKSTAGE_INTERNAL_FRONTEND_URL}
      - BACKSTAGE_INTERNAL_BACKEND_URL=\${BACKSTAGE_INTERNAL_BACKEND_URL}
      # Services
      - OPENAI_SERVICE_URL=\${OPENAI_SERVICE_URL}
      - OPENAI_API_KEY=\${OPENAI_API_KEY}
      # Catalog
      - CATALOG_LOCATIONS=\${CATALOG_LOCATIONS}
EOF

show_success "Configuración creada"

# Paso 6: Construir nueva imagen
show_progress "Construyendo imagen del backend real"
docker-compose build backstage-backend
show_success "Imagen construida"

# Paso 7: Iniciar servicios
show_progress "Iniciando servicios con backend real"
docker-compose up -d postgres redis
sleep 10
docker-compose up -d backstage-backend
sleep 15
docker-compose up -d backstage-frontend
show_success "Servicios iniciados"

# Paso 8: Verificar funcionamiento
show_progress "Verificando funcionamiento"
sleep 30

# Verificar backend
if curl -s -f http://localhost:7007/api/catalog/health > /dev/null; then
    show_success "Backend real funcionando correctamente"
    echo -e "${GREEN}🎉 Backend real de Backstage configurado exitosamente!${NC}"
else
    show_warning "Backend aún iniciando, verifica en unos minutos"
fi

# Mostrar información
echo ""
echo -e "${BLUE}📊 Estado de los servicios:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}🌐 URLs disponibles:${NC}"
echo "• Frontend: http://localhost:3000"
echo "• Backend Real: http://localhost:7007"
echo "• API Catalog: http://localhost:7007/api/catalog/entities"
echo "• API Health: http://localhost:7007/api/catalog/health"

echo ""
echo -e "${BLUE}🔧 Comandos útiles:${NC}"
echo "• Ver logs: docker-compose logs -f backstage-backend"
echo "• Reiniciar: docker-compose restart backstage-backend"
echo "• Estado: docker-compose ps"

echo ""
echo -e "${GREEN}✅ ¡Backend real de Backstage listo para usar!${NC}"
