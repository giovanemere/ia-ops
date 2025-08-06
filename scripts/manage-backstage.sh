#!/bin/bash

# =============================================================================
# SCRIPT DE GESTIÓN - BACKSTAGE SERVICES
# =============================================================================
# Descripción: Gestiona los servicios de Backstage en IA-Ops Platform
# Uso: ./scripts/manage-backstage.sh [comando]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}🏛️ IA-Ops Backstage Management Script${NC}"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo -e "  ${GREEN}status${NC}      - Mostrar estado de todos los servicios"
    echo -e "  ${GREEN}start${NC}       - Iniciar todos los servicios de Backstage"
    echo -e "  ${GREEN}stop${NC}        - Detener todos los servicios de Backstage"
    echo -e "  ${GREEN}restart${NC}     - Reiniciar todos los servicios de Backstage"
    echo -e "  ${GREEN}logs${NC}        - Mostrar logs de Backstage"
    echo -e "  ${GREEN}build${NC}       - Construir imágenes de Backstage"
    echo -e "  ${GREEN}test${NC}        - Probar endpoints de Backstage"
    echo -e "  ${GREEN}clean${NC}       - Limpiar contenedores y volúmenes"
    echo -e "  ${GREEN}urls${NC}        - Mostrar URLs de acceso"
    echo -e "  ${GREEN}health${NC}      - Verificar salud de los servicios"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 test"
}

# Función para mostrar estado
show_status() {
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    docker-compose ps
}

# Función para iniciar servicios
start_services() {
    echo -e "${GREEN}🚀 Iniciando servicios de Backstage...${NC}"
    
    # Iniciar dependencias primero
    echo "Iniciando base de datos y cache..."
    docker-compose up -d postgres redis
    
    # Esperar que estén saludables
    echo "Esperando que las dependencias estén listas..."
    sleep 10
    
    # Iniciar backend
    echo "Iniciando Backstage Backend..."
    docker-compose up -d backstage-backend
    
    # Esperar que el backend esté listo
    echo "Esperando que el backend esté listo..."
    sleep 15
    
    # Iniciar frontend
    echo "Iniciando Backstage Frontend..."
    docker-compose up -d backstage-frontend
    
    # Iniciar servicios adicionales
    echo "Iniciando servicios adicionales..."
    docker-compose up -d openai-service proxy-service
    
    echo -e "${GREEN}✅ Servicios iniciados correctamente${NC}"
    show_status
}

# Función para detener servicios
stop_services() {
    echo -e "${YELLOW}🛑 Deteniendo servicios de Backstage...${NC}"
    docker-compose stop backstage-frontend backstage-backend proxy-service
    echo -e "${YELLOW}✅ Servicios de Backstage detenidos${NC}"
}

# Función para reiniciar servicios
restart_services() {
    echo -e "${PURPLE}🔄 Reiniciando servicios de Backstage...${NC}"
    stop_services
    sleep 5
    start_services
}

# Función para mostrar logs
show_logs() {
    echo -e "${BLUE}📋 Logs de Backstage:${NC}"
    echo ""
    echo -e "${GREEN}=== BACKEND LOGS ===${NC}"
    docker-compose logs --tail=20 backstage-backend
    echo ""
    echo -e "${GREEN}=== FRONTEND LOGS ===${NC}"
    docker-compose logs --tail=20 backstage-frontend
}

# Función para construir imágenes
build_images() {
    echo -e "${BLUE}🔨 Construyendo imágenes de Backstage...${NC}"
    docker-compose build --no-cache backstage-frontend backstage-backend
    echo -e "${GREEN}✅ Imágenes construidas correctamente${NC}"
}

# Función para probar endpoints
test_endpoints() {
    echo -e "${BLUE}🧪 Probando endpoints de Backstage...${NC}"
    echo ""
    
    # Test Backend Health
    echo -e "${GREEN}Testing Backend Health:${NC}"
    if curl -s -f http://localhost:7007/health > /dev/null; then
        echo -e "✅ Backend Health: ${GREEN}OK${NC}"
        curl -s http://localhost:7007/health | jq .
    else
        echo -e "❌ Backend Health: ${RED}FAIL${NC}"
    fi
    
    echo ""
    
    # Test Backend API
    echo -e "${GREEN}Testing Backend API:${NC}"
    if curl -s -f http://localhost:7007/api/catalog/entities > /dev/null; then
        echo -e "✅ Backend API: ${GREEN}OK${NC}"
        curl -s http://localhost:7007/api/catalog/entities | jq .
    else
        echo -e "❌ Backend API: ${RED}FAIL${NC}"
    fi
    
    echo ""
    
    # Test Frontend
    echo -e "${GREEN}Testing Frontend:${NC}"
    if curl -s -f http://localhost:3000 > /dev/null; then
        echo -e "✅ Frontend: ${GREEN}OK${NC}"
    else
        echo -e "❌ Frontend: ${RED}FAIL${NC}"
    fi
    
    echo ""
    
    # Test Proxy (si está disponible)
    echo -e "${GREEN}Testing Proxy Service:${NC}"
    if curl -s -f http://localhost:8080/health > /dev/null; then
        echo -e "✅ Proxy Service: ${GREEN}OK${NC}"
    else
        echo -e "⚠️  Proxy Service: ${YELLOW}NOT AVAILABLE${NC}"
    fi
}

# Función para limpiar
clean_services() {
    echo -e "${RED}🧹 Limpiando contenedores y volúmenes...${NC}"
    read -p "¿Estás seguro? Esto eliminará todos los datos (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        docker system prune -f
        echo -e "${GREEN}✅ Limpieza completada${NC}"
    else
        echo -e "${YELLOW}Operación cancelada${NC}"
    fi
}

# Función para mostrar URLs
show_urls() {
    echo -e "${BLUE}🌐 URLs de acceso:${NC}"
    echo ""
    echo -e "${GREEN}Servicios principales:${NC}"
    echo "• Backstage Frontend:  http://localhost:3000"
    echo "• Backstage Backend:   http://localhost:7007"
    echo "• Proxy Gateway:       http://localhost:8080"
    echo ""
    echo -e "${GREEN}APIs:${NC}"
    echo "• Health Check:        http://localhost:7007/health"
    echo "• Catalog API:         http://localhost:7007/api/catalog/entities"
    echo "• OpenAI Service:      http://localhost:8000"
    echo ""
    echo -e "${GREEN}Monitoreo:${NC}"
    echo "• Prometheus:          http://localhost:9090"
    echo "• Grafana:             http://localhost:3001"
    echo ""
    echo -e "${GREEN}Base de datos:${NC}"
    echo "• PostgreSQL:          localhost:5432"
    echo "• Redis:               localhost:6379"
}

# Función para verificar salud
check_health() {
    echo -e "${BLUE}🏥 Verificando salud de los servicios:${NC}"
    echo ""
    
    services=("postgres" "redis" "backstage-backend" "backstage-frontend" "openai-service" "proxy-service")
    
    for service in "${services[@]}"; do
        status=$(docker-compose ps -q $service 2>/dev/null)
        if [ -n "$status" ]; then
            health=$(docker inspect --format='{{.State.Health.Status}}' $(docker-compose ps -q $service) 2>/dev/null || echo "no-healthcheck")
            if [ "$health" = "healthy" ]; then
                echo -e "✅ $service: ${GREEN}HEALTHY${NC}"
            elif [ "$health" = "unhealthy" ]; then
                echo -e "❌ $service: ${RED}UNHEALTHY${NC}"
            elif [ "$health" = "starting" ]; then
                echo -e "🔄 $service: ${YELLOW}STARTING${NC}"
            else
                echo -e "⚪ $service: ${BLUE}RUNNING (no health check)${NC}"
            fi
        else
            echo -e "⚫ $service: ${RED}NOT RUNNING${NC}"
        fi
    done
}

# Función principal
main() {
    case "${1:-help}" in
        "status")
            show_status
            ;;
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            show_logs
            ;;
        "build")
            build_images
            ;;
        "test")
            test_endpoints
            ;;
        "clean")
            clean_services
            ;;
        "urls")
            show_urls
            ;;
        "health")
            check_health
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: docker-compose.yml no encontrado${NC}"
    echo "Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

# Ejecutar función principal
main "$@"
