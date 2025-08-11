#!/bin/bash

# =============================================================================
# Script para Reparar el Inicio de Backstage
# =============================================================================

set -e

echo "🔧 Reparando configuración de Backstage..."
echo "=========================================="

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 1. Verificar y limpiar procesos
log "🔪 Limpiando procesos existentes..."
./kill-ports.sh

# 2. Verificar servicios Docker
log "🐳 Verificando servicios Docker..."
cd ../../
if ! docker-compose ps postgres | grep -q "Up"; then
    log "🚀 Iniciando PostgreSQL..."
    docker-compose up -d postgres
    sleep 5
fi

if ! docker-compose ps redis | grep -q "Up"; then
    log "🚀 Iniciando Redis..."
    docker-compose up -d redis
    sleep 3
fi

cd applications/backstage

# 3. Verificar conexión a base de datos
log "🗄️ Verificando conexión a base de datos..."
source ../../.env

# Esperar a que PostgreSQL esté listo
for i in {1..30}; do
    if docker-compose -f ../../docker-compose.yml exec -T postgres pg_isready -U $POSTGRES_USER -d $POSTGRES_DB; then
        log "✅ PostgreSQL está listo"
        break
    fi
    log "⏳ Esperando PostgreSQL... ($i/30)"
    sleep 2
done

# 4. Crear configuración simplificada
log "📝 Creando configuración simplificada..."
cat > app-config-simple.yaml << 'EOF'
app:
  title: IA-OPS Developer Portal
  baseUrl: http://localhost:3002

organization:
  name: IA-OPS

backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  csp:
    connect-src: ["'self'", 'http:', 'https:']
  cors:
    origin: http://localhost:3002
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
      ssl: false

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'

catalog:
  import:
    entityFilename: catalog-info.yaml
  rules:
    - allow: [Component, System, API, Resource, Location, Template, Domain, Group, User]
  
  locations:
    - type: file
      target: ../../catalog-info.yaml
      rules:
        - allow: [Component, System, API, Resource, Location, Template, Domain, Group, User]

auth:
  providers:
    guest: {}
EOF

# 5. Verificar variables de entorno críticas
log "🔍 Verificando variables de entorno..."
if [ -z "$BACKEND_SECRET" ]; then
    log "❌ BACKEND_SECRET no está definido"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    log "⚠️  GITHUB_TOKEN no está definido - algunas funciones no funcionarán"
fi

log "✅ Variables de entorno verificadas"

# 6. Limpiar cache de Node
log "🧹 Limpiando cache..."
rm -rf node_modules/.cache || true
rm -rf dist || true
rm -rf dist-types || true

# 7. Reinstalar dependencias si es necesario
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.yarn-integrity" ]; then
    log "📦 Instalando dependencias..."
    yarn install --frozen-lockfile
fi

# 8. Crear archivo catalog-info.yaml básico si no existe
if [ ! -f "../../catalog-info.yaml" ]; then
    log "📋 Creando catalog-info.yaml básico..."
    cat > ../../catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: ia-ops-platform
  title: IA-OPS Platform
  description: Plataforma integrada de IA y DevOps con Backstage
spec:
  owner: devops-team
  domain: platform
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backstage-portal
  title: Backstage Developer Portal
  description: Portal de desarrolladores basado en Backstage
spec:
  type: website
  lifecycle: production
  owner: devops-team
  system: ia-ops-platform
EOF
fi

# 9. Iniciar Backstage con configuración simplificada
log "🚀 Iniciando Backstage con configuración simplificada..."
log "📍 Usando configuración: app-config-simple.yaml"
log "🌐 Frontend: http://localhost:3002"
log "🔧 Backend: http://localhost:7007"

# Exportar variables de entorno
export NODE_ENV=development
export NODE_OPTIONS="--max-old-space-size=4096"

# Iniciar con configuración simplificada
yarn start --config app-config-simple.yaml
