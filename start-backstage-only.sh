#!/bin/bash

# =============================================================================
# SCRIPT PARA INICIAR SOLO BACKSTAGE
# Usa tu comando exacto
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
echo "║                           INICIANDO SOLO BACKSTAGE                          ║"
echo "║                         Tu comando exacto                                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${PURPLE}Ejecutando tu comando exacto:${NC}"
echo -e "${YELLOW}cd /home/giovanemere/ia-ops/ia-ops/applications/backstage && ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh${NC}"
echo ""

# Cambiar al directorio de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Verificar que todos los scripts existen
scripts=("kill-ports.sh" "generate-catalog-files.sh" "sync-env-config.sh" "start-robust.sh")
for script in "${scripts[@]}"; do
    if [ ! -x "./$script" ]; then
        echo -e "${RED}❌ Script no encontrado: $script${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Todos los scripts verificados${NC}"
echo ""

# Ejecutar cada paso
echo -e "${BLUE}=== 1. LIBERANDO PUERTOS ===${NC}"
./kill-ports.sh
echo ""

echo -e "${BLUE}=== 2. GENERANDO ARCHIVOS DE CATÁLOGO ===${NC}"
./generate-catalog-files.sh
echo ""

echo -e "${BLUE}=== 3. SINCRONIZANDO CONFIGURACIÓN ===${NC}"
./sync-env-config.sh
echo ""

echo -e "${BLUE}=== 4. INICIANDO BACKSTAGE ===${NC}"
echo "🚀 Iniciando Backstage (esto puede tardar varios minutos)..."

# Crear log con timestamp
LOG_FILE="backstage-startup-$(date +%Y%m%d-%H%M%S).log"

# Iniciar en background
nohup ./start-robust.sh > "$LOG_FILE" 2>&1 &
BACKSTAGE_PID=$!

echo -e "${GREEN}✅ Backstage iniciándose en segundo plano${NC}"
echo -e "${CYAN}📋 PID: $BACKSTAGE_PID${NC}"
echo -e "${CYAN}📋 Log: $LOG_FILE${NC}"
echo ""

# Monitorear el inicio
echo -e "${BLUE}=== 5. MONITOREANDO INICIO ===${NC}"
echo "⏳ Esperando que Backstage inicie..."

for i in {1..12}; do
    sleep 15
    
    # Verificar si el proceso sigue corriendo
    if ! kill -0 $BACKSTAGE_PID 2>/dev/null; then
        echo -e "${RED}❌ El proceso de Backstage se detuvo inesperadamente${NC}"
        echo "📋 Últimas líneas del log:"
        tail -10 "$LOG_FILE"
        exit 1
    fi
    
    # Verificar si ya responde
    if curl -s --max-time 3 "http://localhost:3002" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backstage Frontend respondiendo: http://localhost:3002${NC}"
        break
    elif curl -s --max-time 3 "http://localhost:7007" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backstage Backend respondiendo: http://localhost:7007${NC}"
        break
    else
        echo "⏳ Backstage aún iniciando... ($i/12) - $(date '+%H:%M:%S')"
        
        # Mostrar últimas líneas del log cada 4 intentos
        if [ $((i % 4)) -eq 0 ]; then
            echo "📋 Últimas líneas del log:"
            tail -3 "$LOG_FILE" | sed 's/^/   /'
        fi
    fi
done

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            BACKSTAGE INICIADO                               ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}🌐 ACCESOS:${NC}"
echo "   🏛️  Frontend: http://localhost:3002"
echo "   🏛️  Backend:  http://localhost:7007"
echo ""
echo -e "${YELLOW}📋 INFORMACIÓN:${NC}"
echo "   PID: $BACKSTAGE_PID"
echo "   Log: $LOG_FILE"
echo ""
echo -e "${YELLOW}🔧 COMANDOS ÚTILES:${NC}"
echo "   Ver log en tiempo real: tail -f $LOG_FILE"
echo "   Verificar estado: ./quick-check.sh"
echo "   Matar proceso: kill $BACKSTAGE_PID"
echo ""
echo -e "${GREEN}✨ ¡Backstage iniciado con tu comando exacto!${NC}"
