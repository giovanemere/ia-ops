#!/bin/bash

# =============================================================================
# DIAGNÓSTICO COMPLETO DE FALLAS EN IA-OPS PLATFORM
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
BACKSTAGE_DIR="/home/giovanemere/ia-ops/ia-ops/applications/backstage"
WEBLOGIC_DIR="/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic"
ISSUES_FOUND=0
CRITICAL_ISSUES=0

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    DIAGNÓSTICO COMPLETO IA-OPS PLATFORM                     ║"
echo "║                          Identificación de Fallas                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# FUNCIONES DE DIAGNÓSTICO
# =============================================================================

log_issue() {
    local level="$1"
    local message="$2"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    
    case "$level" in
        "CRITICAL")
            echo -e "${RED}❌ CRÍTICO: $message${NC}"
            CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  ADVERTENCIA: $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ OK: $message${NC}"
            ;;
    esac
}

# =============================================================================
# 1. VERIFICAR ARCHIVOS DE CONFIGURACIÓN
# =============================================================================

check_config_files() {
    echo -e "${BLUE}=== 1. VERIFICANDO ARCHIVOS DE CONFIGURACIÓN ===${NC}"
    
    # Verificar archivo .env principal
    if [ ! -f "$MAIN_ENV_FILE" ]; then
        log_issue "CRITICAL" "Archivo .env principal no encontrado: $MAIN_ENV_FILE"
        return 1
    else
        log_issue "SUCCESS" "Archivo .env principal encontrado"
    fi
    
    # Verificar variables críticas en .env
    source "$MAIN_ENV_FILE"
    
    # Variables críticas para GitHub
    [ -z "$GITHUB_TOKEN" ] && log_issue "CRITICAL" "GITHUB_TOKEN no definido en .env"
    [ -z "$AUTH_GITHUB_CLIENT_ID" ] && log_issue "CRITICAL" "AUTH_GITHUB_CLIENT_ID no definido en .env"
    [ -z "$AUTH_GITHUB_CLIENT_SECRET" ] && log_issue "CRITICAL" "AUTH_GITHUB_CLIENT_SECRET no definido en .env"
    [ -z "$AUTH_GITHUB_CALLBACK_URL" ] && log_issue "WARNING" "AUTH_GITHUB_CALLBACK_URL no definido en .env"
    
    # Variables críticas para base de datos
    [ -z "$POSTGRES_USER" ] && log_issue "CRITICAL" "POSTGRES_USER no definido en .env"
    [ -z "$POSTGRES_PASSWORD" ] && log_issue "CRITICAL" "POSTGRES_PASSWORD no definido en .env"
    [ -z "$POSTGRES_DB" ] && log_issue "CRITICAL" "POSTGRES_DB no definido en .env"
    
    # Variables críticas para OpenAI
    [ -z "$OPENAI_API_KEY" ] && log_issue "WARNING" "OPENAI_API_KEY no definido en .env"
    
    # Verificar app-config.yaml de Backstage
    if [ ! -f "$BACKSTAGE_DIR/app-config.yaml" ]; then
        log_issue "CRITICAL" "app-config.yaml de Backstage no encontrado"
    else
        log_issue "SUCCESS" "app-config.yaml de Backstage encontrado"
    fi
    
    # Verificar package.json de Backstage
    if [ ! -f "$BACKSTAGE_DIR/package.json" ]; then
        log_issue "CRITICAL" "package.json de Backstage no encontrado"
    else
        log_issue "SUCCESS" "package.json de Backstage encontrado"
    fi
}

# =============================================================================
# 2. VERIFICAR SCRIPTS REQUERIDOS
# =============================================================================

check_required_scripts() {
    echo -e "${BLUE}=== 2. VERIFICANDO SCRIPTS REQUERIDOS ===${NC}"
    
    # Scripts de Backstage
    local backstage_scripts=(
        "kill-ports.sh"
        "generate-catalog-files.sh"
        "sync-env-config.sh"
        "start-robust.sh"
    )
    
    for script in "${backstage_scripts[@]}"; do
        if [ ! -f "$BACKSTAGE_DIR/$script" ]; then
            log_issue "CRITICAL" "Script de Backstage no encontrado: $script"
        elif [ ! -x "$BACKSTAGE_DIR/$script" ]; then
            log_issue "WARNING" "Script de Backstage no es ejecutable: $script"
        else
            log_issue "SUCCESS" "Script de Backstage OK: $script"
        fi
    done
    
    # Scripts de WebLogic
    if [ -d "$WEBLOGIC_DIR" ]; then
        if [ ! -f "$WEBLOGIC_DIR/manage-services.sh" ]; then
            log_issue "WARNING" "Script manage-services.sh de WebLogic no encontrado"
        elif [ ! -x "$WEBLOGIC_DIR/manage-services.sh" ]; then
            log_issue "WARNING" "Script manage-services.sh de WebLogic no es ejecutable"
        else
            log_issue "SUCCESS" "Script manage-services.sh de WebLogic OK"
        fi
    else
        log_issue "WARNING" "Directorio de WebLogic no encontrado: $WEBLOGIC_DIR"
    fi
}

# =============================================================================
# 3. VERIFICAR DEPENDENCIAS DEL SISTEMA
# =============================================================================

check_system_dependencies() {
    echo -e "${BLUE}=== 3. VERIFICANDO DEPENDENCIAS DEL SISTEMA ===${NC}"
    
    # Verificar Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_issue "CRITICAL" "Docker no está instalado"
    else
        if ! docker info >/dev/null 2>&1; then
            log_issue "CRITICAL" "Docker no está corriendo o no tienes permisos"
        else
            log_issue "SUCCESS" "Docker está funcionando"
        fi
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1; then
        log_issue "CRITICAL" "Docker Compose no está instalado"
    else
        log_issue "SUCCESS" "Docker Compose está disponible"
    fi
    
    # Verificar Node.js
    if ! command -v node >/dev/null 2>&1; then
        log_issue "CRITICAL" "Node.js no está instalado"
    else
        local node_version=$(node --version)
        log_issue "SUCCESS" "Node.js está disponible: $node_version"
    fi
    
    # Verificar Yarn
    if ! command -v yarn >/dev/null 2>&1; then
        log_issue "CRITICAL" "Yarn no está instalado"
    else
        local yarn_version=$(yarn --version)
        log_issue "SUCCESS" "Yarn está disponible: $yarn_version"
    fi
    
    # Verificar Python
    if ! command -v python3 >/dev/null 2>&1; then
        log_issue "WARNING" "Python3 no está instalado"
    else
        local python_version=$(python3 --version)
        log_issue "SUCCESS" "Python3 está disponible: $python_version"
    fi
    
    # Verificar Git
    if ! command -v git >/dev/null 2>&1; then
        log_issue "WARNING" "Git no está instalado"
    else
        log_issue "SUCCESS" "Git está disponible"
    fi
    
    # Verificar GitHub CLI
    if ! command -v gh >/dev/null 2>&1; then
        log_issue "WARNING" "GitHub CLI no está instalado"
    else
        log_issue "SUCCESS" "GitHub CLI está disponible"
    fi
}

# =============================================================================
# 4. VERIFICAR SERVICIOS DOCKER
# =============================================================================

check_docker_services() {
    echo -e "${BLUE}=== 4. VERIFICANDO SERVICIOS DOCKER ===${NC}"
    
    cd /home/giovanemere/ia-ops/ia-ops
    
    # Verificar servicios básicos
    local services=("postgres" "redis" "openai-service" "mkdocs")
    
    for service in "${services[@]}"; do
        if docker-compose ps "$service" 2>/dev/null | grep -q "Up"; then
            log_issue "SUCCESS" "Servicio Docker corriendo: $service"
        else
            log_issue "WARNING" "Servicio Docker no está corriendo: $service"
        fi
    done
    
    # Verificar conectividad a PostgreSQL
    if docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
        if docker-compose exec postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
            log_issue "SUCCESS" "PostgreSQL está respondiendo"
        else
            log_issue "CRITICAL" "PostgreSQL no está respondiendo"
        fi
    fi
    
    # Verificar conectividad a Redis
    if docker-compose ps redis 2>/dev/null | grep -q "Up"; then
        if docker-compose exec redis redis-cli ping >/dev/null 2>&1; then
            log_issue "SUCCESS" "Redis está respondiendo"
        else
            log_issue "WARNING" "Redis no está respondiendo"
        fi
    fi
}

# =============================================================================
# 5. VERIFICAR PUERTOS
# =============================================================================

check_ports() {
    echo -e "${BLUE}=== 5. VERIFICANDO PUERTOS ===${NC}"
    
    # Puertos críticos para IA-OPS
    local ports=(
        "3002:Backstage Frontend"
        "7007:Backstage Backend"
        "8080:Proxy Gateway"
        "5432:PostgreSQL"
        "6379:Redis"
        "8003:OpenAI Service"
        "8005:MkDocs"
    )
    
    for port_info in "${ports[@]}"; do
        local port=$(echo "$port_info" | cut -d: -f1)
        local service=$(echo "$port_info" | cut -d: -f2)
        
        if lsof -i ":$port" >/dev/null 2>&1; then
            local process=$(lsof -i ":$port" | tail -n1 | awk '{print $1}')
            log_issue "INFO" "Puerto $port ($service) está ocupado por: $process"
        else
            log_issue "WARNING" "Puerto $port ($service) está libre"
        fi
    done
}

# =============================================================================
# 6. VERIFICAR DEPENDENCIAS DE BACKSTAGE
# =============================================================================

check_backstage_dependencies() {
    echo -e "${BLUE}=== 6. VERIFICANDO DEPENDENCIAS DE BACKSTAGE ===${NC}"
    
    cd "$BACKSTAGE_DIR"
    
    # Verificar node_modules
    if [ ! -d "node_modules" ]; then
        log_issue "CRITICAL" "node_modules no existe en Backstage"
    else
        log_issue "SUCCESS" "node_modules existe en Backstage"
    fi
    
    # Verificar yarn.lock
    if [ ! -f "yarn.lock" ]; then
        log_issue "WARNING" "yarn.lock no existe en Backstage"
    else
        log_issue "SUCCESS" "yarn.lock existe en Backstage"
    fi
    
    # Verificar si hay conflictos en package.json
    if [ -f "package.json" ]; then
        if grep -q '"node":' package.json; then
            local node_requirement=$(grep '"node":' package.json | sed 's/.*"node": *"\([^"]*\)".*/\1/')
            log_issue "INFO" "Backstage requiere Node.js: $node_requirement"
        fi
    fi
    
    # Verificar archivos de configuración de TypeScript
    if [ ! -f "tsconfig.json" ]; then
        log_issue "WARNING" "tsconfig.json no encontrado en Backstage"
    else
        log_issue "SUCCESS" "tsconfig.json encontrado en Backstage"
    fi
}

# =============================================================================
# 7. VERIFICAR CONECTIVIDAD GITHUB
# =============================================================================

check_github_connectivity() {
    echo -e "${BLUE}=== 7. VERIFICANDO CONECTIVIDAD GITHUB ===${NC}"
    
    # Verificar token de GitHub
    if [ -n "$GITHUB_TOKEN" ]; then
        if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user >/dev/null 2>&1; then
            log_issue "SUCCESS" "Token de GitHub es válido"
        else
            log_issue "CRITICAL" "Token de GitHub es inválido o ha expirado"
        fi
    fi
    
    # Verificar acceso a repositorios específicos
    local repos=(
        "giovanemere/poc-billpay-back"
        "giovanemere/poc-billpay-front-a"
        "giovanemere/poc-billpay-front-b"
        "giovanemere/poc-icbs"
    )
    
    for repo in "${repos[@]}"; do
        if curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$repo" >/dev/null 2>&1; then
            log_issue "SUCCESS" "Acceso OK al repositorio: $repo"
        else
            log_issue "WARNING" "No se puede acceder al repositorio: $repo"
        fi
    done
}

# =============================================================================
# 8. VERIFICAR ARCHIVOS DE CATÁLOGO
# =============================================================================

check_catalog_files() {
    echo -e "${BLUE}=== 8. VERIFICANDO ARCHIVOS DE CATÁLOGO ===${NC}"
    
    cd "$BACKSTAGE_DIR"
    
    # Verificar archivos de catálogo generados
    local catalog_files=(
        "catalog-poc-billpay-back.yaml"
        "catalog-poc-billpay-front-a.yaml"
        "catalog-poc-billpay-front-b.yaml"
        "catalog-poc-icbs.yaml"
    )
    
    for file in "${catalog_files[@]}"; do
        if [ -f "$file" ]; then
            log_issue "SUCCESS" "Archivo de catálogo encontrado: $file"
        else
            log_issue "WARNING" "Archivo de catálogo no encontrado: $file"
        fi
    done
    
    # Verificar template de catálogo
    if [ ! -f "catalog-template.yaml" ]; then
        log_issue "WARNING" "catalog-template.yaml no encontrado"
    else
        log_issue "SUCCESS" "catalog-template.yaml encontrado"
    fi
}

# =============================================================================
# 9. VERIFICAR LOGS DE ERRORES
# =============================================================================

check_error_logs() {
    echo -e "${BLUE}=== 9. VERIFICANDO LOGS DE ERRORES ===${NC}"
    
    # Verificar logs de Backstage
    local log_files=(
        "$BACKSTAGE_DIR/backstage.log"
        "$BACKSTAGE_DIR/backstage-backend.log"
        "$BACKSTAGE_DIR/frontend.log"
    )
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            local error_count=$(grep -i "error\|failed\|exception" "$log_file" 2>/dev/null | wc -l)
            if [ "$error_count" -gt 0 ]; then
                log_issue "WARNING" "Errores encontrados en $log_file: $error_count"
            else
                log_issue "SUCCESS" "No hay errores críticos en $log_file"
            fi
        fi
    done
}

# =============================================================================
# 10. GENERAR REPORTE Y RECOMENDACIONES
# =============================================================================

generate_report() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              REPORTE FINAL                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}=== RESUMEN ===${NC}"
    echo -e "Total de problemas encontrados: ${YELLOW}$ISSUES_FOUND${NC}"
    echo -e "Problemas críticos: ${RED}$CRITICAL_ISSUES${NC}"
    
    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        echo -e "${RED}"
        echo "╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                           ACCIÓN REQUERIDA                                  ║"
        echo "║                                                                              ║"
        echo "║  Se encontraron problemas críticos que impiden el funcionamiento normal.    ║"
        echo "║  Por favor, revisa los errores marcados como CRÍTICO arriba.                ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
    
    echo -e "${BLUE}=== RECOMENDACIONES ===${NC}"
    
    # Recomendaciones específicas basadas en los problemas encontrados
    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}1. Solucionar problemas críticos:${NC}"
        echo "   - Verificar y actualizar el token de GitHub"
        echo "   - Asegurar que todas las variables de entorno estén definidas"
        echo "   - Verificar que Docker y Docker Compose estén funcionando"
        echo ""
    fi
    
    echo -e "${YELLOW}2. Comandos recomendados para solucionar problemas:${NC}"
    echo ""
    echo "   # Actualizar token de GitHub:"
    echo "   gh auth login"
    echo ""
    echo "   # Reinstalar dependencias de Backstage:"
    echo "   cd $BACKSTAGE_DIR && yarn install"
    echo ""
    echo "   # Reiniciar servicios Docker:"
    echo "   cd /home/giovanemere/ia-ops/ia-ops && docker-compose down && docker-compose up -d"
    echo ""
    echo "   # Ejecutar secuencia completa de inicio:"
    echo "   cd $BACKSTAGE_DIR"
    echo "   ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh"
    echo ""
    
    if [ "$CRITICAL_ISSUES" -eq 0 ]; then
        echo -e "${GREEN}"
        echo "╔══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                              ¡TODO LISTO!                                   ║"
        echo "║                                                                              ║"
        echo "║  No se encontraron problemas críticos. El sistema debería funcionar         ║"
        echo "║  correctamente. Revisa las advertencias para optimizar el rendimiento.      ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
}

# =============================================================================
# FUNCIÓN PRINCIPAL
# =============================================================================

main() {
    echo -e "${YELLOW}Iniciando diagnóstico completo...${NC}"
    echo ""
    
    check_config_files
    echo ""
    
    check_required_scripts
    echo ""
    
    check_system_dependencies
    echo ""
    
    check_docker_services
    echo ""
    
    check_ports
    echo ""
    
    check_backstage_dependencies
    echo ""
    
    check_github_connectivity
    echo ""
    
    check_catalog_files
    echo ""
    
    check_error_logs
    echo ""
    
    generate_report
}

# Ejecutar diagnóstico
main "$@"
