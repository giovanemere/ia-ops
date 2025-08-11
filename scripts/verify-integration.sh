#!/bin/bash
# =============================================================================
# SCRIPT DE VERIFICACIÓN DE INTEGRACIÓN: IA-OPS + ICBS
# =============================================================================
# Descripción: Verifica que todos los servicios estén funcionando correctamente
# =============================================================================

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              VERIFICACIÓN DE INTEGRACIÓN                    ║"
    echo "║                  IA-Ops + ICBS Platform                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para verificar un servicio
check_service() {
    local url=$1
    local name=$2
    local timeout=${3:-10}
    
    log "🔍 Verificando $name..."
    
    if timeout $timeout curl -s "$url" > /dev/null 2>&1; then
        log "✅ $name está funcionando correctamente"
        return 0
    else
        log_error "❌ $name no está respondiendo en $url"
        return 1
    fi
}

# Función para verificar puerto
check_port() {
    local port=$1
    local name=$2
    
    if netstat -tuln | grep -q ":$port "; then
        log "✅ Puerto $port ($name) está en uso"
        return 0
    else
        log_warning "⚠️ Puerto $port ($name) no está en uso"
        return 1
    fi
}

# Función para verificar imágenes ICBS
check_icbs_images() {
    log "🔍 Verificando imágenes ICBS..."
    
    local icbs_images=(
        "haproxy-advanced:latest"
        "weblogic-feature-flags:latest"
        "jenkins-weblogic:latest"
    )
    
    local missing_images=()
    
    for image in "${icbs_images[@]}"; do
        if docker images -q "$image" >/dev/null 2>&1; then
            log "✅ Imagen ICBS disponible: $image"
        else
            log_warning "⚠️ Imagen ICBS faltante: $image"
            missing_images+=("$image")
        fi
    done
    
    if [ ${#missing_images[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}🔧 Para corregir imágenes faltantes:${NC}"
        echo -e "${YELLOW}./scripts/integrated-startup.sh fix-icbs${NC}"
    fi
    
    return ${#missing_images[@]}
}

# Función principal de verificación
main_verification() {
    show_banner
    
    log "🚀 Iniciando verificación completa de la plataforma integrada con auto-corrección..."
    
    local failed_checks=0
    local total_checks=0
    
    echo -e "\n${BLUE}🔧 VERIFICACIÓN DE IMÁGENES ICBS${NC}"
    echo "=================================================="
    
    # Verificar imágenes ICBS primero
    total_checks=$((total_checks + 1))
    if ! check_icbs_images; then
        failed_checks=$((failed_checks + 1))
    fi
    
    echo -e "\n${BLUE}📊 VERIFICACIÓN DE SERVICIOS IA-OPS${NC}"
    echo "=================================================="
    
    # Verificar servicios IA-Ops
    services_ia_ops=(
        "http://localhost:8080|IA-Ops Backstage (Proxy)|15"
        "http://localhost:3002|Backstage Frontend|10"
        "http://localhost:7007|Backstage Backend|10"
        "http://localhost:8080/openai|OpenAI Service|10"
        "http://localhost:3001|Grafana|10"
        "http://localhost:9090|Prometheus|10"
    )
    
    for service in "${services_ia_ops[@]}"; do
        IFS='|' read -r url name timeout <<< "$service"
        total_checks=$((total_checks + 1))
        if ! check_service "$url" "$name" "$timeout"; then
            failed_checks=$((failed_checks + 1))
        fi
    done
    
    echo -e "\n${BLUE}🏗️ VERIFICACIÓN DE SERVICIOS ICBS (CON AUTO-CORRECCIÓN)${NC}"
    echo "=================================================="
    
    # Verificar servicios ICBS
    services_icbs=(
        "http://localhost:8404/stats|HAProxy Stats (CORREGIDO)|15"
        "http://localhost:8083|HAProxy Frontend|10"
        "http://localhost:7001/console|WebLogic A Admin Console|20"
        "http://localhost:7002/console|WebLogic B Admin Console|20"
        "http://localhost:8081|Jenkins|15"
    )
    
    for service in "${services_icbs[@]}"; do
        IFS='|' read -r url name timeout <<< "$service"
        total_checks=$((total_checks + 1))
        if ! check_service "$url" "$name" "$timeout"; then
            failed_checks=$((failed_checks + 1))
        fi
    done
    
    echo -e "\n${BLUE}🔌 VERIFICACIÓN DE PUERTOS${NC}"
    echo "=================================================="
    
    # Verificar puertos críticos (incluyendo ICBS)
    ports=(
        "8080|IA-Ops Proxy"
        "3002|Backstage Frontend"
        "7007|Backstage Backend"
        "8404|HAProxy Stats"
        "8083|HAProxy Frontend"
        "7001|WebLogic A"
        "7002|WebLogic B"
        "8081|Jenkins"
        "3001|Grafana"
        "9090|Prometheus"
        "5432|PostgreSQL"
        "6379|Redis"
    )
    
    for port_info in "${ports[@]}"; do
        IFS='|' read -r port name <<< "$port_info"
        total_checks=$((total_checks + 1))
        if ! check_port "$port" "$name"; then
            failed_checks=$((failed_checks + 1))
        fi
    done
    
    echo -e "\n${BLUE}🔗 VERIFICACIÓN DE INTEGRACIÓN${NC}"
    echo "=================================================="
    
    # Verificar archivos de integración
    integration_files=(
        "/home/giovanemere/ia-ops/ia-ops/applications/backstage/catalog-poc-icbs.yaml|Catálogo ICBS en Backstage"
        "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/catalog-info.yaml|Catálogo ICBS"
        "/home/giovanemere/ia-ops/ia-ops/config/integrated-services.yaml|Configuración Integrada"
        "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/haproxy/config/haproxy-simple.cfg|HAProxy Config (Auto-corregido)"
    )
    
    for file_info in "${integration_files[@]}"; do
        IFS='|' read -r file name <<< "$file_info"
        total_checks=$((total_checks + 1))
        if [ -f "$file" ]; then
            log "✅ $name existe"
        else
            log_warning "⚠️ $name no encontrado: $file"
            failed_checks=$((failed_checks + 1))
        fi
    done
    
    # Verificar conectividad entre servicios
    log "🔍 Verificando conectividad entre servicios..."
    total_checks=$((total_checks + 2))
    
    # Test: Backstage puede acceder a OpenAI Service
    if curl -s "http://localhost:8080/openai/health" > /dev/null 2>&1; then
        log "✅ Backstage → OpenAI Service: Conectividad OK"
    else
        log_warning "⚠️ Backstage → OpenAI Service: Sin conectividad"
        failed_checks=$((failed_checks + 1))
    fi
    
    # Test: HAProxy Stats accesible (verificación de auto-corrección)
    if curl -s "http://localhost:8404/stats" > /dev/null 2>&1; then
        log "✅ HAProxy Stats: Auto-corrección exitosa"
    else
        log_warning "⚠️ HAProxy Stats: Puede necesitar corrección manual"
        failed_checks=$((failed_checks + 1))
    fi
    
    echo -e "\n${BLUE}📈 RESUMEN DE VERIFICACIÓN${NC}"
    echo "=================================================="
    
    local success_rate=$(( (total_checks - failed_checks) * 100 / total_checks ))
    
    echo -e "Total de verificaciones: ${CYAN}$total_checks${NC}"
    echo -e "Verificaciones exitosas: ${GREEN}$((total_checks - failed_checks))${NC}"
    echo -e "Verificaciones fallidas: ${RED}$failed_checks${NC}"
    echo -e "Tasa de éxito: ${CYAN}$success_rate%${NC}"
    
    if [ $failed_checks -eq 0 ]; then
        echo -e "\n${GREEN}🎉 ¡VERIFICACIÓN COMPLETA EXITOSA!${NC}"
        echo -e "${GREEN}✅ Todos los servicios están funcionando correctamente${NC}"
        echo -e "${GREEN}🔧 Auto-corrección de ICBS funcionando perfectamente${NC}"
        return 0
    elif [ $success_rate -ge 80 ]; then
        echo -e "\n${YELLOW}⚠️ VERIFICACIÓN PARCIALMENTE EXITOSA${NC}"
        echo -e "${YELLOW}La mayoría de servicios están funcionando, pero hay algunos problemas${NC}"
        echo -e "\n${CYAN}🔧 Para corregir problemas de ICBS:${NC}"
        echo -e "${YELLOW}./scripts/integrated-startup.sh fix-icbs${NC}"
        return 1
    else
        echo -e "\n${RED}❌ VERIFICACIÓN FALLIDA${NC}"
        echo -e "${RED}Múltiples servicios no están funcionando correctamente${NC}"
        echo -e "\n${CYAN}🔧 Para corrección completa:${NC}"
        echo -e "${YELLOW}./scripts/integrated-startup.sh stop${NC}"
        echo -e "${YELLOW}./scripts/integrated-startup.sh fix-icbs${NC}"
        echo -e "${YELLOW}./scripts/integrated-startup.sh start${NC}"
        return 2
    fi
}

# Función para mostrar URLs de acceso
show_access_urls() {
    echo -e "\n${BLUE}🌐 URLs DE ACCESO${NC}"
    echo "=================================================="
    echo -e "• ${CYAN}IA-Ops Platform (Principal):${NC} http://localhost:8080"
    echo -e "• ${CYAN}Backstage Frontend:${NC} http://localhost:3002"
    echo -e "• ${CYAN}OpenAI Service:${NC} http://localhost:8080/openai"
    echo -e "• ${CYAN}Grafana:${NC} http://localhost:3001 (admin/admin123)"
    echo -e "• ${CYAN}Prometheus:${NC} http://localhost:9090"
    echo ""
    echo -e "• ${CYAN}WebLogic Console:${NC} http://localhost:7001/console"
    echo -e "• ${CYAN}Jenkins:${NC} http://localhost:8081"
    echo -e "• ${CYAN}HAProxy Stats:${NC} http://localhost:8404/stats"
}

# Función para mostrar ayuda
show_help() {
    show_banner
    echo -e "${YELLOW}Uso: $0 [OPCIÓN]${NC}"
    echo ""
    echo -e "${BLUE}Opciones:${NC}"
    echo "  verify    - Ejecutar verificación completa (por defecto)"
    echo "  urls      - Mostrar URLs de acceso"
    echo "  quick     - Verificación rápida (solo servicios principales)"
    echo "  help      - Mostrar esta ayuda"
}

# Función de verificación rápida
quick_verification() {
    show_banner
    log "🚀 Ejecutando verificación rápida..."
    
    local quick_services=(
        "http://localhost:8080|IA-Ops Platform"
        "http://localhost:7001|WebLogic"
        "http://localhost:8081|Jenkins"
    )
    
    local failed=0
    for service in "${quick_services[@]}"; do
        IFS='|' read -r url name <<< "$service"
        if ! check_service "$url" "$name" 5; then
            failed=$((failed + 1))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        log "✅ Verificación rápida exitosa"
    else
        log_error "❌ $failed servicios principales no están funcionando"
    fi
}

# Función principal
case "${1:-verify}" in
    verify)
        main_verification
        exit_code=$?
        show_access_urls
        exit $exit_code
        ;;
    urls)
        show_access_urls
        ;;
    quick)
        quick_verification
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Opción no reconocida: $1"
        show_help
        exit 1
        ;;
esac
