#!/bin/bash

# =============================================================================
# SCRIPT PARA SOLUCIONAR TODOS LOS PROBLEMAS DE SERVICIOS
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
echo "║                    SOLUCIONANDO PROBLEMAS DE SERVICIOS                      ║"
echo "║                          IA-OPS + WebLogic Stack                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# 1. VERIFICAR ESTADO ACTUAL
# =============================================================================

echo -e "${BLUE}=== 1. VERIFICANDO ESTADO ACTUAL ===${NC}"
echo ""
echo -e "${YELLOW}Servicios IA-OPS:${NC}"
cd /home/giovanemere/ia-ops/ia-ops
docker-compose ps

echo ""
echo -e "${YELLOW}Servicios WebLogic:${NC}"
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
docker-compose ps

# =============================================================================
# 2. SOLUCIONAR MKDOCS (WebLogic) - Falta módulo mermaid2
# =============================================================================

echo -e "${BLUE}=== 2. SOLUCIONANDO MKDOCS (WebLogic) ===${NC}"
echo "Problema: Falta módulo 'mermaid2'"

# Verificar si el archivo mkdocs.yml tiene el plugin mermaid2
if [ -f "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/mkdocs.yml" ]; then
    echo "Verificando configuración de MkDocs..."
    if grep -q "mermaid2" /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/mkdocs.yml; then
        echo "Encontrado plugin mermaid2 en configuración"
        echo "Reiniciando MkDocs con dependencias correctas..."
        cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
        docker-compose stop mkdocs-server
        docker-compose rm -f mkdocs-server
        docker-compose up -d mkdocs-server
    fi
fi

# =============================================================================
# 3. SOLUCIONAR HAPROXY - Problema con health check
# =============================================================================

echo -e "${BLUE}=== 3. SOLUCIONANDO HAPROXY ===${NC}"
echo "Problema: Health check fallando en /stats"

# Reiniciar HAProxy
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
echo "Reiniciando HAProxy..."
docker-compose restart haproxy

# Esperar un momento para que se estabilice
sleep 10

# Verificar si HAProxy responde
if curl -s http://localhost:8083 >/dev/null; then
    echo -e "${GREEN}✅ HAProxy respondiendo en puerto 8083${NC}"
else
    echo -e "${RED}❌ HAProxy aún no responde${NC}"
fi

# =============================================================================
# 4. SOLUCIONAR OPENAI SERVICE
# =============================================================================

echo -e "${BLUE}=== 4. SOLUCIONANDO OPENAI SERVICE ===${NC}"
echo "Problema: Servicio unhealthy"

cd /home/giovanemere/ia-ops/ia-ops
echo "Reiniciando OpenAI Service..."
docker-compose restart openai-service

# Esperar y verificar
sleep 10
if curl -s http://localhost:8003/health >/dev/null; then
    echo -e "${GREEN}✅ OpenAI Service respondiendo${NC}"
else
    echo -e "${RED}❌ OpenAI Service aún no responde${NC}"
fi

# =============================================================================
# 5. SOLUCIONAR MKDOCS (IA-OPS)
# =============================================================================

echo -e "${BLUE}=== 5. SOLUCIONANDO MKDOCS (IA-OPS) ===${NC}"
echo "Reiniciando MkDocs de IA-OPS..."

cd /home/giovanemere/ia-ops/ia-ops
docker-compose restart mkdocs

sleep 10
if curl -s http://localhost:8005 >/dev/null; then
    echo -e "${GREEN}✅ MkDocs IA-OPS respondiendo${NC}"
else
    echo -e "${RED}❌ MkDocs IA-OPS aún no responde${NC}"
fi

# =============================================================================
# 6. VERIFICAR SERVICIOS PRINCIPALES
# =============================================================================

echo -e "${BLUE}=== 6. VERIFICANDO SERVICIOS PRINCIPALES ===${NC}"

# URLs principales para verificar
declare -A services=(
    ["Backstage Frontend"]="http://localhost:3002"
    ["Backstage Backend"]="http://localhost:7007/api/catalog/entities"
    ["Portainer"]="http://localhost:9080"
    ["Jenkins"]="http://localhost:8091"
    ["WebLogic A"]="http://localhost:7001/console"
    ["WebLogic B"]="http://localhost:7002/console"
    ["HAProxy"]="http://localhost:8083"
    ["HAProxy Stats"]="http://localhost:8404/stats"
    ["OpenAI Service"]="http://localhost:8003"
    ["MkDocs IA-OPS"]="http://localhost:8005"
    ["Grafana"]="http://localhost:3001"
    ["Prometheus"]="http://localhost:9090"
    ["Nexus"]="http://localhost:8092"
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

# =============================================================================
# 7. MOSTRAR RESUMEN FINAL
# =============================================================================

echo ""
echo -e "${CYAN}=== RESUMEN FINAL ===${NC}"
echo ""
echo -e "${YELLOW}Servicios principales disponibles:${NC}"
echo "🏛️  Backstage:        http://localhost:3002"
echo "🐳 Portainer:        http://localhost:9080"
echo "🔧 Jenkins:          http://localhost:8091"
echo "☕ WebLogic A:       http://localhost:7001/console"
echo "☕ WebLogic B:       http://localhost:7002/console"
echo "⚖️  HAProxy:          http://localhost:8083"
echo "📊 HAProxy Stats:    http://localhost:8404/stats"
echo "🤖 OpenAI Service:   http://localhost:8003"
echo "📚 MkDocs:           http://localhost:8005"
echo "📈 Grafana:          http://localhost:3001"
echo "📊 Prometheus:       http://localhost:9090"
echo "📦 Nexus:            http://localhost:8092"
echo ""
echo -e "${GREEN}✨ Solución de problemas completada${NC}"
