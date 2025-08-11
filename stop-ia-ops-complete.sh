#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - SCRIPT DE PARADA COMPLETO
# =============================================================================
# Detiene todos los servicios de la plataforma IA-Ops
# =============================================================================

set -e

echo "🛑 Deteniendo IA-Ops Platform..."
echo "================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Detener Backstage
log_info "Deteniendo Backstage..."
cd applications/backstage
./kill-ports.sh > /dev/null 2>&1 || true
pkill -f "backstage\|yarn" > /dev/null 2>&1 || true
cd ../../

# 2. Detener servicios Docker
log_info "Deteniendo servicios Docker..."
docker-compose down

# 3. Verificar que los puertos estén libres
log_info "Verificando puertos..."
PORTS_IN_USE=$(netstat -tlnp 2>/dev/null | grep -E ':(3002|7007|5432|6379|8003|8004|3001|9090|8005|8006|9100|8082)' | wc -l)

if [ $PORTS_IN_USE -eq 0 ]; then
    log_success "Todos los puertos están libres"
else
    log_warning "$PORTS_IN_USE puertos aún están en uso"
    echo "Puertos en uso:"
    netstat -tlnp 2>/dev/null | grep -E ':(3002|7007|5432|6379|8003|8004|3001|9090|8005|8006|9100|8082)' || true
fi

# 4. Limpiar procesos zombie si existen
log_info "Limpiando procesos..."
pkill -f "node.*backstage" > /dev/null 2>&1 || true
pkill -f "yarn.*start" > /dev/null 2>&1 || true

echo ""
log_success "IA-Ops Platform detenida exitosamente"
echo ""
echo "📋 Para reiniciar:"
echo "  ./start-ia-ops-complete.sh"
echo ""
echo "🔍 Para verificar que todo esté detenido:"
echo "  docker-compose ps"
echo "  netstat -tlnp | grep -E ':(3002|7007|5432|6379|8003)'"
echo ""
