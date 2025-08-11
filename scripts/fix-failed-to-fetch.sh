#!/bin/bash

# =============================================================================
# SCRIPT PARA SOLUCIONAR "TypeError: Failed to fetch" EN BACKSTAGE
# =============================================================================
# Soluciona problemas de conectividad entre frontend y backend

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

print_status "=== SOLUCIONANDO ERROR 'Failed to fetch' EN BACKSTAGE ==="
echo

# Cargar variables de entorno
if [ -f ".env" ]; then
    print_status "Cargando variables de entorno..."
    source .env
    print_success "Variables cargadas"
else
    print_error "Archivo .env no encontrado"
    exit 1
fi

# 1. Verificar variables críticas
print_status "1. Verificando variables críticas..."

critical_vars=(
    "BACKEND_SECRET"
    "POSTGRES_HOST"
    "POSTGRES_USER"
    "POSTGRES_PASSWORD"
    "POSTGRES_DB"
    "BACKSTAGE_BASE_URL"
    "BACKSTAGE_BACKEND_URL"
)

missing_vars=()
for var in "${critical_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    else
        print_success "$var está definida"
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Variables faltantes: ${missing_vars[*]}"
    exit 1
fi

# Verificar que BACKEND_SECRET tenga la longitud correcta
if [ ${#BACKEND_SECRET} -lt 32 ]; then
    print_error "BACKEND_SECRET es demasiado corta (mínimo 32 caracteres)"
    print_status "Generando nueva BACKEND_SECRET..."
    
    new_secret=$(openssl rand -hex 32)
    print_status "Nueva BACKEND_SECRET generada: $new_secret"
    print_warning "Actualiza tu archivo .env con: BACKEND_SECRET=$new_secret"
fi

echo

# 2. Detener servicios existentes
print_status "2. Deteniendo servicios existentes..."
docker-compose down 2>/dev/null || true
print_success "Servicios detenidos"

# 3. Limpiar contenedores y volúmenes problemáticos
print_status "3. Limpiando contenedores problemáticos..."
docker container prune -f >/dev/null 2>&1 || true
print_success "Contenedores limpiados"

# 4. Verificar y crear configuración de Backstage
print_status "4. Verificando configuración de Backstage..."

# Crear app-config.yaml temporal si no existe
if [ ! -f "app-config.yaml" ]; then
    print_status "Creando app-config.yaml temporal..."
    cat > app-config.yaml << EOF
app:
  title: IA-Ops Platform
  baseUrl: http://localhost:3000

organization:
  name: IA-Ops

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  csp:
    connect-src: ["'self'", 'http:', 'https:']
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: pg
    connection:
      host: \${POSTGRES_HOST}
      port: \${POSTGRES_PORT}
      user: \${POSTGRES_USER}
      password: \${POSTGRES_PASSWORD}
      database: \${POSTGRES_DB}

auth:
  environment: development
  session:
    secret: \${BACKEND_SECRET}
  providers:
    github:
      development:
        clientId: \${AUTH_GITHUB_CLIENT_ID}
        clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location, User, Group, Domain]
  locations:
    - type: file
      target: ./catalog-info.yaml
    - type: file
      target: ./users.yaml

integrations:
  github:
    - host: github.com
      token: \${GITHUB_TOKEN}

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'

search:
  pg:
    highlightOptions:
      useHighlight: true
EOF
    print_success "app-config.yaml creado"
fi

echo

# 5. Iniciar base de datos primero
print_status "5. Iniciando base de datos..."
docker-compose up -d postgres
print_status "Esperando que PostgreSQL esté listo..."

# Esperar que PostgreSQL esté listo
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if docker-compose exec -T postgres pg_isready -U $POSTGRES_USER -d $POSTGRES_DB >/dev/null 2>&1; then
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

echo

# 6. Verificar conectividad de base de datos
print_status "6. Verificando conectividad de base de datos..."

# Crear base de datos si no existe
docker-compose exec -T postgres psql -U $POSTGRES_USER -c "CREATE DATABASE $POSTGRES_DB;" 2>/dev/null || true

# Verificar conexión
if docker-compose exec -T postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" >/dev/null 2>&1; then
    print_success "Conexión a base de datos exitosa"
else
    print_error "No se puede conectar a la base de datos"
    exit 1
fi

echo

# 7. Iniciar Backstage backend
print_status "7. Iniciando Backstage backend..."

# Verificar si existe el servicio backstage-backend en docker-compose
if docker-compose config --services | grep -q "backstage-backend"; then
    docker-compose up -d backstage-backend
    print_status "Esperando que el backend esté listo..."
    
    # Esperar que el backend responda
    max_attempts=60
    attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
            print_success "Backstage backend está respondiendo"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "Timeout esperando Backstage backend"
            print_status "Verificando logs del backend..."
            docker-compose logs --tail=20 backstage-backend
            exit 1
        fi
        
        print_status "Intento $attempt/$max_attempts - Esperando backend..."
        sleep 3
        ((attempt++))
    done
else
    print_warning "Servicio backstage-backend no encontrado en docker-compose.yml"
    print_status "Iniciando Backstage con configuración alternativa..."
    
    # Usar imagen oficial de Backstage
    docker run -d \
        --name backstage-backend-temp \
        --network ia-ops_ia-ops-network \
        -p 7007:7007 \
        -e POSTGRES_HOST=$POSTGRES_HOST \
        -e POSTGRES_PORT=$POSTGRES_PORT \
        -e POSTGRES_USER=$POSTGRES_USER \
        -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
        -e POSTGRES_DB=$POSTGRES_DB \
        -e BACKEND_SECRET=$BACKEND_SECRET \
        -e AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID \
        -e AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET \
        -e GITHUB_TOKEN=$GITHUB_TOKEN \
        -v $(pwd)/app-config.yaml:/app/app-config.yaml \
        -v $(pwd)/catalog-info.yaml:/app/catalog-info.yaml \
        -v $(pwd)/users.yaml:/app/users.yaml \
        backstage/backstage:latest
fi

echo

# 8. Iniciar Backstage frontend
print_status "8. Iniciando Backstage frontend..."

if docker-compose config --services | grep -q "backstage-frontend"; then
    docker-compose up -d backstage-frontend
    print_status "Esperando que el frontend esté listo..."
    
    # Esperar que el frontend responda
    max_attempts=30
    attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
            print_success "Backstage frontend está respondiendo"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_warning "Frontend no responde, pero puede estar iniciando"
            break
        fi
        
        print_status "Intento $attempt/$max_attempts - Esperando frontend..."
        sleep 2
        ((attempt++))
    done
else
    print_warning "Servicio backstage-frontend no encontrado"
fi

echo

# 9. Verificar conectividad completa
print_status "9. Verificando conectividad completa..."

# Verificar backend API
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

# Verificar CORS
cors_test=$(curl -s -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: X-Requested-With" -X OPTIONS "http://localhost:7007/api/catalog/entities" -w "%{http_code}" -o /dev/null)

if [ "$cors_test" = "200" ] || [ "$cors_test" = "204" ]; then
    print_success "✅ CORS está configurado correctamente"
else
    print_warning "⚠️  CORS puede tener problemas (código: $cors_test)"
fi

echo

# 10. Mostrar información de acceso
print_status "10. Información de acceso:"
echo
print_success "🌐 Frontend: http://localhost:3000"
print_success "🔧 Backend API: http://localhost:7007"
print_success "📊 Catalog API: http://localhost:7007/api/catalog/entities"
print_success "🔍 Search API: http://localhost:7007/api/search/query"
echo

# 11. Mostrar logs si hay errores
print_status "11. Verificando logs recientes..."

if docker-compose logs --tail=5 backstage-backend 2>/dev/null | grep -i error; then
    print_warning "Se encontraron errores en el backend. Logs completos:"
    docker-compose logs --tail=20 backstage-backend
fi

echo

print_status "=== SOLUCIÓN COMPLETADA ==="
print_success "Si el error 'Failed to fetch' persiste:"
print_status "1. Verifica que ambos servicios estén corriendo"
print_status "2. Verifica la consola del navegador para más detalles"
print_status "3. Intenta refrescar la página (Ctrl+F5)"
print_status "4. Verifica que no haya bloqueadores de contenido"

echo
print_status "Para ver logs en tiempo real:"
print_status "docker-compose logs -f backstage-backend backstage-frontend"
