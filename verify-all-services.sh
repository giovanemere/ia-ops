#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN COMPLETA DE SERVICIOS
# =============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICACIÓN COMPLETA DE SERVICIOS                       ║"
echo "║                          IA-OPS + WebLogic Stack                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Función para verificar servicio
check_service() {
    local name="$1"
    local url="$2"
    local description="$3"
    
    if curl -s --max-time 5 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name${NC}: $url"
        echo -e "   $description"
    else
        echo -e "${RED}❌ $name${NC}: $url"
        echo -e "   $description"
    fi
    echo ""
}

echo -e "${BLUE}=== SERVICIOS PRINCIPALES ===${NC}"
echo ""

check_service "Backstage Frontend" "http://localhost:3002" "Portal de desarrolladores - Interfaz principal"
check_service "Backstage Backend" "http://localhost:7007" "API de Backstage - Servicios backend"

echo -e "${BLUE}=== SERVICIOS WEBLOGIC STACK ===${NC}"
echo ""

check_service "Portainer" "http://localhost:9080" "Gestión de contenedores Docker"
check_service "Jenkins" "http://localhost:8091" "CI/CD - Integración continua"
check_service "WebLogic A Console" "http://localhost:7001" "Servidor WebLogic A - Consola de administración"
check_service "WebLogic B Console" "http://localhost:7002" "Servidor WebLogic B - Consola de administración"
check_service "HAProxy" "http://localhost:8083" "Load Balancer - Balanceador de carga"
check_service "HAProxy Stats" "http://localhost:8404/stats" "Estadísticas de HAProxy"
check_service "Nexus" "http://localhost:8092" "Repositorio de artefactos"

echo -e "${BLUE}=== SERVICIOS IA-OPS ===${NC}"
echo ""

check_service "OpenAI Service" "http://localhost:8003" "Servicio de IA - API de OpenAI"
check_service "MkDocs IA-OPS" "http://localhost:8005" "Documentación de IA-OPS"
check_service "Grafana" "http://localhost:3001" "Dashboards y métricas"
check_service "Prometheus" "http://localhost:9090" "Recolección de métricas"

echo -e "${BLUE}=== SERVICIOS DE BASE DE DATOS ===${NC}"
echo ""

# Verificar PostgreSQL
if docker-compose -f /home/giovanemere/ia-ops/ia-ops/docker-compose.yml exec postgres pg_isready >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL${NC}: localhost:5432"
    echo -e "   Base de datos principal para Backstage"
else
    echo -e "${RED}❌ PostgreSQL${NC}: localhost:5432"
    echo -e "   Base de datos principal para Backstage"
fi
echo ""

# Verificar Redis
if docker-compose -f /home/giovanemere/ia-ops/ia-ops/docker-compose.yml exec redis redis-cli ping >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis${NC}: localhost:6379"
    echo -e "   Cache y sesiones"
else
    echo -e "${RED}❌ Redis${NC}: localhost:6379"
    echo -e "   Cache y sesiones"
fi
echo ""

# Verificar Oracle DB
if docker exec orcldb sqlplus -s sys/oracle@localhost:1521/XE as sysdba <<< "SELECT 1 FROM DUAL;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Oracle Database${NC}: localhost:1521"
    echo -e "   Base de datos Oracle para WebLogic"
else
    echo -e "${RED}❌ Oracle Database${NC}: localhost:1521"
    echo -e "   Base de datos Oracle para WebLogic"
fi
echo ""

echo -e "${CYAN}=== RESUMEN DE ACCESOS ===${NC}"
echo ""
echo -e "${YELLOW}🏛️  Backstage Portal:${NC}     http://localhost:3002"
echo -e "${YELLOW}🐳 Portainer:${NC}            http://localhost:9080"
echo -e "${YELLOW}🔧 Jenkins:${NC}              http://localhost:8091"
echo -e "${YELLOW}☕ WebLogic A:${NC}           http://localhost:7001/console"
echo -e "${YELLOW}☕ WebLogic B:${NC}           http://localhost:7002/console"
echo -e "${YELLOW}⚖️  HAProxy:${NC}              http://localhost:8083"
echo -e "${YELLOW}📊 HAProxy Stats:${NC}        http://localhost:8404/stats"
echo -e "${YELLOW}🤖 OpenAI Service:${NC}       http://localhost:8003"
echo -e "${YELLOW}📚 MkDocs:${NC}               http://localhost:8005"
echo -e "${YELLOW}📈 Grafana:${NC}              http://localhost:3001"
echo -e "${YELLOW}📊 Prometheus:${NC}           http://localhost:9090"
echo -e "${YELLOW}📦 Nexus:${NC}                http://localhost:8092"
echo ""
echo -e "${GREEN}✨ Verificación completada${NC}"
