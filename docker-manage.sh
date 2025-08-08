#!/bin/bash

# =============================================================================
# IA-OPS PLATFORM - DOCKER MANAGEMENT SCRIPT
# =============================================================================
# Fecha: 8 de Agosto de 2025
# Versión: 2.1.0
# Descripción: Script de gestión para servicios Docker de IA-Ops Platform
# Funciona desde cualquier directorio y detecta automáticamente la ubicación
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
PROJECT_NAME="ia-ops"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

# Detectar directorio del proyecto automáticamente
detect_project_dir() {
    local current_dir="$(pwd)"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Posibles ubicaciones del proyecto
    local possible_dirs=(
        "$script_dir"
        "/home/giovanemere/ia-ops/ia-ops"
        "/home/giovanemere/ia-ops/ia-ops-framework"
        "$current_dir"
        "$HOME/ia-ops/ia-ops"
        "$HOME/ia-ops-framework"
    )
    
    for dir in "${possible_dirs[@]}"; do
        if [[ -f "$dir/$COMPOSE_FILE" && -f "$dir/$ENV_FILE" ]]; then
            echo "$dir"
            return 0
        fi
    done
    
    return 1
}

# Establecer directorio de trabajo
PROJECT_DIR=$(detect_project_dir)
if [[ -z "$PROJECT_DIR" ]]; then
    error "No se pudo encontrar el directorio del proyecto IA-Ops"
    error "Asegúrate de que existan los archivos docker-compose.yml y .env"
    exit 1
fi

# Cambiar al directorio del proyecto
cd "$PROJECT_DIR"

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}🚀 IA-OPS PLATFORM - DOCKER MANAGEMENT SCRIPT${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo ""
    echo -e "${GREEN}Uso: $0 [COMANDO]${NC}"
    echo ""
    echo -e "${YELLOW}COMANDOS DISPONIBLES:${NC}"
    echo ""
    echo -e "${CYAN}📦 GESTIÓN DE SERVICIOS:${NC}"
    echo -e "  ${GREEN}dev${NC}           - Iniciar entorno de desarrollo completo"
    echo -e "  ${GREEN}prod${NC}          - Iniciar entorno de producción"
    echo -e "  ${GREEN}start${NC}         - Iniciar todos los servicios"
    echo -e "  ${GREEN}stop${NC}          - Detener todos los servicios"
    echo -e "  ${GREEN}restart${NC}       - Reiniciar todos los servicios"
    echo -e "  ${GREEN}down${NC}          - Detener y eliminar contenedores"
    echo -e "  ${GREEN}clean${NC}         - Limpieza completa (contenedores, volúmenes, imágenes)"
    echo ""
    echo -e "${CYAN}🔍 MONITOREO Y DEBUG:${NC}"
    echo -e "  ${GREEN}status${NC}        - Ver estado de todos los servicios"
    echo -e "  ${GREEN}logs${NC}          - Ver logs de todos los servicios"
    echo -e "  ${GREEN}logs [servicio]${NC} - Ver logs de un servicio específico"
    echo -e "  ${GREEN}health${NC}        - Verificar salud de los servicios"
    echo -e "  ${GREEN}ps${NC}            - Listar contenedores activos"
    echo ""
    echo -e "${CYAN}🛠️ UTILIDADES:${NC}"
    echo -e "  ${GREEN}build${NC}         - Construir todas las imágenes"
    echo -e "  ${GREEN}pull${NC}          - Actualizar imágenes base"
    echo -e "  ${GREEN}shell [servicio]${NC} - Acceder al shell de un servicio"
    echo -e "  ${GREEN}db-shell${NC}      - Acceder al shell de PostgreSQL"
    echo -e "  ${GREEN}redis-shell${NC}   - Acceder al shell de Redis"
    echo ""
    echo -e "${CYAN}🧪 TESTING:${NC}"
    echo -e "  ${GREEN}test${NC}          - Ejecutar tests de conectividad"
    echo -e "  ${GREEN}test-api${NC}      - Probar APIs principales"
    echo -e "  ${GREEN}test-backstage${NC} - Probar Backstage específicamente"
    echo ""
    echo -e "${CYAN}📊 INFORMACIÓN:${NC}"
    echo -e "  ${GREEN}info${NC}          - Mostrar información del proyecto"
    echo -e "  ${GREEN}urls${NC}          - Mostrar URLs de acceso"
    echo -e "  ${GREEN}env${NC}           - Verificar variables de entorno"
    echo ""
    echo -e "${YELLOW}EJEMPLOS:${NC}"
    echo -e "  $0 dev              # Iniciar entorno de desarrollo"
    echo -e "  $0 logs backstage   # Ver logs de Backstage"
    echo -e "  $0 shell openai     # Acceder al contenedor de OpenAI"
    echo -e "  $0 clean            # Limpieza completa"
    echo ""
}

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar prerrequisitos
check_prerequisites() {
    if ! command -v docker &> /dev/null; then
        error "Docker no está instalado"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose no está instalado"
        exit 1
    fi

    if [ ! -f "$PROJECT_DIR/$COMPOSE_FILE" ]; then
        error "Archivo $COMPOSE_FILE no encontrado en $PROJECT_DIR"
        exit 1
    fi

    if [ ! -f "$PROJECT_DIR/$ENV_FILE" ]; then
        warning "Archivo $ENV_FILE no encontrado en $PROJECT_DIR, usando valores por defecto"
    fi
    
    info "Proyecto detectado en: $PROJECT_DIR"
}

# Mostrar información del proyecto
show_info() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}📊 INFORMACIÓN DEL PROYECTO IA-OPS${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${CYAN}Proyecto:${NC} IA-Ops Platform"
    echo -e "${CYAN}Versión:${NC} 2.1.0"
    echo -e "${CYAN}Directorio Detectado:${NC} $PROJECT_DIR"
    echo -e "${CYAN}Directorio Actual:${NC} $(pwd)"
    echo -e "${CYAN}Compose File:${NC} $COMPOSE_FILE"
    echo -e "${CYAN}Env File:${NC} $ENV_FILE"
    echo ""
    echo -e "${YELLOW}Servicios configurados:${NC}"
    docker-compose config --services | sed 's/^/  - /'
    echo ""
}

# Mostrar URLs de acceso
show_urls() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}🌐 URLS DE ACCESO${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${GREEN}🏛️  Backstage Portal:${NC}     http://localhost:3000"
    echo -e "${GREEN}🤖 OpenAI Service:${NC}       http://localhost:8001"
    echo -e "${GREEN}🔄 Proxy Gateway:${NC}        http://localhost:8080"
    echo -e "${GREEN}📊 Prometheus:${NC}           http://localhost:9090"
    echo -e "${GREEN}📈 Grafana:${NC}              http://localhost:3001"
    echo -e "${GREEN}📚 MkDocs:${NC}               http://localhost:8000"
    echo -e "${GREEN}💾 PostgreSQL:${NC}           localhost:5433"
    echo -e "${GREEN}🔴 Redis:${NC}                localhost:6380"
    echo ""
}

# Verificar salud de servicios
check_health() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}🏥 VERIFICACIÓN DE SALUD DE SERVICIOS${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    
    services=$(docker-compose ps --services)
    
    for service in $services; do
        if docker-compose ps $service | grep -q "Up"; then
            echo -e "${GREEN}✅ $service: RUNNING${NC}"
        else
            echo -e "${RED}❌ $service: STOPPED${NC}"
        fi
    done
    echo ""
}

# Probar APIs
test_apis() {
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}🧪 TESTING DE APIS${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    
    # Test Backstage
    echo -e "${CYAN}Testing Backstage...${NC}"
    if curl -s -f http://localhost:3000/api/catalog/entities > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backstage API: OK${NC}"
    else
        echo -e "${RED}❌ Backstage API: FAIL${NC}"
    fi
    
    # Test OpenAI Service
    echo -e "${CYAN}Testing OpenAI Service...${NC}"
    if curl -s -f http://localhost:8001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OpenAI Service: OK${NC}"
    else
        echo -e "${RED}❌ OpenAI Service: FAIL${NC}"
    fi
    
    # Test Proxy
    echo -e "${CYAN}Testing Proxy Gateway...${NC}"
    if curl -s -f http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Proxy Gateway: OK${NC}"
    else
        echo -e "${RED}❌ Proxy Gateway: FAIL${NC}"
    fi
    
    echo ""
}

# Función principal
main() {
    check_prerequisites
    
    case "${1:-help}" in
        "dev"|"development")
            log "🚀 Iniciando entorno de desarrollo..."
            docker-compose up -d
            sleep 5
            show_urls
            check_health
            ;;
        "prod"|"production")
            log "🚀 Iniciando entorno de producción..."
            docker-compose -f docker-compose.yml up -d
            sleep 5
            show_urls
            check_health
            ;;
        "start"|"up")
            log "▶️ Iniciando servicios..."
            docker-compose up -d
            ;;
        "stop")
            log "⏹️ Deteniendo servicios..."
            docker-compose stop
            ;;
        "restart")
            log "🔄 Reiniciando servicios..."
            docker-compose restart
            ;;
        "down")
            log "⬇️ Deteniendo y eliminando contenedores..."
            docker-compose down
            ;;
        "clean")
            log "🧹 Limpieza completa..."
            docker-compose down -v --remove-orphans
            docker system prune -f
            ;;
        "status"|"ps")
            docker-compose ps
            ;;
        "logs")
            if [ -n "$2" ]; then
                docker-compose logs -f "$2"
            else
                docker-compose logs -f
            fi
            ;;
        "health")
            check_health
            ;;
        "build")
            log "🔨 Construyendo imágenes..."
            docker-compose build
            ;;
        "pull")
            log "⬇️ Actualizando imágenes base..."
            docker-compose pull
            ;;
        "shell")
            if [ -n "$2" ]; then
                docker-compose exec "$2" /bin/bash
            else
                error "Especifica el servicio: $0 shell [servicio]"
            fi
            ;;
        "db-shell")
            docker-compose exec postgres psql -U postgres -d backstage
            ;;
        "redis-shell")
            docker-compose exec redis redis-cli
            ;;
        "test")
            test_apis
            ;;
        "test-api")
            test_apis
            ;;
        "test-backstage")
            echo -e "${CYAN}Testing Backstage específicamente...${NC}"
            curl -v http://localhost:3000/api/catalog/entities
            ;;
        "info")
            show_info
            ;;
        "urls")
            show_urls
            ;;
        "env")
            if [ -f "$PROJECT_DIR/$ENV_FILE" ]; then
                echo -e "${BLUE}Variables de entorno configuradas:${NC}"
                grep -v '^#' "$PROJECT_DIR/$ENV_FILE" | grep -v '^$' | sed 's/=.*/=***/' | sed 's/^/  /'
            else
                warning "Archivo $ENV_FILE no encontrado en $PROJECT_DIR"
            fi
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Comando desconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
