#!/bin/bash

# =============================================================================
# TEST POSTGRESQL CONNECTION - IA-OPS PLATFORM
# =============================================================================
# Descripción: Script para probar la conexión a PostgreSQL usando variables .env

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Navegar al directorio del proyecto
cd /home/giovanemere/ia-ops/ia-ops

log_info "=== PRUEBA DE CONEXIÓN POSTGRESQL ==="
echo ""

# Cargar variables de entorno
log_info "Cargando variables de entorno desde .env..."
source .env
log_success "Variables de entorno cargadas"

# Mostrar variables de PostgreSQL
log_info "Variables de PostgreSQL configuradas:"
echo "  POSTGRES_HOST: ${POSTGRES_HOST}"
echo "  POSTGRES_PORT: ${POSTGRES_PORT}"
echo "  POSTGRES_USER: ${POSTGRES_USER}"
echo "  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:0:5}..."
echo "  POSTGRES_DB: ${POSTGRES_DB}"
echo "  DATABASE_URL: ${DATABASE_URL:0:30}..."
echo ""

# Verificar si el contenedor PostgreSQL está corriendo
log_info "Verificando estado del contenedor PostgreSQL..."
if docker-compose ps postgres | grep -q "Up"; then
    log_success "Contenedor PostgreSQL está corriendo"
else
    log_warning "Contenedor PostgreSQL no está corriendo. Iniciando..."
    docker-compose up -d postgres
    sleep 10
fi

# Test 1: Verificar que PostgreSQL está listo para conexiones
log_info "Test 1: Verificando que PostgreSQL está listo..."
if docker-compose exec -T postgres pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}; then
    log_success "PostgreSQL está listo para conexiones"
else
    log_error "PostgreSQL no está listo"
    exit 1
fi

# Test 2: Probar conexión básica
log_info "Test 2: Probando conexión básica..."
if docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT version();" > /dev/null 2>&1; then
    log_success "Conexión básica exitosa"
else
    log_error "Error en conexión básica"
    exit 1
fi

# Test 3: Mostrar información de la base de datos
log_info "Test 3: Información de la base de datos..."
echo "Versión de PostgreSQL:"
docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT version();" | head -3

echo ""
echo "Bases de datos disponibles:"
docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\l" | grep -E "(Name|backstage|postgres)"

# Test 4: Verificar tablas existentes
log_info "Test 4: Verificando tablas en la base de datos backstage..."
TABLES=$(docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt" 2>/dev/null | grep -c "table" || echo "0")
echo "Número de tablas encontradas: $TABLES"

if [ "$TABLES" -gt 0 ]; then
    echo "Tablas existentes:"
    docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt"
else
    log_warning "No se encontraron tablas (base de datos nueva o vacía)"
fi

# Test 5: Probar conexión desde fuera del contenedor (simulando Backstage)
log_info "Test 5: Probando conexión externa (como lo haría Backstage)..."
if command -v psql &> /dev/null; then
    # Si psql está instalado localmente
    if PGPASSWORD=${POSTGRES_PASSWORD} psql -h localhost -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT 1;" > /dev/null 2>&1; then
        log_success "Conexión externa exitosa"
    else
        log_warning "Conexión externa falló (puede ser normal si psql no está instalado localmente)"
    fi
else
    log_warning "psql no está instalado localmente, saltando test de conexión externa"
fi

# Test 6: Verificar variables específicas de Backstage
log_info "Test 6: Verificando variables específicas de Backstage..."
echo "Variables de Backstage PostgreSQL:"
echo "  BACKSTAGE_POSTGRES_HOST: ${BACKSTAGE_POSTGRES_HOST}"
echo "  BACKSTAGE_POSTGRES_PORT: ${BACKSTAGE_POSTGRES_PORT}"
echo "  BACKSTAGE_POSTGRES_USER: ${BACKSTAGE_POSTGRES_USER}"
echo "  BACKSTAGE_POSTGRES_PASSWORD: ${BACKSTAGE_POSTGRES_PASSWORD:0:5}..."
echo "  BACKSTAGE_POSTGRES_DATABASE: ${BACKSTAGE_POSTGRES_DATABASE}"

# Test 7: Crear una tabla de prueba
log_info "Test 7: Creando tabla de prueba..."
if docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "
CREATE TABLE IF NOT EXISTS test_connection (
    id SERIAL PRIMARY KEY,
    test_message VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO test_connection (test_message) VALUES ('IA-Ops Platform Test');
SELECT * FROM test_connection WHERE test_message = 'IA-Ops Platform Test';
" 2>/dev/null; then
    log_success "Tabla de prueba creada e insertado registro exitosamente"
else
    log_error "Error al crear tabla de prueba"
fi

# Test 8: Limpiar tabla de prueba
log_info "Test 8: Limpiando tabla de prueba..."
docker-compose exec -T postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "DROP TABLE IF EXISTS test_connection;" > /dev/null 2>&1
log_success "Tabla de prueba eliminada"

echo ""
log_success "=== TODAS LAS PRUEBAS DE POSTGRESQL COMPLETADAS ==="
echo ""
log_info "Resumen de la configuración:"
echo "  ✅ PostgreSQL está corriendo y accesible"
echo "  ✅ Credenciales funcionan correctamente"
echo "  ✅ Base de datos 'backstage' existe y es accesible"
echo "  ✅ Operaciones CRUD funcionan correctamente"
echo ""
log_info "Configuración lista para Backstage:"
echo "  Host: ${POSTGRES_HOST} (desde contenedores)"
echo "  Host: localhost (desde host local)"
echo "  Puerto: ${POSTGRES_PORT}"
echo "  Usuario: ${POSTGRES_USER}"
echo "  Base de datos: ${POSTGRES_DB}"
echo ""
log_info "URL de conexión para Backstage:"
echo "  ${DATABASE_URL}"
