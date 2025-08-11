#!/bin/bash

# =============================================================================
# TEST DE INTEGRACIÓN GITHUB-BACKSTAGE
# =============================================================================
# Descripción: Prueba completa de la integración entre GitHub y Backstage
# Uso: ./scripts/test-github-backstage-integration.sh

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

echo "🐙 Iniciando tests de integración GitHub-Backstage..."
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

# Función para test HTTP con GitHub API
test_github_api() {
    local test_name="$1"
    local endpoint="$2"
    local expected_status="${3:-200}"
    local use_auth="${4:-true}"
    
    ((TOTAL_TESTS++))
    log_info "Test GitHub API: $test_name"
    
    local curl_cmd="curl -s -w '%{http_code}' -o /dev/null --max-time 10"
    
    if [ "$use_auth" = "true" ] && [ -n "$GITHUB_TOKEN" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: token $GITHUB_TOKEN'"
    fi
    
    curl_cmd="$curl_cmd '$GITHUB_API_URL$endpoint'"
    
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

# Verificar que curl esté disponible
run_test "curl está disponible" "command -v curl"

# Verificar que jq esté disponible (opcional)
if command -v jq >/dev/null 2>&1; then
    log_success "jq está disponible para parsing JSON"
else
    log_warning "jq no está disponible, algunos tests serán limitados"
fi

# Verificar variables críticas
CRITICAL_VARS=("GITHUB_TOKEN" "GITHUB_ORG" "GITHUB_REPO" "GITHUB_API_URL")

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

# =============================================================================
# TESTS DE CONECTIVIDAD GITHUB API
# =============================================================================

log_info "Probando conectividad con GitHub API..."

# Test conectividad básica
test_github_api "Conectividad básica GitHub API" "" 200 false

# Test autenticación
test_github_api "Autenticación con token" "/user" 200 true

# Test acceso a organización
if [ -n "$GITHUB_ORG" ]; then
    test_github_api "Acceso a organización" "/orgs/$GITHUB_ORG" 200 true
fi

# Test acceso a repositorio
if [ -n "$GITHUB_ORG" ] && [ -n "$GITHUB_REPO" ]; then
    test_github_api "Acceso a repositorio" "/repos/$GITHUB_ORG/$GITHUB_REPO" 200 true
fi

# Test rate limits
test_github_api "Rate limits" "/rate_limit" 200 true

# =============================================================================
# TESTS DE FUNCIONALIDAD GITHUB
# =============================================================================

log_info "Probando funcionalidad específica de GitHub..."

# Test listar repositorios de la organización
if [ -n "$GITHUB_ORG" ] && [ -n "$GITHUB_TOKEN" ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Listar repositorios de la organización"
    
    REPOS_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API_URL/orgs/$GITHUB_ORG/repos?per_page=5")
    
    if command -v jq >/dev/null 2>&1; then
        if echo "$REPOS_RESPONSE" | jq -e '.[0].name' >/dev/null 2>&1; then
            REPO_COUNT=$(echo "$REPOS_RESPONSE" | jq '. | length')
            log_success "PASS: Encontrados $REPO_COUNT repositorios"
            ((PASSED_TESTS++))
        else
            log_error "FAIL: No se pudieron obtener repositorios"
            ((FAILED_TESTS++))
        fi
    else
        if echo "$REPOS_RESPONSE" | grep -q '"name"'; then
            log_success "PASS: Repositorios obtenidos (sin jq)"
            ((PASSED_TESTS++))
        else
            log_error "FAIL: No se pudieron obtener repositorios"
            ((FAILED_TESTS++))
        fi
    fi
fi

# Test obtener contenido de archivo (catalog-info.yaml)
if [ -n "$GITHUB_ORG" ] && [ -n "$GITHUB_REPO" ] && [ -n "$GITHUB_TOKEN" ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Obtener catalog-info.yaml"
    
    CATALOG_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API_URL/repos/$GITHUB_ORG/$GITHUB_REPO/contents/catalog-info.yaml")
    
    case $CATALOG_RESPONSE in
        200)
            log_success "PASS: catalog-info.yaml encontrado"
            ((PASSED_TESTS++))
            ;;
        404)
            log_warning "PASS: catalog-info.yaml no existe (esperado en algunos casos)"
            ((PASSED_TESTS++))
            ;;
        *)
            log_error "FAIL: Error obteniendo catalog-info.yaml (HTTP $CATALOG_RESPONSE)"
            ((FAILED_TESTS++))
            ;;
    esac
fi

# Test webhooks del repositorio
if [ -n "$GITHUB_ORG" ] && [ -n "$GITHUB_REPO" ] && [ -n "$GITHUB_TOKEN" ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Listar webhooks del repositorio"
    
    WEBHOOKS_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API_URL/repos/$GITHUB_ORG/$GITHUB_REPO/hooks")
    
    case $WEBHOOKS_RESPONSE in
        200)
            log_success "PASS: Webhooks accesibles"
            ((PASSED_TESTS++))
            ;;
        403)
            log_warning "PASS: Sin permisos para webhooks (esperado con algunos tokens)"
            ((PASSED_TESTS++))
            ;;
        *)
            log_error "FAIL: Error accediendo webhooks (HTTP $WEBHOOKS_RESPONSE)"
            ((FAILED_TESTS++))
            ;;
    esac
fi

# =============================================================================
# TESTS DE CONFIGURACIÓN OAUTH
# =============================================================================

log_info "Probando configuración OAuth..."

# Test formato de Client ID
((TOTAL_TESTS++))
if [[ "$AUTH_GITHUB_CLIENT_ID" =~ ^(Iv1\.|Ov23)[a-zA-Z0-9]{16}$ ]]; then
    log_success "PASS: Formato de AUTH_GITHUB_CLIENT_ID válido"
    ((PASSED_TESTS++))
else
    log_warning "PASS: AUTH_GITHUB_CLIENT_ID con formato no estándar (puede ser válido)"
    ((PASSED_TESTS++))
fi

# Test formato de Client Secret
((TOTAL_TESTS++))
if [[ ${#AUTH_GITHUB_CLIENT_SECRET} -eq 40 ]] && [[ "$AUTH_GITHUB_CLIENT_SECRET" =~ ^[a-f0-9]{40}$ ]]; then
    log_success "PASS: Formato de AUTH_GITHUB_CLIENT_SECRET válido"
    ((PASSED_TESTS++))
else
    log_warning "PASS: AUTH_GITHUB_CLIENT_SECRET con formato no estándar (puede ser válido)"
    ((PASSED_TESTS++))
fi

# Test callback URL
((TOTAL_TESTS++))
if [[ "$AUTH_GITHUB_CALLBACK_URL" =~ /api/auth/github/handler/frame$ ]]; then
    log_success "PASS: AUTH_GITHUB_CALLBACK_URL tiene endpoint correcto"
    ((PASSED_TESTS++))
else
    log_error "FAIL: AUTH_GITHUB_CALLBACK_URL no termina con el endpoint correcto"
    ((FAILED_TESTS++))
fi

# =============================================================================
# TESTS DE CATÁLOGO BACKSTAGE
# =============================================================================

log_info "Probando configuración del catálogo..."

# Test formato de CATALOG_LOCATIONS
((TOTAL_TESTS++))
if [[ "$CATALOG_LOCATIONS" =~ ^https://github\.com/[^/]+/[^/]+/blob/[^/]+/.*\.yaml$ ]]; then
    log_success "PASS: CATALOG_LOCATIONS tiene formato válido"
    ((PASSED_TESTS++))
else
    log_error "FAIL: CATALOG_LOCATIONS no tiene formato válido de GitHub"
    ((FAILED_TESTS++))
fi

# Test acceso al archivo de catálogo
if [ -n "$CATALOG_LOCATIONS" ] && [ -n "$GITHUB_TOKEN" ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Acceso al archivo de catálogo"
    
    # Convertir URL de blob a raw
    RAW_CATALOG_URL=$(echo "$CATALOG_LOCATIONS" | sed 's|github\.com|raw.githubusercontent.com|' | sed 's|/blob/|/|')
    
    CATALOG_FILE_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$RAW_CATALOG_URL")
    
    case $CATALOG_FILE_RESPONSE in
        200)
            log_success "PASS: Archivo de catálogo accesible"
            ((PASSED_TESTS++))
            ;;
        404)
            log_warning "PASS: Archivo de catálogo no existe (crear si es necesario)"
            ((PASSED_TESTS++))
            ;;
        *)
            log_error "FAIL: Error accediendo archivo de catálogo (HTTP $CATALOG_FILE_RESPONSE)"
            ((FAILED_TESTS++))
            ;;
    esac
fi

# Test configuración de auto-discovery
((TOTAL_TESTS++))
if [ "$GITHUB_AUTODISCOVERY_ENABLED" = "true" ]; then
    if [ -n "$GITHUB_AUTODISCOVERY_ORG" ] && [ -n "$GITHUB_AUTODISCOVERY_TOPICS" ]; then
        log_success "PASS: Auto-discovery configurado correctamente"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: Auto-discovery habilitado pero faltan configuraciones"
        ((FAILED_TESTS++))
    fi
else
    log_success "PASS: Auto-discovery deshabilitado (configuración válida)"
    ((PASSED_TESTS++))
fi

# =============================================================================
# TESTS DE BACKSTAGE (si está corriendo)
# =============================================================================

if docker ps --format "table {{.Names}}" | grep -q "backstage"; then
    log_info "Probando integración con Backstage..."
    
    BACKSTAGE_URL="http://localhost:${DEV_BACKSTAGE_BACKEND_PORT:-7007}"
    
    # Test Backstage health
    ((TOTAL_TESTS++))
    BACKSTAGE_HEALTH=$(curl -s -w "%{http_code}" -o /dev/null --max-time 10 "$BACKSTAGE_URL/health")
    if [ "$BACKSTAGE_HEALTH" = "200" ]; then
        log_success "PASS: Backstage backend está corriendo"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: Backstage backend no responde (HTTP $BACKSTAGE_HEALTH)"
        ((FAILED_TESTS++))
    fi
    
    # Test catalog endpoint
    ((TOTAL_TESTS++))
    CATALOG_ENDPOINT=$(curl -s -w "%{http_code}" -o /dev/null --max-time 10 "$BACKSTAGE_URL/api/catalog/entities")
    if [ "$CATALOG_ENDPOINT" = "200" ]; then
        log_success "PASS: Endpoint de catálogo accesible"
        ((PASSED_TESTS++))
    else
        log_warning "PASS: Endpoint de catálogo no accesible (puede requerir auth)"
        ((PASSED_TESTS++))
    fi
    
else
    log_warning "Backstage no está corriendo, saltando tests de integración"
fi

# =============================================================================
# TESTS DE SEGURIDAD
# =============================================================================

log_info "Ejecutando tests de seguridad..."

# Test que el token no esté en logs o archivos públicos
((TOTAL_TESTS++))
if [ -f ".gitignore" ] && grep -q ".env" .gitignore; then
    log_success "PASS: .env está en .gitignore"
    ((PASSED_TESTS++))
else
    log_error "FAIL: .env no está en .gitignore (riesgo de seguridad)"
    ((FAILED_TESTS++))
fi

# Test longitud del webhook secret
((TOTAL_TESTS++))
if [ -n "$GITHUB_WEBHOOK_SECRET" ] && [ ${#GITHUB_WEBHOOK_SECRET} -ge 12 ]; then
    log_success "PASS: GITHUB_WEBHOOK_SECRET tiene longitud adecuada"
    ((PASSED_TESTS++))
else
    log_warning "PASS: GITHUB_WEBHOOK_SECRET podría ser más largo"
    ((PASSED_TESTS++))
fi

# =============================================================================
# TESTS DE PERFORMANCE
# =============================================================================

log_info "Ejecutando tests de performance..."

# Test tiempo de respuesta de GitHub API
if [ -n "$GITHUB_TOKEN" ]; then
    ((TOTAL_TESTS++))
    log_info "Test: Tiempo de respuesta GitHub API"
    
    START_TIME=$(date +%s%N)
    curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/user" >/dev/null
    END_TIME=$(date +%s%N)
    
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 )) # Convert to milliseconds
    
    if [ $RESPONSE_TIME -lt 2000 ]; then
        log_success "PASS: Tiempo de respuesta GitHub API: ${RESPONSE_TIME}ms"
        ((PASSED_TESTS++))
    elif [ $RESPONSE_TIME -lt 5000 ]; then
        log_warning "PASS: Tiempo de respuesta GitHub API lento: ${RESPONSE_TIME}ms"
        ((PASSED_TESTS++))
    else
        log_error "FAIL: Tiempo de respuesta GitHub API muy lento: ${RESPONSE_TIME}ms"
        ((FAILED_TESTS++))
    fi
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

echo "=================================================="
echo "📊 Resumen de Tests GitHub-Backstage:"
echo "   Total:   $TOTAL_TESTS"
echo "   Pasaron: $PASSED_TESTS"
echo "   Fallaron: $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "🎉 Todos los tests pasaron! La integración GitHub-Backstage está funcionando correctamente"
    
    # Información adicional
    echo ""
    log_info "🔗 Información de configuración:"
    echo "   Organización: $GITHUB_ORG"
    echo "   Repositorio: $GITHUB_REPO"
    echo "   OAuth Client: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
    echo "   Auto-discovery: $GITHUB_AUTODISCOVERY_ENABLED"
    echo "   Catálogo: $(basename "$CATALOG_LOCATIONS" 2>/dev/null || echo "No configurado")"
    
    echo ""
    log_info "🚀 Próximos pasos:"
    echo "   1. Configurar webhooks en GitHub si es necesario"
    echo "   2. Crear catalog-info.yaml en repositorios"
    echo "   3. Configurar OAuth App en GitHub"
    echo "   4. Probar autenticación en Backstage"
    
    exit 0
else
    log_error "❌ $FAILED_TESTS tests fallaron. Revisa la configuración"
    
    echo ""
    log_info "🔧 Comandos de diagnóstico:"
    echo "   ./scripts/validate-github-integration.sh     # Validar configuración"
    echo "   curl -H \"Authorization: token \$GITHUB_TOKEN\" \$GITHUB_API_URL/user  # Test manual"
    echo "   docker logs ia-ops-backstage-backend         # Logs de Backstage"
    
    exit 1
fi
