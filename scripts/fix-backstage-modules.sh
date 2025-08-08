#!/bin/bash

# =============================================================================
# SCRIPT PARA SOLUCIONAR MÓDULOS FALTANTES EN BACKSTAGE
# =============================================================================
# Soluciona el error: Cannot find module '@backstage/backend-defaults'

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "=== SOLUCIONANDO MÓDULOS FALTANTES EN BACKSTAGE ==="
echo

# Verificar que estamos en el directorio correcto
if [ ! -f ".env" ]; then
    print_error "Archivo .env no encontrado. Ejecuta desde el directorio raíz del proyecto."
    exit 1
fi

# Cargar variables de entorno
source .env

# 1. Detener servicios existentes
print_status "1. Deteniendo servicios de Backstage..."
docker-compose down 2>/dev/null || true
print_success "Servicios detenidos"

# 2. Limpiar contenedores e imágenes problemáticas
print_status "2. Limpiando contenedores e imágenes..."
docker container prune -f >/dev/null 2>&1 || true
docker image rm $(docker images | grep backstage | awk '{print $3}') 2>/dev/null || true
print_success "Limpieza completada"

# 3. Verificar estructura del proyecto Backstage
print_status "3. Verificando estructura del proyecto Backstage..."

backstage_dir="./applications/backstage"
if [ ! -d "$backstage_dir" ]; then
    print_error "Directorio de Backstage no encontrado: $backstage_dir"
    exit 1
fi

cd "$backstage_dir"

# Verificar que existe package.json
if [ ! -f "package.json" ]; then
    print_error "package.json no encontrado en $backstage_dir"
    exit 1
fi

print_success "Estructura del proyecto verificada"

# 4. Limpiar node_modules y yarn cache
print_status "4. Limpiando dependencias existentes..."

# Limpiar node_modules
if [ -d "node_modules" ]; then
    rm -rf node_modules
    print_status "node_modules eliminado"
fi

# Limpiar yarn cache
yarn cache clean 2>/dev/null || true

# Limpiar node_modules en packages
if [ -d "packages/backend/node_modules" ]; then
    rm -rf packages/backend/node_modules
    print_status "Backend node_modules eliminado"
fi

if [ -d "packages/app/node_modules" ]; then
    rm -rf packages/app/node_modules
    print_status "Frontend node_modules eliminado"
fi

print_success "Dependencias limpiadas"

# 5. Reinstalar dependencias
print_status "5. Reinstalando dependencias..."

# Verificar que yarn está instalado
if ! command -v yarn &> /dev/null; then
    print_error "Yarn no está instalado. Instalando..."
    npm install -g yarn
fi

# Instalar dependencias principales
print_status "Instalando dependencias principales..."
yarn install --frozen-lockfile 2>/dev/null || yarn install

# Verificar instalación del backend
print_status "Verificando instalación del backend..."
cd packages/backend

# Instalar dependencias específicas del backend
yarn install 2>/dev/null || npm install

# Verificar que @backstage/backend-defaults está instalado
if [ ! -d "node_modules/@backstage/backend-defaults" ]; then
    print_warning "@backstage/backend-defaults no encontrado, instalando manualmente..."
    yarn add @backstage/backend-defaults@^0.11.1 || npm install @backstage/backend-defaults@^0.11.1
fi

cd ../..

print_success "Dependencias reinstaladas"

# 6. Crear Dockerfile simplificado para el backend
print_status "6. Creando Dockerfile optimizado..."

cat > Dockerfile.backend.fixed << 'EOF'
# Multi-stage build para optimizar el tamaño de la imagen
FROM node:18-bullseye-slim as packages

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar archivos de configuración
COPY package.json yarn.lock ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/app/package.json ./packages/app/

# Instalar dependencias
RUN yarn install --frozen-lockfile --production=false

# Stage 2: Build
FROM node:18-bullseye-slim as build

RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar dependencias instaladas
COPY --from=packages /app/node_modules ./node_modules
COPY --from=packages /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=packages /app/packages/app/node_modules ./packages/app/node_modules

# Copiar código fuente
COPY . .

# Build del backend
RUN yarn workspace backend build

# Stage 3: Runtime
FROM node:18-bullseye-slim

RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Crear usuario no-root
RUN groupadd -r backstage && useradd -r -g backstage backstage

# Copiar archivos necesarios
COPY --from=build --chown=backstage:backstage /app/yarn.lock /app/package.json ./
COPY --from=build --chown=backstage:backstage /app/packages/backend/dist ./packages/backend/dist
COPY --from=build --chown=backstage:backstage /app/node_modules ./node_modules

# Copiar configuración
COPY --chown=backstage:backstage app-config*.yaml ./
COPY --chown=backstage:backstage catalog-info.yaml ./

USER backstage

EXPOSE 7007

CMD ["node", "packages/backend/dist/index.cjs.js"]
EOF

print_success "Dockerfile creado"

# 7. Volver al directorio raíz
cd ../../..

# 8. Actualizar docker-compose.yml para usar el nuevo Dockerfile
print_status "7. Actualizando configuración de Docker Compose..."

# Verificar si existe la sección de backstage-backend en docker-compose.yml
if ! grep -q "backstage-backend:" docker-compose.yml; then
    print_status "Agregando configuración de backstage-backend a docker-compose.yml..."
    
    # Crear backup del docker-compose.yml
    cp docker-compose.yml docker-compose.yml.backup
    
    # Agregar configuración de Backstage
    cat >> docker-compose.yml << 'EOF'

  # =============================================================================
  # BACKSTAGE SERVICES
  # =============================================================================
  
  backstage-backend:
    build:
      context: ./applications/backstage
      dockerfile: Dockerfile.backend.fixed
    container_name: ia-ops-backstage-backend
    environment:
      NODE_ENV: development
      POSTGRES_HOST: ${POSTGRES_HOST}
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
      BACKEND_SECRET: ${BACKEND_SECRET}
      AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID}
      AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET}
      GITHUB_TOKEN: ${GITHUB_TOKEN}
      GITHUB_ORG: ${GITHUB_ORG}
    ports:
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
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7007/api/catalog/entities"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  backstage-frontend:
    image: nginx:alpine
    container_name: ia-ops-backstage-frontend
    ports:
      - "3000:80"
    volumes:
      - ./config/nginx-simple.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - backstage-backend
    networks:
      - ia-ops-network
    environment:
      BACKEND_URL: http://backstage-backend:7007
EOF
    
    print_success "Configuración de Docker Compose actualizada"
else
    print_status "Configuración de backstage-backend ya existe en docker-compose.yml"
fi

# 9. Crear configuración de nginx para el frontend
print_status "8. Creando configuración de nginx..."

mkdir -p config
cat > config/nginx-simple.conf << 'EOF'
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://backstage-backend:7007;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin "http://localhost:3000" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization" always;
        add_header Access-Control-Expose-Headers "Content-Length,Content-Range" always;
        
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "http://localhost:3000";
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization";
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
    }
}
EOF

print_success "Configuración de nginx creada"

# 10. Iniciar servicios
print_status "9. Iniciando servicios..."

# Iniciar PostgreSQL primero
print_status "Iniciando PostgreSQL..."
docker-compose up -d postgres

# Esperar que PostgreSQL esté listo
print_status "Esperando PostgreSQL..."
sleep 15

# Verificar que PostgreSQL está listo
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if docker-compose exec -T postgres pg_isready -U $POSTGRES_USER >/dev/null 2>&1; then
        print_success "PostgreSQL está listo"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        print_error "Timeout esperando PostgreSQL"
        exit 1
    fi
    
    print_status "Intento $attempt/$max_attempts - Esperando PostgreSQL..."
    sleep 2
    ((attempt++))
done

# Construir e iniciar Backstage backend
print_status "Construyendo e iniciando Backstage backend..."
docker-compose build backstage-backend
docker-compose up -d backstage-backend

# Esperar que el backend esté listo
print_status "Esperando Backstage backend..."
sleep 30

# Verificar que el backend responde
max_attempts=60
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
        print_success "Backstage backend está respondiendo"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        print_error "Timeout esperando Backstage backend"
        print_status "Verificando logs..."
        docker-compose logs --tail=20 backstage-backend
        exit 1
    fi
    
    print_status "Intento $attempt/$max_attempts - Esperando backend..."
    sleep 3
    ((attempt++))
done

# Iniciar frontend
print_status "Iniciando Backstage frontend..."
docker-compose up -d backstage-frontend

print_success "Servicios iniciados correctamente"

# 11. Verificación final
print_status "10. Verificación final..."

# Verificar backend
if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    print_success "✅ Backend API está funcionando"
else
    print_error "❌ Backend API no responde"
fi

# Verificar frontend
if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    print_success "✅ Frontend está funcionando"
else
    print_warning "⚠️  Frontend puede estar iniciando"
fi

echo
print_status "=== SOLUCIÓN COMPLETADA ==="
print_success "🌐 Frontend: http://localhost:3000"
print_success "🔧 Backend: http://localhost:7007"
print_success "📊 Catalog: http://localhost:7007/api/catalog/entities"
echo

print_status "Si aún hay problemas, verifica los logs:"
print_status "docker-compose logs -f backstage-backend"
print_status "docker-compose logs -f backstage-frontend"
