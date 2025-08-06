#!/bin/bash

# =============================================================================
# CLEAN RESTART - IA-OPS PLATFORM
# =============================================================================
# Descripción: Script para limpiar completamente y reiniciar el sistema
# Autor: DevOps Team

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "=== LIMPIEZA COMPLETA Y REINICIO ==="
echo ""

# Detener todos los servicios
log_info "Deteniendo todos los servicios..."
docker-compose down -v --remove-orphans 2>/dev/null || true

# Limpiar imágenes relacionadas
log_info "Limpiando imágenes Docker..."
docker images | grep -E "(ia-ops|backstage)" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

# Limpiar contenedores huérfanos
log_info "Limpiando contenedores huérfanos..."
docker container prune -f 2>/dev/null || true

# Limpiar volúmenes huérfanos
log_info "Limpiando volúmenes huérfanos..."
docker volume prune -f 2>/dev/null || true

# Limpiar redes huérfanas
log_info "Limpiando redes huérfanas..."
docker network prune -f 2>/dev/null || true

# Limpiar logs locales
log_info "Limpiando logs locales..."
rm -rf logs/* 2>/dev/null || true
mkdir -p logs

log_success "Limpieza completada"
echo ""

# Reconstruir y iniciar servicios básicos primero
log_info "Iniciando servicios de base de datos..."
docker-compose up -d postgres redis

# Esperar a que estén listos
log_info "Esperando a que PostgreSQL esté listo..."
for i in {1..30}; do
    if docker-compose exec -T postgres pg_isready -U postgres -d backstage 2>/dev/null; then
        log_success "PostgreSQL está listo"
        break
    fi
    sleep 2
    if [[ $i -eq 30 ]]; then
        log_error "Timeout esperando a PostgreSQL"
        exit 1
    fi
done

log_info "Esperando a que Redis esté listo..."
for i in {1..15}; do
    if docker-compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        log_success "Redis está listo"
        break
    fi
    sleep 2
    if [[ $i -eq 15 ]]; then
        log_error "Timeout esperando a Redis"
        exit 1
    fi
done

# Construir e iniciar OpenAI Service
log_info "Construyendo e iniciando OpenAI Service..."
docker-compose build openai-service
docker-compose up -d openai-service

# Esperar a que OpenAI Service esté listo
log_info "Esperando a que OpenAI Service esté listo..."
for i in {1..20}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        log_success "OpenAI Service está listo"
        break
    fi
    sleep 3
    if [[ $i -eq 20 ]]; then
        log_warning "OpenAI Service no responde, continuando..."
        break
    fi
done

# Construir e iniciar Proxy Service
log_info "Construyendo e iniciando Proxy Service..."
docker-compose build proxy-service
docker-compose up -d proxy-service

# Esperar a que Proxy Service esté listo
log_info "Esperando a que Proxy Service esté listo..."
for i in {1..20}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        log_success "Proxy Service está listo"
        break
    fi
    sleep 3
    if [[ $i -eq 20 ]]; then
        log_warning "Proxy Service no responde, continuando..."
        break
    fi
done

log_success "¡Sistema limpiado y servicios básicos iniciados!"
echo ""

log_info "=== ESTADO ACTUAL ==="
docker-compose ps
echo ""

log_info "=== PRÓXIMOS PASOS ==="
echo "1. Para iniciar Backstage con la configuración real:"
echo "   ./scripts/setup-backstage-complete.sh"
echo ""
echo "2. Para verificar el estado:"
echo "   docker-compose ps"
echo "   curl http://localhost:8080/health"
echo ""

log_success "Limpieza y reinicio completados"
