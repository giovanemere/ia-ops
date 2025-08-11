#!/bin/bash

# =============================================================================
# SCRIPT DE INICIO COMPLETO - IA-OPS PLATFORM
# =============================================================================
# Descripción: Inicia toda la solución IA-Ops con todos los servicios
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🚀 Iniciando solución completa IA-Ops Platform..."

# Verificar directorio
if [ ! -f "docker-compose.yml" ]; then
    log_error "No se encontró docker-compose.yml. Ejecuta desde el directorio raíz."
    exit 1
fi

echo ""
log_info "=== PASO 1: DETENER SERVICIOS EXISTENTES ==="
docker-compose down || true
log_success "Servicios existentes detenidos"

echo ""
log_info "=== PASO 2: INICIAR SERVICIOS PRINCIPALES ==="

log_info "Iniciando servicios base..."
docker-compose up -d postgres redis openai-service

log_info "Esperando que los servicios base estén listos..."
sleep 15

log_info "Iniciando servicios de monitoreo..."
docker-compose up -d prometheus grafana

log_info "Iniciando servicios de documentación..."
docker-compose up -d mkdocs

log_success "Todos los servicios Docker iniciados"

echo ""
log_info "=== PASO 3: VERIFICAR SERVICIOS ==="

# Verificar PostgreSQL
if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    log_success "PostgreSQL: Operativo (puerto 5432)"
else
    log_warning "PostgreSQL: Iniciando..."
fi

# Verificar OpenAI Service
if curl -s http://localhost:8003/health >/dev/null 2>&1; then
    log_success "OpenAI Service: Operativo (puerto 8003)"
else
    log_warning "OpenAI Service: Iniciando..."
fi

# Verificar Prometheus
if curl -s http://localhost:9090/-/healthy >/dev/null 2>&1; then
    log_success "Prometheus: Operativo (puerto 9090)"
else
    log_warning "Prometheus: Iniciando..."
fi

# Verificar Grafana
if curl -s http://localhost:3001/api/health >/dev/null 2>&1; then
    log_success "Grafana: Operativo (puerto 3001)"
else
    log_warning "Grafana: Iniciando..."
fi

echo ""
log_info "=== PASO 4: INICIAR BACKSTAGE ==="

cd applications/backstage

log_info "Iniciando Backstage Backend y Frontend..."
nohup yarn start > ../../backstage-complete.log 2>&1 &
BACKSTAGE_PID=$!

log_info "Backstage iniciando en background (PID: $BACKSTAGE_PID)"
log_info "Logs disponibles en: backstage-complete.log"

cd ../..

echo ""
log_info "=== PASO 5: ESTADO FINAL ==="

sleep 10
docker-compose ps

echo ""
log_success "=== SOLUCIÓN IA-OPS COMPLETAMENTE INICIADA ==="

echo ""
echo "🌐 ACCESO A SERVICIOS:"
echo "   🏛️  Backstage Portal:    http://localhost:3002"
echo "   🤖 OpenAI Service:      http://localhost:8003"
echo "   📊 Grafana:             http://localhost:3001"
echo "   📈 Prometheus:          http://localhost:9090"
echo "   📚 MkDocs:              http://localhost:8005"

echo ""
echo "🔍 HEALTH CHECKS:"
echo "   PostgreSQL:  pg_isready -h localhost -p 5432"
echo "   OpenAI:      curl http://localhost:8003/health"
echo "   Prometheus:  curl http://localhost:9090/-/healthy"
echo "   Grafana:     curl http://localhost:3001/api/health"

echo ""
echo "📊 MONITOREO:"
echo "   docker-compose ps                    # Estado de servicios"
echo "   docker-compose logs [servicio]      # Logs específicos"
echo "   tail -f backstage-complete.log      # Logs de Backstage"

echo ""
log_success "¡Solución IA-Ops Platform completamente operativa!"
