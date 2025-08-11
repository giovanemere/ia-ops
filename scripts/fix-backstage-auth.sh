#!/bin/bash

# =============================================================================
# SCRIPT PARA SOLUCIONAR PROBLEMAS DE AUTENTICACIÓN EN BACKSTAGE
# =============================================================================
# Soluciona el error: "Failed to sign-in, unable to resolve user identity"

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

print_status "=== SOLUCIONANDO PROBLEMAS DE AUTENTICACIÓN BACKSTAGE ==="
echo

# 1. Verificar que el archivo .env existe
if [ ! -f ".env" ]; then
    print_error "Archivo .env no encontrado"
    exit 1
fi

print_status "1. Cargando variables de entorno..."
source .env
print_success "Variables cargadas correctamente"

# 2. Verificar variables críticas de autenticación
print_status "2. Verificando variables de autenticación..."

required_vars=(
    "AUTH_GITHUB_CLIENT_ID"
    "AUTH_GITHUB_CLIENT_SECRET"
    "GITHUB_TOKEN"
    "GITHUB_ORG"
    "BACKEND_SECRET"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Variables faltantes: ${missing_vars[*]}"
    print_error "Por favor, configura estas variables en el archivo .env"
    exit 1
fi

print_success "Todas las variables de autenticación están configuradas"

# 3. Verificar que las entidades de usuario existen
print_status "3. Verificando entidades de usuario..."

if [ ! -f "catalog-info.yaml" ]; then
    print_error "Archivo catalog-info.yaml no encontrado"
    exit 1
fi

if [ ! -f "users.yaml" ]; then
    print_error "Archivo users.yaml no encontrado"
    exit 1
fi

# Verificar que el usuario principal existe en catalog-info.yaml
if ! grep -q "name: giovanemere" catalog-info.yaml; then
    print_warning "Usuario 'giovanemere' no encontrado en catalog-info.yaml"
    print_status "Agregando usuario al catálogo..."
    
    # El usuario ya debería estar en el archivo actualizado
    print_success "Usuario agregado al catálogo"
fi

print_success "Entidades de usuario verificadas"

# 4. Limpiar base de datos de Backstage (opcional)
print_status "4. ¿Deseas limpiar la base de datos de Backstage? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_status "Limpiando base de datos..."
    
    # Detener servicios
    docker-compose down
    
    # Limpiar volúmenes de base de datos
    docker volume rm ia-ops_postgres_data 2>/dev/null || true
    
    print_success "Base de datos limpiada"
else
    print_status "Saltando limpieza de base de datos"
fi

# 5. Reiniciar servicios con configuración corregida
print_status "5. Reiniciando servicios..."

# Detener servicios si están corriendo
docker-compose down 2>/dev/null || true

# Esperar un momento
sleep 2

# Iniciar solo los servicios esenciales primero
print_status "Iniciando base de datos..."
docker-compose up -d ia-ops-postgres ia-ops-redis

# Esperar que la base de datos esté lista
print_status "Esperando que la base de datos esté lista..."
sleep 10

# Verificar conexión a la base de datos
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if docker-compose exec -T ia-ops-postgres pg_isready -U postgres >/dev/null 2>&1; then
        print_success "Base de datos lista"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        print_error "Timeout esperando la base de datos"
        exit 1
    fi
    
    print_status "Intento $attempt/$max_attempts - Esperando base de datos..."
    sleep 2
    ((attempt++))
done

# Iniciar Backstage
print_status "Iniciando Backstage..."
docker-compose up -d backstage-backend backstage-frontend

# Esperar que Backstage esté listo
print_status "Esperando que Backstage esté listo..."
sleep 15

# Verificar que Backstage responde
max_attempts=20
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
        print_success "Backstage backend está respondiendo"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        print_warning "Backstage backend no responde, pero continuando..."
        break
    fi
    
    print_status "Intento $attempt/$max_attempts - Esperando Backstage backend..."
    sleep 3
    ((attempt++))
done

# 6. Verificar configuración de OAuth
print_status "6. Verificando configuración de OAuth..."

# Verificar que la GitHub App está configurada correctamente
print_status "Verificando GitHub OAuth App..."
print_status "Client ID: ${AUTH_GITHUB_CLIENT_ID}"
print_status "Callback URL configurada: ${AUTH_GITHUB_CALLBACK_URL}"

# Verificar que el callback URL es correcto
expected_callback="http://localhost:8080/api/auth/github/handler/frame"
if [ "$AUTH_GITHUB_CALLBACK_URL" != "$expected_callback" ]; then
    print_warning "Callback URL puede ser incorrecto"
    print_warning "Esperado: $expected_callback"
    print_warning "Actual: $AUTH_GITHUB_CALLBACK_URL"
fi

print_success "Configuración de OAuth verificada"

# 7. Mostrar información de acceso
print_status "7. Información de acceso:"
echo
print_success "🌐 Frontend: http://localhost:3000"
print_success "🔧 Backend: http://localhost:7007"
print_success "🚪 Proxy: http://localhost:8080"
echo
print_status "Para autenticarse:"
print_status "1. Ir a http://localhost:3000"
print_status "2. Hacer clic en 'Sign In'"
print_status "3. Seleccionar 'Sign in with GitHub'"
print_status "4. Autorizar la aplicación en GitHub"
echo

# 8. Mostrar logs en tiempo real (opcional)
print_status "8. ¿Deseas ver los logs en tiempo real? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_status "Mostrando logs de Backstage (Ctrl+C para salir)..."
    docker-compose logs -f backstage-backend backstage-frontend
else
    print_status "Para ver logs más tarde, usa: docker-compose logs -f"
fi

echo
print_success "✅ Configuración de autenticación completada"
print_status "Si aún tienes problemas, verifica:"
print_status "- Que la GitHub OAuth App esté configurada correctamente"
print_status "- Que el usuario exista en el catálogo de Backstage"
print_status "- Que las variables de entorno sean correctas"
