#!/bin/bash

# =============================================================================
# TEST DE INTEGRACIÓN OPENAI-BACKSTAGE
# =============================================================================
# Descripción: Prueba completa de la integración entre OpenAI y Backstage
# Uso: ./scripts/test-openai-backstage-integration.sh

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
    log_info "Variables de entorno cargadas desde .env"
else
    log_error "Archivo .env no encontrado"
    exit 1
fi

echo "🧪 Iniciando tests de integración OpenAI-Backstage..."
echo "=================================================="

# Contador de tests
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Función para ejecutar test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_status="${3:-0}"
    
    ((TOTAL_TESTS++))
    log_info "Test: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [ $? -eq $expected_status ]; then
            log_success "PASS: $test_name"
            ((PASSED_TESTS++))
        else
            log_error "FAIL: $test_name (unexpected exit status)"
            ((FAILED_TESTS++))
        fi
    else
        log_error "FAIL: $test_name"
        ((FAILED_TESTS++))
    fi
}

# Función para test HTTP
test_http() {
    local test_name="$1"
    local url="$2"
    local expected_status="${3:-200}"
    local method="${4:-GET}"
    local data="${5:-}"
    
    ((TOTAL_TESTS++))
    log_info "Test HTTP: $test_name"
    
    local curl_cmd="curl -s -w '%{http_code}' -o /dev/null"
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        curl_cmd="$curl_cmd -X POST -H 'Content-Type: application/json' -d '$data'"
    fi
    
    curl_cmd="$curl_cmd '$url'"
    
    local status_code=$(eval $curl_cmd)
    
    if [ "$status_code" = "$expected_status" ]; then
        log_success "PASS: $test_name (HTTP $status_code)"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: $test_name (Expected HTTP $expected_status, got $status_code)"
        ((FAILED_TESTS++))
    fi
}

# =============================================================================
# TESTS DE PREREQUISITOS
# =============================================================================

log_info "Verificando prerequisitos..."

# Verificar que Docker esté corriendo
run_test "Docker está corriendo" "docker ps"

# Verificar que curl esté disponible
run_test "curl está disponible" "command -v curl"

# Verificar que jq esté disponible (opcional)
if command -v jq >/dev/null 2>&1; then
    log_success "jq está disponible para parsing JSON"
else
    log_warning "jq no está disponible, algunos tests serán limitados"
fi

# =============================================================================
# TESTS DE SERVICIOS BASE
# =============================================================================

log_info "Verificando servicios base..."

# Verificar que los contenedores estén corriendo
REQUIRED_CONTAINERS=("ia-ops-postgres" "ia-ops-openai-service")

for container in "${REQUIRED_CONTAINERS[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        log_success "Contenedor $container está corriendo"
        ((PASSED_TESTS++))
    else
        log_error "Contenedor $container no está corriendo"
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
done

# =============================================================================
# TESTS DE CONECTIVIDAD OPENAI SERVICE
# =============================================================================

log_info "Probando conectividad del servicio OpenAI..."

# Test health check directo
OPENAI_DIRECT_URL="http://localhost:${DEV_OPENAI_PORT:-8000}"
test_http "OpenAI Service Health Check" "$OPENAI_DIRECT_URL/health" 200

# Test root endpoint
test_http "OpenAI Service Root" "$OPENAI_DIRECT_URL/" 200

# Test models endpoint
test_http "OpenAI Service Models" "$OPENAI_DIRECT_URL/models" 200

# Test chat completions (POST)
CHAT_DATA='{"messages":[{"role":"user","content":"Hello, this is a test"}],"model":"gpt-4o-mini","max_tokens":50}'
test_http "OpenAI Service Chat Completions" "$OPENAI_DIRECT_URL/chat/completions" 200 "POST" "$CHAT_DATA"

# =============================================================================
# TESTS DE BACKSTAGE (si está corriendo)
# =============================================================================

if docker ps --format "table {{.Names}}" | grep -q "backstage"; then
    log_info "Probando integración con Backstage..."
    
    BACKSTAGE_URL="http://localhost:${DEV_BACKSTAGE_BACKEND_PORT:-7007}"
    
    # Test Backstage health
    test_http "Backstage Backend Health" "$BACKSTAGE_URL/health" 200
    
    # Test proxy OpenAI health via Backstage
    test_http "OpenAI via Backstage Proxy Health" "$BACKSTAGE_URL/api/proxy/openai/health" 200
    
    # Test proxy OpenAI models via Backstage
    test_http "OpenAI Models via Backstage Proxy" "$BACKSTAGE_URL/api/proxy/openai/models" 200
    
    # Test proxy chat completions via Backstage
    test_http "OpenAI Chat via Backstage Proxy" "$BACKSTAGE_URL/api/proxy/openai/chat/completions" 200 "POST" "$CHAT_DATA"
    
else
    log_warning "Backstage no está corriendo, saltando tests de integración"
fi

# =============================================================================
# TESTS DE BASE DE DATOS
# =============================================================================

log_info "Probando conectividad de base de datos..."

# Test PostgreSQL connectivity
if command -v psql >/dev/null 2>&1; then
    PGPASSWORD="$POSTGRES_PASSWORD" psql -h localhost -p "${DEV_POSTGRES_PORT:-5432}" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_success "PASS: PostgreSQL connectivity"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: PostgreSQL connectivity"
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
else
    log_warning "psql no disponible, saltando test de PostgreSQL"
fi

# =============================================================================
# TESTS FUNCIONALES AVANZADOS
# =============================================================================

log_info "Ejecutando tests funcionales avanzados..."

# Test de respuesta JSON válida
if command -v jq >/dev/null 2>&1; then
    ((TOTAL_TESTS++))
    log_info "Test: Validación de respuesta JSON del servicio OpenAI"
    
    RESPONSE=$(curl -s -X POST "$OPENAI_DIRECT_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$CHAT_DATA")
    
    if echo "$RESPONSE" | jq . >/dev/null 2>&1; then
        log_success "PASS: Respuesta JSON válida"
        ((PASSED_TESTS++))
        
        # Verificar estructura de respuesta
        if echo "$RESPONSE" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
            log_success "PASS: Estructura de respuesta correcta"
            ((PASSED_TESTS++))
        else
            log_error "FAIL: Estructura de respuesta incorrecta"
            ((FAILED_TESTS++))
        fi
        ((TOTAL_TESTS++))
    else
        log_error "FAIL: Respuesta JSON inválida"
        ((FAILED_TESTS++))
    fi
fi

# Test de rate limiting (si está habilitado)
if [ "${OPENAI_RATE_LIMIT:-0}" -gt 0 ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Rate limiting"
    
    # Hacer múltiples requests rápidos
    for i in {1..5}; do
        curl -s "$OPENAI_DIRECT_URL/health" >/dev/null &
    done
    wait
    
    # El último request debería funcionar (test básico)
    if curl -s "$OPENAI_DIRECT_URL/health" >/dev/null; then
        log_success "PASS: Rate limiting no bloquea requests normales"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: Rate limiting demasiado restrictivo"
        ((FAILED_TESTS++))
    fi
fi

# =============================================================================
# TESTS DE CONFIGURACIÓN
# =============================================================================

log_info "Verificando configuración..."

# Test variables críticas
CRITICAL_VARS=("OPENAI_API_KEY" "OPENAI_MODEL" "BACKSTAGE_BASE_URL")

for var in "${CRITICAL_VARS[@]}"; do
    ((TOTAL_TESTS++))
    if [ -n "${!var}" ]; then
        log_success "PASS: Variable $var está configurada"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: Variable $var no está configurada"
        ((FAILED_TESTS++))
    fi
done

# Test modo demo
((TOTAL_TESTS++))
if [ "$OPENAI_DEMO_MODE" = "true" ]; then
    log_warning "PASS: Modo demo activado (desarrollo)"
    ((PASSED_TESTS++))
else
    log_success "PASS: Modo demo desactivado (producción)"
    ((PASSED_TESTS++))
fi

# =============================================================================
# TESTS DE SEGURIDAD BÁSICOS
# =============================================================================

log_info "Ejecutando tests de seguridad básicos..."

# Test CORS headers
((TOTAL_TESTS++))
CORS_RESPONSE=$(curl -s -I -H "Origin: http://localhost:3000" "$OPENAI_DIRECT_URL/health")
if echo "$CORS_RESPONSE" | grep -i "access-control-allow-origin" >/dev/null; then
    log_success "PASS: Headers CORS presentes"
    ((PASSED_TESTS++))
else
    log_warning "FAIL: Headers CORS no encontrados"
    ((FAILED_TESTS++))
fi

# Test que endpoints sensibles no estén expuestos
((TOTAL_TESTS++))
if curl -s "$OPENAI_DIRECT_URL/admin" | grep -q "404\|Not Found"; then
    log_success "PASS: Endpoints administrativos no expuestos"
    ((PASSED_TESTS++))
else
    log_warning "FAIL: Posibles endpoints administrativos expuestos"
    ((FAILED_TESTS++))
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

echo "=================================================="
echo "📊 Resumen de Tests:"
echo "   Total:   $TOTAL_TESTS"
echo "   Pasaron: $PASSED_TESTS"
echo "   Fallaron: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "🎉 Todos los tests pasaron! La integración OpenAI-Backstage está funcionando correctamente"
    
    # Información adicional
    echo ""
    log_info "🔗 URLs de acceso:"
    echo "   OpenAI Service: http://localhost:${DEV_OPENAI_PORT:-8000}"
    echo "   OpenAI Docs: http://localhost:${DEV_OPENAI_PORT:-8000}/docs"
    if docker ps --format "table {{.Names}}" | grep -q "backstage"; then
        echo "   Backstage: http://localhost:${DEV_PROXY_PORT:-8080}"
        echo "   Backstage API: http://localhost:${DEV_BACKSTAGE_BACKEND_PORT:-7007}"
    fi
    
    exit 0
else
    log_error "❌ $FAILED_TESTS tests fallaron. Revisa la configuración y servicios"
    
    echo ""
    log_info "🔧 Comandos de diagnóstico:"
    echo "   docker ps                                    # Ver contenedores"
    echo "   docker logs ia-ops-openai-service           # Logs OpenAI"
    echo "   ./scripts/validate-openai-backstage-env.sh  # Validar variables"
    
    exit 1
fi
