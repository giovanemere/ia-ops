#!/bin/bash

# =============================================================================
# SETUP BACKSTAGE COMPLETE - IA-OPS PLATFORM
# =============================================================================
# Descripción: Script para configurar Backstage completamente
# Autor: DevOps Team
# Fecha: $(date)

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
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

# Función para verificar prerrequisitos
check_prerequisites() {
    log_info "Verificando prerrequisitos..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose no está instalado"
        exit 1
    fi
    
    # Verificar archivo .env
    if [[ ! -f ".env" ]]; then
        log_error "Archivo .env no encontrado"
        exit 1
    fi
    
    log_success "Prerrequisitos verificados"
}

# Función para configurar base de datos
setup_database() {
    log_info "Configurando base de datos PostgreSQL..."
    
    # Iniciar PostgreSQL si no está corriendo
    if ! docker-compose ps postgres | grep -q "Up"; then
        log_info "Iniciando PostgreSQL..."
        docker-compose up -d postgres
        sleep 10
    fi
    
    # Verificar conexión a la base de datos
    if docker-compose exec -T postgres pg_isready -U postgres -d backstage; then
        log_success "Base de datos PostgreSQL configurada correctamente"
    else
        log_error "Error al conectar con PostgreSQL"
        exit 1
    fi
}

# Función para configurar Redis
setup_redis() {
    log_info "Configurando Redis..."
    
    # Iniciar Redis si no está corriendo
    if ! docker-compose ps redis | grep -q "Up"; then
        log_info "Iniciando Redis..."
        docker-compose up -d redis
        sleep 5
    fi
    
    # Verificar conexión a Redis con autenticación
    if docker-compose exec -T redis redis-cli -a redis123 ping 2>/dev/null | grep -q "PONG"; then
        log_success "Redis configurado correctamente"
    else
        log_error "Error al conectar con Redis"
        exit 1
    fi
}

# Función para construir imágenes de Backstage
build_backstage_images() {
    log_info "Construyendo imágenes de Backstage..."
    
    # Construir imagen del backend
    log_info "Construyendo Backstage Backend..."
    docker-compose build backstage-backend
    
    # Construir imagen del frontend
    log_info "Construyendo Backstage Frontend..."
    docker-compose build backstage-frontend
    
    log_success "Imágenes de Backstage construidas"
}

# Función para iniciar servicios de Backstage
start_backstage_services() {
    log_info "Iniciando servicios de Backstage..."
    
    # Iniciar backend
    log_info "Iniciando Backstage Backend..."
    docker-compose up -d backstage-backend
    
    # Esperar a que el backend esté listo
    log_info "Esperando a que el backend esté listo..."
    for i in {1..30}; do
        if curl -s http://localhost:7007/health > /dev/null 2>&1; then
            log_success "Backstage Backend está listo"
            break
        fi
        sleep 2
        if [[ $i -eq 30 ]]; then
            log_error "Timeout esperando al backend"
            exit 1
        fi
    done
    
    # Iniciar frontend
    log_info "Iniciando Backstage Frontend..."
    docker-compose up -d backstage-frontend
    
    # Esperar a que el frontend esté listo
    log_info "Esperando a que el frontend esté listo..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            log_success "Backstage Frontend está listo"
            break
        fi
        sleep 2
        if [[ $i -eq 30 ]]; then
            log_error "Timeout esperando al frontend"
            exit 1
        fi
    done
}

# Función para verificar configuración
verify_configuration() {
    log_info "Verificando configuración de Backstage..."
    
    # Verificar health check del backend
    if curl -s http://localhost:7007/health | grep -q "healthy"; then
        log_success "Backend health check OK"
    else
        log_error "Backend health check falló"
        return 1
    fi
    
    # Verificar API del catálogo
    if curl -s http://localhost:7007/api/catalog/entities > /dev/null; then
        log_success "Catalog API OK"
    else
        log_error "Catalog API falló"
        return 1
    fi
    
    # Verificar frontend
    if curl -s http://localhost:3000 > /dev/null; then
        log_success "Frontend OK"
    else
        log_error "Frontend falló"
        return 1
    fi
    
    log_success "Configuración verificada correctamente"
}

# Función para mostrar información de acceso
show_access_info() {
    log_info "=== INFORMACIÓN DE ACCESO ==="
    echo ""
    echo "🌐 URLs de Acceso:"
    echo "  • Portal Principal (via Proxy): http://localhost:8080"
    echo "  • Backstage Frontend: http://localhost:3000"
    echo "  • Backstage Backend: http://localhost:7007"
    echo "  • Health Check: http://localhost:7007/health"
    echo "  • Catalog API: http://localhost:7007/api/catalog/entities"
    echo ""
    echo "📊 Monitoreo:"
    echo "  • Prometheus: http://localhost:9090"
    echo "  • Grafana: http://localhost:3001"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "  • Ver logs: docker-compose logs -f backstage-frontend backstage-backend"
    echo "  • Reiniciar: docker-compose restart backstage-frontend backstage-backend"
    echo "  • Estado: docker-compose ps"
    echo ""
}

# Función principal
main() {
    log_info "=== CONFIGURACIÓN COMPLETA DE BACKSTAGE ==="
    echo ""
    
    check_prerequisites
    setup_database
    setup_redis
    build_backstage_images
    start_backstage_services
    
    if verify_configuration; then
        log_success "¡Backstage configurado exitosamente!"
        show_access_info
    else
        log_error "Error en la configuración de Backstage"
        exit 1
    fi
}

# Ejecutar función principal
main "$@"
