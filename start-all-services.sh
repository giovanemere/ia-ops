#!/bin/bash

# =============================================================================
# SCRIPT MAESTRO PARA INICIAR TODOS LOS SERVICIOS IA-OPS
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    INICIANDO TODOS LOS SERVICIOS IA-OPS                     ║"
echo "║                     Plataforma Completa + WebLogic Stack                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# 1. SERVICIOS BASE (Docker Compose)
# =============================================================================

echo -e "${BLUE}=== 1. INICIANDO SERVICIOS BASE ===${NC}"
cd /home/giovanemere/ia-ops/ia-ops
echo "🐳 Iniciando servicios Docker Compose..."
docker-compose up -d
echo -e "${GREEN}✅ Servicios base iniciados${NC}"
echo ""

# =============================================================================
# 2. SERVICIOS WEBLOGIC STACK
# =============================================================================

echo -e "${BLUE}=== 2. INICIANDO WEBLOGIC STACK ===${NC}"
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
echo "☕ Iniciando servicios WebLogic..."
./manage-services.sh start
echo -e "${GREEN}✅ WebLogic Stack iniciado${NC}"
echo ""

# =============================================================================
# 3. SERVICIOS DE TEMPLATES
# =============================================================================

echo -e "${BLUE}=== 3. INICIANDO SERVICIO DE TEMPLATES ===${NC}"
cd /home/giovanemere/ia-ops/ia-ops/templates
echo "🎯 Iniciando servidor de templates..."
docker-compose up -d
echo -e "${GREEN}✅ Servicio de templates iniciado${NC}"
echo ""

# =============================================================================
# 4. SERVICIOS DE FRAMEWORK
# =============================================================================

echo -e "${BLUE}=== 4. INICIANDO SERVICIO DE FRAMEWORK ===${NC}"
cd /home/giovanemere/ia-ops/ia-ops/framework
echo "🏗️ Iniciando servidor de framework..."
docker-compose up -d
echo -e "${GREEN}✅ Servicio de framework iniciado${NC}"
echo ""

# =============================================================================
# 5. BACKSTAGE (ÚLTIMO)
# =============================================================================

echo -e "${BLUE}=== 5. INICIANDO BACKSTAGE ===${NC}"
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
echo "🏛️ Preparando Backstage..."

# Limpiar puertos
./kill-ports.sh

# Generar catálogos
echo "📝 Generando archivos de catálogo..."
./generate-catalog-files.sh

# Sincronizar configuración
echo "🔄 Sincronizando configuración..."
./sync-env-config.sh

# Iniciar Backstage
echo "🚀 Iniciando Backstage..."
nohup ./start-robust.sh > backstage-startup-$(date +%Y%m%d-%H%M%S).log 2>&1 &

echo -e "${GREEN}✅ Backstage iniciándose en segundo plano${NC}"
echo ""

# =============================================================================
# 6. ESPERAR Y VERIFICAR
# =============================================================================

echo -e "${BLUE}=== 6. VERIFICANDO SERVICIOS ===${NC}"
echo "⏳ Esperando que los servicios se estabilicen..."
sleep 30

# Verificar servicios principales
declare -A services=(
    ["🐳 Portainer"]="http://localhost:9080"
    ["🔧 Jenkins"]="http://localhost:8091"
    ["☕ WebLogic A"]="http://localhost:7001"
    ["☕ WebLogic B"]="http://localhost:7002"
    ["⚖️ HAProxy"]="http://localhost:8083"
    ["📦 Nexus"]="http://localhost:8092"
    ["🤖 OpenAI Service"]="http://localhost:8003"
    ["📚 MkDocs IA-OPS"]="http://localhost:8005"
    ["📈 Grafana"]="http://localhost:3001"
    ["📊 Prometheus"]="http://localhost:9090"
    ["🎯 Templates"]="http://localhost:8006"
    ["🏗️ Framework"]="http://localhost:1100"
)

echo ""
for service in "${!services[@]}"; do
    url="${services[$service]}"
    if curl -s --max-time 5 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $service: $url${NC}"
    else
        echo -e "${RED}❌ $service: $url${NC}"
    fi
done

# Verificar Backstage (puede tardar más)
echo ""
echo "🏛️ Verificando Backstage (puede tardar unos minutos)..."
for i in {1..6}; do
    if curl -s --max-time 5 "http://localhost:3002" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backstage Frontend: http://localhost:3002${NC}"
        break
    elif curl -s --max-time 5 "http://localhost:7007" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backstage Backend: http://localhost:7007${NC}"
        break
    else
        echo "⏳ Backstage aún iniciando... ($i/6)"
        sleep 30
    fi
done

# =============================================================================
# 7. RESUMEN FINAL
# =============================================================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                           SERVICIOS DISPONIBLES                             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
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
echo -e "${YELLOW}🎯 Templates:${NC}            http://localhost:8006"
echo -e "${YELLOW}🏗️ Framework:${NC}            http://localhost:1100"
echo ""
echo -e "${GREEN}✨ ¡Plataforma IA-OPS completamente iniciada!${NC}"
echo ""
echo -e "${CYAN}📝 Notas importantes:${NC}"
echo "• Backstage puede tardar 2-3 minutos en estar completamente disponible"
echo "• Todos los servicios tienen health checks configurados"
echo "• Los logs de Backstage están en applications/backstage/"
echo "• Para verificar el estado: ./verify-all-services.sh"
