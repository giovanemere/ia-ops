#!/bin/bash

# =============================================================================
# FIX BACKSTAGE CON IMAGEN NODE.JS
# =============================================================================

set -e

echo "🔧 Solucionando Backstage con imagen Node.js..."

# Cargar variables
source .env

# Detener servicios
echo "⏹️  Deteniendo servicios..."
docker-compose down 2>/dev/null || true

# Crear Dockerfile simple
echo "📝 Creando Dockerfile simple..."
cat > Dockerfile.backstage-simple << 'EOF'
FROM node:18-bullseye-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar Backstage CLI
RUN npm install -g @backstage/create-app@latest

# Crear aplicación Backstage
RUN npx @backstage/create-app@latest --skip-install backstage-app

WORKDIR /app/backstage-app

# Instalar dependencias
RUN yarn install

# Copiar configuración
COPY app-config*.yaml ./
COPY catalog-info.yaml ./
COPY users.yaml ./

# Exponer puertos
EXPOSE 3000 7007

# Script de inicio
COPY start-backstage.sh ./
RUN chmod +x start-backstage.sh

CMD ["./start-backstage.sh"]
EOF

# Crear script de inicio
echo "📝 Creando script de inicio..."
cat > start-backstage.sh << 'EOF'
#!/bin/bash

echo "🚀 Iniciando Backstage..."

# Esperar PostgreSQL
echo "⏳ Esperando PostgreSQL..."
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 1
done

echo "✅ PostgreSQL listo"

# Iniciar backend en background
echo "🔧 Iniciando backend..."
cd /app/backstage-app
yarn workspace backend start &

# Esperar que el backend esté listo
sleep 30

# Iniciar frontend
echo "🎭 Iniciando frontend..."
yarn workspace app start
EOF

chmod +x start-backstage.sh

# Crear docker-compose simplificado
echo "📝 Creando docker-compose simplificado..."
cat > docker-compose.simple.yml << EOF
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
    build:
      context: .
      dockerfile: Dockerfile.backstage-simple
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
EOF

# Iniciar servicios
echo "🗄️  Iniciando PostgreSQL..."
docker-compose -f docker-compose.simple.yml up -d postgres

echo "⏳ Esperando PostgreSQL..."
sleep 15

echo "🏗️  Construyendo imagen de Backstage..."
docker-compose -f docker-compose.simple.yml build backstage

echo "🎭 Iniciando Backstage..."
docker-compose -f docker-compose.simple.yml up -d backstage

echo "⏳ Esperando Backstage (esto puede tomar varios minutos)..."
sleep 60

# Verificar
echo "✅ Verificando servicios..."

if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:7007"
else
    echo "❌ Backend no responde aún, puede estar iniciando..."
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
echo "Para ver logs: docker-compose -f docker-compose.simple.yml logs -f backstage"
