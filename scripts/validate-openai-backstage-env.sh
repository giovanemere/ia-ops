#!/bin/bash

# =============================================================================
# VALIDADOR DE VARIABLES DE ENTORNO - INTEGRACIÓN OPENAI-BACKSTAGE
# =============================================================================
# Descripción: Valida que todas las variables necesarias estén configuradas
# Uso: ./scripts/validate-openai-backstage-env.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Cargar variables de entorno
if [ -f .env ]; then
    source .env
    log_info "Cargando variables desde .env"
else
    log_error "Archivo .env no encontrado"
    exit 1
fi

echo "🔍 Validando configuración de integración OpenAI-Backstage..."
echo "=================================================="

# Contador de errores
ERRORS=0

# =============================================================================
# VALIDAR VARIABLES CRÍTICAS
# =============================================================================

log_info "Validando variables críticas..."

# Variables requeridas
REQUIRED_VARS=(
    "OPENAI_API_KEY"
    "OPENAI_MODEL"
    "BACKSTAGE_BASE_URL"
    "BACKSTAGE_BACKEND_URL"
    "OPENAI_SERVICE_URL"
    "POSTGRES_HOST"
    "POSTGRES_PASSWORD"
    "POSTGRES_DB"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        log_error "Variable requerida $var no está definida"
        ((ERRORS++))
    else
        log_success "$var está definida"
    fi
done

# =============================================================================
# VALIDAR CONFIGURACIÓN OPENAI
# =============================================================================

log_info "Validando configuración OpenAI..."

# Verificar API Key format
if [[ ! -z "$OPENAI_API_KEY" ]]; then
    if [[ "$OPENAI_API_KEY" =~ ^sk-[a-zA-Z0-9-_]{20,}$ ]] || [[ "$OPENAI_DEMO_MODE" == "true" ]]; then
        log_success "Formato de OPENAI_API_KEY válido o modo demo activado"
    else
        log_warning "Formato de OPENAI_API_KEY podría ser inválido"
    fi
fi

# Verificar modelo
VALID_MODELS=("gpt-4" "gpt-4-turbo" "gpt-4o" "gpt-4o-mini" "gpt-3.5-turbo")
if [[ " ${VALID_MODELS[@]} " =~ " ${OPENAI_MODEL} " ]]; then
    log_success "Modelo OpenAI válido: $OPENAI_MODEL"
else
    log_warning "Modelo OpenAI no reconocido: $OPENAI_MODEL"
fi

# Verificar parámetros numéricos
if [[ "$OPENAI_MAX_TOKENS" =~ ^[0-9]+$ ]] && [ "$OPENAI_MAX_TOKENS" -gt 0 ] && [ "$OPENAI_MAX_TOKENS" -le 4096 ]; then
    log_success "OPENAI_MAX_TOKENS válido: $OPENAI_MAX_TOKENS"
else
    log_error "OPENAI_MAX_TOKENS debe ser un número entre 1 y 4096"
    ((ERRORS++))
fi

if [[ "$OPENAI_TEMPERATURE" =~ ^[0-9]*\.?[0-9]+$ ]] && (( $(echo "$OPENAI_TEMPERATURE >= 0" | bc -l) )) && (( $(echo "$OPENAI_TEMPERATURE <= 2" | bc -l) )); then
    log_success "OPENAI_TEMPERATURE válida: $OPENAI_TEMPERATURE"
else
    log_error "OPENAI_TEMPERATURE debe ser un número entre 0.0 y 2.0"
    ((ERRORS++))
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN BACKSTAGE
# =============================================================================

log_info "Validando configuración Backstage..."

# Verificar URLs
if [[ "$BACKSTAGE_BASE_URL" =~ ^https?:// ]]; then
    log_success "BACKSTAGE_BASE_URL tiene formato válido"
else
    log_error "BACKSTAGE_BASE_URL debe comenzar con http:// o https://"
    ((ERRORS++))
fi

if [[ "$BACKSTAGE_BACKEND_URL" =~ ^https?:// ]]; then
    log_success "BACKSTAGE_BACKEND_URL tiene formato válido"
else
    log_error "BACKSTAGE_BACKEND_URL debe comenzar con http:// o https://"
    ((ERRORS++))
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN DE BASE DE DATOS
# =============================================================================

log_info "Validando configuración de base de datos..."

# Verificar puerto PostgreSQL
if [[ "$POSTGRES_PORT" =~ ^[0-9]+$ ]] && [ "$POSTGRES_PORT" -gt 0 ] && [ "$POSTGRES_PORT" -le 65535 ]; then
    log_success "POSTGRES_PORT válido: $POSTGRES_PORT"
else
    log_error "POSTGRES_PORT debe ser un número entre 1 y 65535"
    ((ERRORS++))
fi

# Verificar DATABASE_URL format
if [[ "$DATABASE_URL" =~ ^postgresql:// ]]; then
    log_success "DATABASE_URL tiene formato válido"
else
    log_error "DATABASE_URL debe comenzar con postgresql://"
    ((ERRORS++))
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN DE RED
# =============================================================================

log_info "Validando configuración de red..."

# Verificar puertos de servicios
PORTS_TO_CHECK=(
    "OPENAI_SERVICE_PORT"
    "DEV_BACKSTAGE_FRONTEND_PORT"
    "DEV_BACKSTAGE_BACKEND_PORT"
    "DEV_PROXY_PORT"
)

for port_var in "${PORTS_TO_CHECK[@]}"; do
    port_value="${!port_var}"
    if [[ "$port_value" =~ ^[0-9]+$ ]] && [ "$port_value" -gt 0 ] && [ "$port_value" -le 65535 ]; then
        log_success "$port_var válido: $port_value"
    else
        log_error "$port_var debe ser un número entre 1 y 65535"
        ((ERRORS++))
    fi
done

# =============================================================================
# TESTS DE CONECTIVIDAD
# =============================================================================

log_info "Ejecutando tests de conectividad..."

# Test de conectividad a servicios (si están corriendo)
test_service_connectivity() {
    local service_name=$1
    local url=$2
    local timeout=${3:-5}
    
    if command -v curl >/dev/null 2>&1; then
        if curl -f -s --max-time $timeout "$url" >/dev/null 2>&1; then
            log_success "$service_name está accesible en $url"
        else
            log_warning "$service_name no está accesible en $url (puede estar apagado)"
        fi
    else
        log_warning "curl no disponible, saltando test de conectividad"
    fi
}

# Solo hacer tests si los servicios deberían estar corriendo
if docker ps --format "table {{.Names}}" | grep -q "openai-service"; then
    test_service_connectivity "OpenAI Service" "http://localhost:${DEV_OPENAI_PORT:-8000}/health"
fi

if docker ps --format "table {{.Names}}" | grep -q "backstage"; then
    test_service_connectivity "Backstage Backend" "http://localhost:${DEV_BACKSTAGE_BACKEND_PORT:-7007}/health"
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN DE SEGURIDAD
# =============================================================================

log_info "Validando configuración de seguridad..."

# Verificar que no se usen passwords por defecto en producción
if [[ "$NODE_ENV" == "production" ]]; then
    DEFAULT_PASSWORDS=("password" "123456" "admin" "postgres123" "redis123")
    
    for default_pass in "${DEFAULT_PASSWORDS[@]}"; do
        if [[ "$POSTGRES_PASSWORD" == "$default_pass" ]] || [[ "$REDIS_PASSWORD" == "$default_pass" ]]; then
            log_error "No usar passwords por defecto en producción: $default_pass"
            ((ERRORS++))
        fi
    done
    
    if [[ "$OPENAI_DEMO_MODE" == "true" ]]; then
        log_warning "Modo demo activado en producción"
    fi
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN ESPECÍFICA DE INTEGRACIÓN
# =============================================================================

log_info "Validando configuración específica de integración..."

# Verificar que las URLs de servicios sean consistentes
if [[ "$OPENAI_SERVICE_URL" != "http://${OPENAI_SERVICE_HOST}:${OPENAI_SERVICE_PORT}" ]]; then
    log_warning "OPENAI_SERVICE_URL no es consistente con HOST:PORT"
fi

# Verificar configuración CORS
if [[ -z "$CORS_ORIGIN" ]]; then
    log_warning "CORS_ORIGIN no está configurado"
else
    log_success "CORS_ORIGIN configurado: $CORS_ORIGIN"
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

echo "=================================================="
echo "🏁 Resumen de validación:"

if [ $ERRORS -eq 0 ]; then
    log_success "✨ Todas las validaciones pasaron correctamente"
    log_info "La integración OpenAI-Backstage está lista para usar"
    exit 0
else
    log_error "❌ Se encontraron $ERRORS errores que deben corregirse"
    log_info "Por favor, revisa las variables marcadas con error"
    exit 1
fi
