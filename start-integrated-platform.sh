#!/bin/bash
# =============================================================================
# SCRIPT DE ACCESO DIRECTO: PLATAFORMA INTEGRADA IA-OPS + ICBS
# =============================================================================
# Descripción: Script de acceso directo para iniciar la plataforma completa
# Ubicación: /home/giovanemere/ia-ops/ia-ops/start-integrated-platform.sh
# =============================================================================

# Colores
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 PLATAFORMA INTEGRADA                         ║"
echo "║                  IA-Ops + ICBS Platform                      ║"
echo "║                                                              ║"
echo "║  🚀 Iniciando todos los servicios de forma coordinada...    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Directorio base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ejecutar script integrado
echo -e "${BLUE}📋 Ejecutando startup integrado...${NC}"
exec "$BASE_DIR/scripts/integrated-startup.sh" "$@"
