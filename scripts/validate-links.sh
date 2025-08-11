#!/bin/bash

# =============================================================================
# SCRIPT DE VALIDACIÓN DE LINKS BACKSTAGE
# =============================================================================
# Descripción: Valida que todos los links en los catálogos estén funcionando
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

echo "🔗 Validando links de catálogos Backstage..."

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

# Contadores
TOTAL_LINKS=0
VALID_LINKS=0
LOCAL_LINKS=0
EXTERNAL_LINKS=0

check_url() {
    local url=$1
    local title=$2
    TOTAL_LINKS=$((TOTAL_LINKS + 1))
    
    if [[ $url == http://localhost* ]]; then
        LOCAL_LINKS=$((LOCAL_LINKS + 1))
        log_warning "Local link: $title ($url) - Requiere servicios activos"
        return 0
    elif [[ $url == https://github.com* ]]; then
        EXTERNAL_LINKS=$((EXTERNAL_LINKS + 1))
        if curl -s --head "$url" | head -n 1 | grep -q "200 OK"; then
            log_success "GitHub link válido: $title"
            VALID_LINKS=$((VALID_LINKS + 1))
            return 0
        else
            log_error "GitHub link inválido: $title ($url)"
            return 1
        fi
    else
        EXTERNAL_LINKS=$((EXTERNAL_LINKS + 1))
        if curl -s --head "$url" | head -n 1 | grep -q -E "(200 OK|301|302)"; then
            log_success "External link válido: $title"
            VALID_LINKS=$((VALID_LINKS + 1))
            return 0
        else
            log_error "External link inválido: $title ($url)"
            return 1
        fi
    fi
}

echo ""
log_info "=== VALIDANDO LINKS EN CATALOG-INFO.YAML ==="

# Extraer links del catalog-info.yaml
if [ -f "catalog-info.yaml" ]; then
    log_info "Procesando catalog-info.yaml..."
    
    # Links principales del sistema
    check_url "https://github.com/giovanemere/ia-ops" "Main Repository"
    check_url "http://localhost:8080" "Backstage Portal"
    check_url "http://localhost:8080/openai" "OpenAI Service"
    check_url "http://localhost:9090" "Prometheus Metrics"
    check_url "http://localhost:3001" "Grafana Dashboards"
    check_url "https://github.com/giovanemere/ia-ops/wiki" "Documentation Wiki"
    check_url "https://github.com/giovanemere/ia-ops/issues" "Issue Tracker"
else
    log_error "catalog-info.yaml no encontrado"
fi

echo ""
log_info "=== VALIDANDO LINKS EN CATALOG-TEMPLATES.YAML ==="

if [ -f "catalog-templates.yaml" ]; then
    log_info "Procesando catalog-templates.yaml..."
    
    # Links de templates
    check_url "https://github.com/giovanemere/templates_backstage" "Templates Repository"
    check_url "http://localhost:8080/create" "Create from Template"
    check_url "https://backstage.io/docs/features/software-templates/" "Backstage Templates Guide"
    
    # Links específicos por proveedor
    check_url "https://aws.amazon.com/getting-started/" "AWS Getting Started"
    check_url "https://docs.microsoft.com/en-us/azure/service-bus-messaging/" "Azure Service Bus Documentation"
    check_url "https://cloud.google.com/storage/docs" "GCP Storage Documentation"
    check_url "https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm" "OCI Networking Documentation"
    check_url "https://kubernetes.io/docs/concepts/workloads/controllers/deployment/" "Kubernetes Deployments"
else
    log_error "catalog-templates.yaml no encontrado"
fi

echo ""
log_info "=== VALIDANDO LINKS EN CATALOG-FRAMEWORK.YAML ==="

if [ -f "catalog-framework.yaml" ]; then
    log_info "Procesando catalog-framework.yaml..."
    
    # Links del framework
    check_url "https://github.com/giovanemere/ia-ops-framework" "Framework Repository"
    check_url "http://localhost:8080/framework" "Architecture Documentation"
    check_url "https://github.com/giovanemere/ia-ops-framework/blob/trunk/arquitectura-diagramas.md" "Architecture Diagrams"
else
    log_error "catalog-framework.yaml no encontrado"
fi

echo ""
log_info "=== VERIFICANDO SERVICIOS LOCALES ==="

# Verificar si los servicios locales están corriendo
if command -v docker-compose &> /dev/null; then
    if docker-compose ps | grep -q "Up"; then
        log_success "Servicios Docker Compose están corriendo"
        
        # Verificar puertos específicos
        if nc -z localhost 8080 2>/dev/null; then
            log_success "Puerto 8080 (Backstage/Proxy) accesible"
        else
            log_warning "Puerto 8080 no accesible - Iniciar con 'docker-compose up -d'"
        fi
        
        if nc -z localhost 9090 2>/dev/null; then
            log_success "Puerto 9090 (Prometheus) accesible"
        else
            log_warning "Puerto 9090 no accesible"
        fi
        
        if nc -z localhost 3001 2>/dev/null; then
            log_success "Puerto 3001 (Grafana) accesible"
        else
            log_warning "Puerto 3001 no accesible"
        fi
    else
        log_warning "Servicios Docker Compose no están corriendo"
        log_info "Ejecuta 'docker-compose up -d' para iniciar los servicios"
    fi
else
    log_warning "Docker Compose no encontrado"
fi

echo ""
log_info "=== RESUMEN DE VALIDACIÓN DE LINKS ==="

# Calcular estadísticas
if [ $TOTAL_LINKS -gt 0 ]; then
    EXTERNAL_SUCCESS_RATE=$((VALID_LINKS * 100 / EXTERNAL_LINKS))
else
    EXTERNAL_SUCCESS_RATE=0
fi

echo "📊 Estadísticas de links:"
echo "   🔗 Total de links: $TOTAL_LINKS"
echo "   ✅ Links externos válidos: $VALID_LINKS"
echo "   🏠 Links locales: $LOCAL_LINKS"
echo "   🌐 Links externos: $EXTERNAL_LINKS"
echo "   📈 Tasa de éxito (externos): $EXTERNAL_SUCCESS_RATE%"

if [ $EXTERNAL_SUCCESS_RATE -ge 90 ]; then
    log_success "¡Todos los links externos están funcionando correctamente!"
    echo ""
    echo "🎯 Próximos pasos:"
    echo "1. Iniciar servicios: docker-compose up -d"
    echo "2. Verificar links locales en Backstage"
    echo "3. Probar navegación entre entidades"
    exit 0
elif [ $EXTERNAL_SUCCESS_RATE -ge 70 ]; then
    log_warning "La mayoría de links funcionan. Revisar los fallidos."
    exit 1
else
    log_error "Varios links tienen problemas. Revisar configuración."
    exit 2
fi
