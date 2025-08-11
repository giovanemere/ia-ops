#!/bin/bash

# =============================================================================
# SCRIPT MAESTRO PARA INICIAR LA PLATAFORMA IA-OPS
# Usa los comandos exactos que has estado utilizando
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                      INICIANDO PLATAFORMA IA-OPS                            ║"
echo "║                    Usando comandos de producción                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# 1. VERIFICAR PREREQUISITOS
# =============================================================================

echo -e "${BLUE}=== 1. VERIFICANDO PREREQUISITOS ===${NC}"

# Verificar que los directorios existen
if [ ! -d "/home/giovanemere/ia-ops/ia-ops/applications/backstage" ]; then
    echo -e "${RED}❌ Directorio de Backstage no encontrado${NC}"
    exit 1
fi

if [ ! -d "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic" ]; then
    echo -e "${RED}❌ Directorio de WebLogic no encontrado${NC}"
    exit 1
fi

# Verificar que los scripts existen
scripts=(
    "/home/giovanemere/ia-ops/ia-ops/applications/backstage/kill-ports.sh"
    "/home/giovanemere/ia-ops/ia-ops/applications/backstage/generate-catalog-files.sh"
    "/home/giovanemere/ia-ops/ia-ops/applications/backstage/sync-env-config.sh"
    "/home/giovanemere/ia-ops/ia-ops/applications/backstage/start-robust.sh"
    "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/manage-services.sh"
)

for script in "${scripts[@]}"; do
    if [ ! -x "$script" ]; then
        echo -e "${RED}❌ Script no encontrado o no ejecutable: $(basename $script)${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Todos los prerequisitos verificados${NC}"
echo ""

# =============================================================================
# 2. INICIAR SERVICIOS BASE (Docker Compose)
# =============================================================================

echo -e "${BLUE}=== 2. INICIANDO SERVICIOS BASE ===${NC}"
cd /home/giovanemere/ia-ops/ia-ops

echo "🐳 Iniciando servicios Docker Compose base..."
if docker-compose up -d; then
    echo -e "${GREEN}✅ Servicios base iniciados correctamente${NC}"
else
    echo -e "${RED}❌ Error iniciando servicios base${NC}"
    exit 1
fi
echo ""

# =============================================================================
# 3. INICIAR WEBLOGIC STACK (TU COMANDO EXACTO)
# =============================================================================

echo -e "${BLUE}=== 3. INICIANDO WEBLOGIC STACK ===${NC}"
echo -e "${PURPLE}Ejecutando: cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic && ./manage-services.sh start${NC}"

cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
if ./manage-services.sh start; then
    echo -e "${GREEN}✅ WebLogic Stack iniciado correctamente${NC}"
else
    echo -e "${YELLOW}⚠️ WebLogic Stack puede haber tenido problemas, pero continuando...${NC}"
fi
echo ""

# =============================================================================
# 4. INICIAR BACKSTAGE (TU COMANDO EXACTO)
# =============================================================================

echo -e "${BLUE}=== 4. INICIANDO BACKSTAGE ===${NC}"
echo -e "${PURPLE}Ejecutando: cd /home/giovanemere/ia-ops/ia-ops/applications/backstage && ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh${NC}"

cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Ejecutar cada paso de tu comando exacto
echo "🔪 Ejecutando kill-ports.sh..."
if ./kill-ports.sh; then
    echo -e "${GREEN}✅ Puertos liberados${NC}"
else
    echo -e "${YELLOW}⚠️ Algunos puertos pueden no haberse liberado${NC}"
fi

echo "📝 Ejecutando generate-catalog-files.sh..."
if ./generate-catalog-files.sh; then
    echo -e "${GREEN}✅ Archivos de catálogo generados${NC}"
else
    echo -e "${RED}❌ Error generando archivos de catálogo${NC}"
    exit 1
fi

echo "🔄 Ejecutando sync-env-config.sh..."
if ./sync-env-config.sh; then
    echo -e "${GREEN}✅ Configuración sincronizada${NC}"
else
    echo -e "${RED}❌ Error sincronizando configuración${NC}"
    exit 1
fi

echo "🚀 Ejecutando start-robust.sh..."
echo "   (Esto puede tardar varios minutos...)"

# Iniciar en background y capturar el PID
nohup ./start-robust.sh > backstage-startup-$(date +%Y%m%d-%H%M%S).log 2>&1 &
BACKSTAGE_PID=$!

echo -e "${GREEN}✅ Backstage iniciándose en segundo plano (PID: $BACKSTAGE_PID)${NC}"
echo ""

# =============================================================================
# 5. INICIAR SERVICIOS ADICIONALES (Templates y Framework)
# =============================================================================

echo -e "${BLUE}=== 5. INICIANDO SERVICIOS ADICIONALES ===${NC}"

# Templates
if [ -f "/home/giovanemere/ia-ops/ia-ops/templates/docker-compose.yml" ]; then
    echo "🎯 Iniciando servicio de templates..."
    cd /home/giovanemere/ia-ops/ia-ops/templates
    docker-compose up -d
    echo -e "${GREEN}✅ Templates iniciado${NC}"
fi

# Framework
if [ -f "/home/giovanemere/ia-ops/ia-ops/framework/docker-compose.yml" ]; then
    echo "🏗️ Iniciando servicio de framework..."
    cd /home/giovanemere/ia-ops/ia-ops/framework
    docker-compose up -d
    echo -e "${GREEN}✅ Framework iniciado${NC}"
fi
echo ""

# =============================================================================
# 6. VERIFICACIÓN Y MONITOREO
# =============================================================================

echo -e "${BLUE}=== 6. VERIFICANDO SERVICIOS ===${NC}"
echo "⏳ Esperando que los servicios se estabilicen..."
sleep 20

# Función para verificar servicio
check_service() {
    local name="$1"
    local url="$2"
    local icon="$3"
    
    if curl -s --max-time 5 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $icon $name: $url${NC}"
        return 0
    else
        echo -e "${RED}❌ $icon $name: $url${NC}"
        return 1
    fi
}

# Verificar servicios principales
echo ""
echo "🔍 Verificando servicios principales:"
check_service "Portainer" "http://localhost:9080" "🐳"
check_service "Jenkins" "http://localhost:8091" "🔧"
check_service "WebLogic A" "http://localhost:7001" "☕"
check_service "WebLogic B" "http://localhost:7002" "☕"
check_service "HAProxy" "http://localhost:8083" "⚖️"
check_service "Nexus" "http://localhost:8092" "📦"

echo ""
echo "🔍 Verificando servicios IA-OPS:"
check_service "OpenAI Service" "http://localhost:8003" "🤖"
check_service "MkDocs" "http://localhost:8005" "📚"
check_service "Grafana" "http://localhost:3001" "📈"
check_service "Prometheus" "http://localhost:9090" "📊"

if [ -f "/home/giovanemere/ia-ops/ia-ops/templates/docker-compose.yml" ]; then
    check_service "Templates" "http://localhost:8006" "🎯"
fi

if [ -f "/home/giovanemere/ia-ops/ia-ops/framework/docker-compose.yml" ]; then
    check_service "Framework" "http://localhost:1100" "🏗️"
fi

# Verificar Backstage (puede tardar más)
echo ""
echo "🏛️ Verificando Backstage (puede tardar 2-3 minutos)..."
backstage_ready=false
for i in {1..6}; do
    if check_service "Backstage Frontend" "http://localhost:3002" "🏛️" 2>/dev/null; then
        backstage_ready=true
        break
    elif check_service "Backstage Backend" "http://localhost:7007" "🏛️" 2>/dev/null; then
        backstage_ready=true
        break
    else
        echo "⏳ Backstage aún iniciando... ($i/6) - Esperando 30s más"
        sleep 30
    fi
done

if [ "$backstage_ready" = false ]; then
    echo -e "${YELLOW}⚠️ Backstage aún no responde, pero puede estar iniciando${NC}"
    echo "   Revisa los logs en: /home/giovanemere/ia-ops/ia-ops/applications/backstage/"
fi

# =============================================================================
# 7. RESUMEN FINAL
# =============================================================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                           PLATAFORMA IA-OPS INICIADA                        ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}🌐 SERVICIOS PRINCIPALES:${NC}"
echo "   🏛️  Backstage:        http://localhost:3002"
echo "   🤖 OpenAI Service:   http://localhost:8003"
echo ""
echo -e "${YELLOW}🐳 WEBLOGIC STACK:${NC}"
echo "   🐳 Portainer:        http://localhost:9080"
echo "   🔧 Jenkins:          http://localhost:8091"
echo "   ☕ WebLogic A:       http://localhost:7001/console"
echo "   ☕ WebLogic B:       http://localhost:7002/console"
echo "   ⚖️  HAProxy:          http://localhost:8083"
echo "   📦 Nexus:            http://localhost:8092"
echo ""
echo -e "${YELLOW}📊 MONITOREO:${NC}"
echo "   📈 Grafana:          http://localhost:3001"
echo "   📊 Prometheus:       http://localhost:9090"
echo ""
echo -e "${YELLOW}🎯 TEMPLATES Y FRAMEWORK:${NC}"
echo "   🎯 Templates:        http://localhost:8006"
echo "   🏗️ Framework:        http://localhost:1100"
echo ""
echo -e "${GREEN}✨ ¡Plataforma iniciada con tus comandos exactos!${NC}"
echo ""
echo -e "${CYAN}📝 COMANDOS UTILIZADOS:${NC}"
echo "   1. cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic && ./manage-services.sh start"
echo "   2. cd /home/giovanemere/ia-ops/ia-ops/applications/backstage && ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh"
echo ""
echo -e "${CYAN}🔧 PARA VERIFICAR ESTADO:${NC}"
echo "   ./verify-all-services.sh"
echo ""
echo -e "${CYAN}📋 LOGS DE BACKSTAGE:${NC}"
echo "   tail -f /home/giovanemere/ia-ops/ia-ops/applications/backstage/backstage-startup-*.log"
