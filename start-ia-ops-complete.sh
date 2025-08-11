#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - SCRIPT DE INICIO COMPLETO
# =============================================================================
# Inicia todos los servicios de la plataforma IA-Ops
# Backstage en host + Servicios de soporte en Docker
# =============================================================================

set -e

echo "🚀 Iniciando IA-Ops Platform Completa..."
echo "========================================"

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

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    log_error "No se encontró docker-compose.yml. Ejecuta desde el directorio raíz del proyecto."
    exit 1
fi

# 1. Iniciar servicios de soporte en Docker
log_info "Iniciando servicios de soporte en Docker..."
docker-compose up -d postgres redis openai-service

# Esperar a que los servicios estén listos
log_info "Esperando a que los servicios estén listos..."
sleep 10

# Verificar estado de servicios Docker
log_info "Verificando estado de servicios Docker..."
if docker-compose ps | grep -q "Up (healthy).*postgres"; then
    log_success "PostgreSQL está funcionando"
else
    log_warning "PostgreSQL puede no estar completamente listo"
fi

if docker-compose ps | grep -q "Up (healthy).*redis"; then
    log_success "Redis está funcionando"
else
    log_warning "Redis puede no estar completamente listo"
fi

if docker-compose ps | grep -q "Up.*openai-service"; then
    log_success "OpenAI Service está funcionando"
else
    log_warning "OpenAI Service puede no estar completamente listo"
fi

# 2. Preparar y iniciar Backstage
log_info "Preparando Backstage..."
cd applications/backstage

# Liberar puertos si están ocupados
log_info "Liberando puertos..."
./kill-ports.sh > /dev/null 2>&1 || true

# Sincronizar configuración
log_info "Sincronizando configuración..."
./sync-env-config.sh > /dev/null 2>&1 || true

# Iniciar Backstage en background
log_info "Iniciando Backstage..."
nohup ./start-robust.sh > backstage-production.log 2>&1 &

# Volver al directorio raíz
cd ../../

# 3. Esperar a que Backstage esté listo
log_info "Esperando a que Backstage esté listo..."
BACKSTAGE_READY=false
ATTEMPTS=0
MAX_ATTEMPTS=30

while [ $BACKSTAGE_READY = false ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
        BACKSTAGE_READY=true
        log_success "Backstage Backend está funcionando (puerto 7007)"
    else
        sleep 2
        ATTEMPTS=$((ATTEMPTS + 1))
        echo -n "."
    fi
done

if [ $BACKSTAGE_READY = false ]; then
    log_error "Backstage no pudo iniciarse después de $MAX_ATTEMPTS intentos"
    log_info "Revisa los logs en applications/backstage/backstage-production.log"
    exit 1
fi

# Verificar frontend
sleep 5
if curl -s -I http://localhost:3002 > /dev/null 2>&1; then
    log_success "Backstage Frontend está funcionando (puerto 3002)"
else
    log_warning "Backstage Frontend puede no estar completamente listo"
fi

# 4. Mostrar resumen de servicios
echo ""
echo "🎉 IA-Ops Platform iniciada exitosamente!"
echo "========================================"
echo ""
echo "📊 Servicios Activos:"
echo "  🏛️  Backstage Frontend: http://localhost:3002"
echo "  🔧 Backstage Backend:  http://localhost:7007"
echo "  🤖 OpenAI Service:     http://localhost:8003"
echo "  💾 PostgreSQL:         localhost:5432"
echo "  🔄 Redis:              localhost:6379"
echo ""
echo "📋 Comandos Útiles:"
echo "  • Ver logs de Backstage:    tail -f applications/backstage/backstage-production.log"
echo "  • Ver servicios Docker:     docker-compose ps"
echo "  • Parar servicios Docker:   docker-compose down"
echo "  • Parar Backstage:          cd applications/backstage && ./kill-ports.sh"
echo ""
echo "🔍 Verificar Estado:"
echo "  • Puertos activos:          netstat -tlnp | grep -E ':(3002|7007|5432|6379|8003)'"
echo "  • API de Backstage:         curl http://localhost:7007/api/catalog/health"
echo ""

# 5. Opcional: Iniciar servicios adicionales
read -p "¿Deseas iniciar servicios adicionales (Grafana, Prometheus, MkDocs)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Iniciando servicios adicionales..."
    docker-compose up -d grafana prometheus mkdocs node-exporter cadvisor
    
    echo ""
    echo "📊 Servicios Adicionales:"
    echo "  📈 Grafana:            http://localhost:3001 (admin/admin123)"
    echo "  📊 Prometheus:         http://localhost:9090"
    echo "  📚 MkDocs:             http://localhost:8005"
    echo "  🖥️  Node Exporter:      http://localhost:9100"
    echo "  📦 cAdvisor:           http://localhost:8082"
fi

echo ""
log_success "¡IA-Ops Platform está lista para usar!"
echo ""
