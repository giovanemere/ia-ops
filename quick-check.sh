#!/bin/bash

# =============================================================================
# VERIFICACIÓN RÁPIDA DE LA PLATAFORMA IA-OPS
# =============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔍 VERIFICACIÓN RÁPIDA DE SERVICIOS${NC}"
echo ""

# Función para verificar servicio
check_service() {
    local name="$1"
    local url="$2"
    local icon="$3"
    
    if curl -s --max-time 3 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $icon $name${NC}"
        return 0
    else
        echo -e "${RED}❌ $icon $name${NC}"
        return 1
    fi
}

# Servicios críticos
echo -e "${BLUE}🏛️ SERVICIOS PRINCIPALES:${NC}"
check_service "Backstage Frontend" "http://localhost:3002" "🏛️"
check_service "Backstage Backend" "http://localhost:7007" "🏛️"
check_service "OpenAI Service" "http://localhost:8003" "🤖"

echo ""
echo -e "${BLUE}🐳 WEBLOGIC STACK:${NC}"
check_service "Portainer" "http://localhost:9080" "🐳"
check_service "Jenkins" "http://localhost:8091" "🔧"
check_service "WebLogic A" "http://localhost:7001" "☕"
check_service "WebLogic B" "http://localhost:7002" "☕"
check_service "HAProxy" "http://localhost:8083" "⚖️"

echo ""
echo -e "${BLUE}🎯 TEMPLATES Y FRAMEWORK:${NC}"
check_service "Templates" "http://localhost:8006" "🎯"
check_service "Framework" "http://localhost:1100" "🏗️"

echo ""
echo -e "${BLUE}📊 MONITOREO:${NC}"
check_service "Grafana" "http://localhost:3001" "📈"
check_service "Prometheus" "http://localhost:9090" "📊"

echo ""
echo -e "${CYAN}📋 PROCESOS DE BACKSTAGE:${NC}"
if pgrep -f "yarn.*backstage" >/dev/null; then
    echo -e "${GREEN}✅ Procesos de Backstage corriendo${NC}"
else
    echo -e "${RED}❌ No se detectan procesos de Backstage${NC}"
fi

echo ""
echo -e "${CYAN}🐳 CONTENEDORES ACTIVOS:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(ia-ops|weblogic|haproxy|portainer|jenkins|nexus)" | head -10

echo ""
echo -e "${CYAN}💡 COMANDOS ÚTILES:${NC}"
echo "   Reiniciar todo: ./start-platform.sh"
echo "   Solo Backstage: cd applications/backstage && ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh"
echo "   Solo WebLogic:  cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic && ./manage-services.sh start"
