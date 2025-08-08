#!/bin/bash

# =============================================================================
# SCRIPT DE DIAGNÓSTICO - AUTENTICACIÓN BACKSTAGE
# =============================================================================
# Diagnostica problemas de autenticación y proporciona soluciones

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

print_status "=== DIAGNÓSTICO DE AUTENTICACIÓN BACKSTAGE ==="
echo

# Cargar variables de entorno
if [ -f ".env" ]; then
    source .env
else
    print_error "Archivo .env no encontrado"
    exit 1
fi

# 1. Verificar variables de autenticación
print_status "1. Verificando variables de autenticación..."

if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    print_error "AUTH_GITHUB_CLIENT_ID no está definida"
else
    print_success "AUTH_GITHUB_CLIENT_ID: $AUTH_GITHUB_CLIENT_ID"
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    print_error "AUTH_GITHUB_CLIENT_SECRET no está definida"
else
    print_success "AUTH_GITHUB_CLIENT_SECRET: [OCULTO]"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GITHUB_TOKEN no está definida"
else
    print_success "GITHUB_TOKEN: [OCULTO]"
fi

if [ -z "$BACKEND_SECRET" ]; then
    print_error "BACKEND_SECRET no está definida"
else
    print_success "BACKEND_SECRET: [OCULTO]"
fi

echo

# 2. Verificar configuración de GitHub OAuth App
print_status "2. Verificando configuración de GitHub OAuth App..."

print_status "Callback URL configurada: $AUTH_GITHUB_CALLBACK_URL"

# Verificar que el callback URL sea correcto
if [[ "$AUTH_GITHUB_CALLBACK_URL" == *":3000/api/auth/github/handler/frame" ]]; then
    print_success "Callback URL parece correcto para frontend"
elif [[ "$AUTH_GITHUB_CALLBACK_URL" == *":7007/api/auth/github/handler/frame" ]]; then
    print_success "Callback URL parece correcto para backend"
else
    print_warning "Callback URL puede ser incorrecto"
    print_status "URLs esperadas:"
    print_status "  Frontend: http://localhost:3000/api/auth/github/handler/frame"
    print_status "  Backend:  http://localhost:7007/api/auth/github/handler/frame"
fi

echo

# 3. Verificar entidades de usuario en el catálogo
print_status "3. Verificando entidades de usuario..."

if [ -f "catalog-info.yaml" ]; then
    user_count=$(grep -c "kind: User" catalog-info.yaml || echo "0")
    print_status "Usuarios encontrados en catalog-info.yaml: $user_count"
    
    if [ "$user_count" -gt 0 ]; then
        print_status "Usuarios definidos:"
        grep -A 2 "kind: User" catalog-info.yaml | grep "name:" | sed 's/.*name: /  - /'
    else
        print_error "No se encontraron usuarios en catalog-info.yaml"
    fi
else
    print_error "catalog-info.yaml no encontrado"
fi

if [ -f "users.yaml" ]; then
    user_count=$(grep -c "kind: User" users.yaml || echo "0")
    print_status "Usuarios encontrados en users.yaml: $user_count"
else
    print_warning "users.yaml no encontrado"
fi

echo

# 4. Verificar estado de los servicios
print_status "4. Verificando estado de los servicios..."

services=("ia-ops-postgres" "backstage-backend" "backstage-frontend")

for service in "${services[@]}"; do
    if docker-compose ps "$service" | grep -q "Up"; then
        print_success "$service está corriendo"
    else
        print_error "$service no está corriendo"
    fi
done

echo

# 5. Verificar conectividad de la base de datos
print_status "5. Verificando conectividad de la base de datos..."

if docker-compose exec -T ia-ops-postgres pg_isready -U postgres >/dev/null 2>&1; then
    print_success "Base de datos PostgreSQL está disponible"
    
    # Verificar si existen tablas de Backstage
    table_count=$(docker-compose exec -T ia-ops-postgres psql -U postgres -d backstage -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ' || echo "0")
    
    if [ "$table_count" -gt 0 ]; then
        print_success "Base de datos tiene $table_count tablas"
    else
        print_warning "Base de datos parece estar vacía"
    fi
else
    print_error "No se puede conectar a la base de datos PostgreSQL"
fi

echo

# 6. Verificar endpoints de Backstage
print_status "6. Verificando endpoints de Backstage..."

# Backend API
if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    print_success "Backend API (puerto 7007) está respondiendo"
else
    print_error "Backend API (puerto 7007) no responde"
fi

# Frontend
if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    print_success "Frontend (puerto 3000) está respondiendo"
else
    print_error "Frontend (puerto 3000) no responde"
fi

# Auth endpoint
if curl -s "http://localhost:7007/api/auth/github/start" | grep -q "github.com"; then
    print_success "Endpoint de autenticación GitHub está configurado"
else
    print_warning "Endpoint de autenticación GitHub puede tener problemas"
fi

echo

# 7. Verificar logs de errores
print_status "7. Verificando logs recientes..."

print_status "Últimos errores en backend:"
docker-compose logs --tail=10 backstage-backend 2>/dev/null | grep -i error || print_status "No se encontraron errores recientes"

echo

print_status "Últimos errores en frontend:"
docker-compose logs --tail=10 backstage-frontend 2>/dev/null | grep -i error || print_status "No se encontraron errores recientes"

echo

# 8. Recomendaciones
print_status "8. Recomendaciones para solucionar problemas:"
echo

print_status "Si el problema persiste, intenta:"
print_status "1. Ejecutar el script de corrección: ./scripts/fix-backstage-auth.sh"
print_status "2. Verificar la configuración de GitHub OAuth App en:"
print_status "   https://github.com/settings/applications/${AUTH_GITHUB_CLIENT_ID}"
print_status "3. Asegurar que el callback URL en GitHub coincida con:"
print_status "   $AUTH_GITHUB_CALLBACK_URL"
print_status "4. Limpiar la base de datos y reiniciar:"
print_status "   docker-compose down && docker volume rm ia-ops_postgres_data"
print_status "5. Verificar que tu usuario GitHub esté en el catálogo"

echo

# 9. Información de debug
print_status "9. Información de debug:"
print_status "GitHub Org: $GITHUB_ORG"
print_status "GitHub User: $GITHUB_USER"
print_status "Backstage Base URL: $BACKSTAGE_BASE_URL"
print_status "Backstage Backend URL: $BACKSTAGE_BACKEND_URL"

echo
print_status "=== FIN DEL DIAGNÓSTICO ==="
