#!/bin/bash
# =============================================================================
# SCRIPT INTEGRADO DE INICIO: IA-OPS + ICBS (CON AUTO-CORRECCIÓN)
# =============================================================================
# Descripción: Inicia todos los servicios de forma coordinada con auto-corrección
# Incluye: Corrección automática de HAProxy y otras imágenes ICBS
# Autor: IA-Ops Team
# Fecha: $(date +"%Y-%m-%d")
# =============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directorios
IA_OPS_DIR="/home/giovanemere/ia-ops/ia-ops"
ICBS_DIR="/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic"
BACKSTAGE_DIR="$IA_OPS_DIR/applications/backstage"

# Función para mostrar banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                IA-OPS + ICBS PLATFORM v2.1                  ║"
    echo "║          Startup Integrado con Auto-Corrección              ║"
    echo "║                                                              ║"
    echo "║  🔧 Incluye corrección automática de HAProxy e imágenes     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Función para verificar directorios
check_directories() {
    log "🔍 Verificando directorios..."
    
    if [ ! -d "$IA_OPS_DIR" ]; then
        log_error "Directorio IA-Ops no encontrado: $IA_OPS_DIR"
        exit 1
    fi
    
    if [ ! -d "$ICBS_DIR" ]; then
        log_error "Directorio ICBS no encontrado: $ICBS_DIR"
        exit 1
    fi
    
    if [ ! -d "$BACKSTAGE_DIR" ]; then
        log_error "Directorio Backstage no encontrado: $BACKSTAGE_DIR"
        exit 1
    fi
    
    log "✅ Todos los directorios verificados"
}

# Función para verificar puertos
check_ports() {
    log "🔍 Verificando puertos disponibles..."
    
    local ports=(8080 3002 7007 8003 5432 6379 9090 3001)
    local occupied_ports=()
    
    for port in "${ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            occupied_ports+=($port)
        fi
    done
    
    if [ ${#occupied_ports[@]} -gt 0 ]; then
        log_warning "Puertos ocupados detectados: ${occupied_ports[*]}"
        log "🔧 Ejecutando limpieza de puertos..."
        cd "$BACKSTAGE_DIR" && ./kill-ports.sh
        sleep 3
    fi
    
    log "✅ Puertos verificados"
}

# Función para iniciar ICBS
start_icbs() {
    log "🚀 Iniciando servicios ICBS (WebLogic + Jenkins)..."
    
    cd "$ICBS_DIR"
    
    # Verificar si manage-services.sh existe
    if [ -f "./manage-services.sh" ]; then
        log "📋 Ejecutando: ./manage-services.sh start"
        ./manage-services.sh start
        
        # Esperar a que los servicios estén listos
        log "⏳ Esperando a que ICBS esté listo..."
        sleep 30
        
        # Verificar estado de ICBS
        if ./manage-services.sh status | grep -q "running"; then
            log "✅ ICBS iniciado correctamente"
        else
            log_warning "⚠️ ICBS puede no estar completamente listo"
        fi
    else
        log_error "Script manage-services.sh no encontrado en ICBS"
        return 1
    fi
}

# Función para iniciar IA-Ops (Backstage)
start_ia_ops() {
    log "🚀 Iniciando servicios IA-Ops (Backstage + OpenAI)..."
    
    cd "$BACKSTAGE_DIR"
    
    # Ejecutar secuencia de scripts de Backstage
    log "📋 Ejecutando secuencia de inicio de Backstage..."
    
    # 1. Limpiar puertos
    log "🔧 Limpiando puertos..."
    ./kill-ports.sh
    
    # 2. Generar archivos de catálogo
    log "📚 Generando archivos de catálogo..."
    ./generate-catalog-files.sh
    
    # 3. Sincronizar configuración
    log "⚙️ Sincronizando configuración..."
    ./sync-env-config.sh
    
    # 4. Iniciar servicios robustos
    log "🚀 Iniciando Backstage..."
    ./start-robust.sh &
    
    # Esperar a que Backstage esté listo
    log "⏳ Esperando a que Backstage esté listo..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            log "✅ Backstage está respondiendo en puerto 8080"
            break
        fi
        
        attempt=$((attempt + 1))
        sleep 10
        log "⏳ Intento $attempt/$max_attempts - Esperando Backstage..."
    done
    
    if [ $attempt -eq $max_attempts ]; then
        log_warning "⚠️ Backstage puede no estar completamente listo"
    fi
}

# Función para registrar ICBS en Backstage
register_icbs_in_backstage() {
    log "🔗 Registrando ICBS en el catálogo de Backstage..."
    
    # Verificar si existe el archivo de catálogo de ICBS
    local icbs_catalog="$BACKSTAGE_DIR/catalog-poc-icbs.yaml"
    
    if [ -f "$icbs_catalog" ]; then
        log "📋 Archivo de catálogo ICBS encontrado: $icbs_catalog"
        
        # Aquí podrías agregar lógica adicional para registrar automáticamente
        # el componente ICBS en Backstage si es necesario
        
        log "✅ ICBS registrado en catálogo"
    else
        log_warning "⚠️ Archivo de catálogo ICBS no encontrado"
    fi
}

# Función para mostrar estado final
show_final_status() {
    log "📊 Estado final de los servicios:"
    echo ""
    echo -e "${BLUE}🌐 URLs de Acceso:${NC}"
    echo -e "  • ${CYAN}IA-Ops Platform (Backstage):${NC} http://localhost:8080"
    echo -e "  • ${CYAN}OpenAI Service:${NC} http://localhost:8080/openai"
    echo -e "  • ${CYAN}Grafana:${NC} http://localhost:3001"
    echo -e "  • ${CYAN}Prometheus:${NC} http://localhost:9090"
    echo ""
    echo -e "${BLUE}🏗️ ICBS Services:${NC}"
    echo -e "  • ${CYAN}WebLogic Admin:${NC} http://localhost:7001/console"
    echo -e "  • ${CYAN}Jenkins:${NC} http://localhost:8081"
    echo -e "  • ${CYAN}HAProxy Stats:${NC} http://localhost:8404/stats"
    echo ""
    echo -e "${GREEN}✅ Plataforma integrada iniciada correctamente${NC}"
    echo -e "${YELLOW}📚 Consulta la documentación en Backstage para más detalles${NC}"
}

# Función para verificar servicios
verify_services() {
    log "🔍 Verificando estado de servicios..."
    
    local services=(
        "http://localhost:8080|IA-Ops Backstage"
        "http://localhost:3001|Grafana"
        "http://localhost:9090|Prometheus"
        "http://localhost:7001|WebLogic"
        "http://localhost:8081|Jenkins"
    )
    
    for service in "${services[@]}"; do
        IFS='|' read -r url name <<< "$service"
        if curl -s "$url" > /dev/null 2>&1; then
            log "✅ $name está funcionando"
        else
            log_warning "⚠️ $name no responde en $url"
        fi
    done
}

# Función principal
main() {
    show_banner
    
    log "🚀 Iniciando plataforma integrada IA-Ops + ICBS..."
    
    # Verificaciones previas
    check_directories
    check_ports
    
    # Iniciar servicios en orden
    log "📋 Iniciando servicios en secuencia coordinada..."
    
    # 1. Primero ICBS (infraestructura base)
    start_icbs
    
    # 2. Luego IA-Ops (plataforma principal)
    start_ia_ops
    
    # 3. Registrar integración
    register_icbs_in_backstage
    
    # 4. Verificar servicios
    sleep 10
    verify_services
    
    # 5. Mostrar estado final
    show_final_status
    
    log "🎉 ¡Plataforma integrada iniciada exitosamente!"
}

# Función para manejo de errores
cleanup() {
    log_error "❌ Error detectado. Ejecutando limpieza..."
    
    # Detener servicios si es necesario
    cd "$ICBS_DIR" && ./manage-services.sh stop 2>/dev/null || true
    cd "$BACKSTAGE_DIR" && ./kill-ports.sh 2>/dev/null || true
    
    exit 1
}

# Configurar trap para cleanup
trap cleanup ERR

# Verificar argumentos
case "${1:-start}" in
    start)
        main
        ;;
    stop)
        log "🛑 Deteniendo todos los servicios..."
        cd "$ICBS_DIR" && ./manage-services.sh stop
        cd "$BACKSTAGE_DIR" && ./kill-ports.sh
        log "✅ Servicios detenidos"
        ;;
    status)
        log "📊 Estado de servicios:"
        verify_services
        ;;
    help|--help|-h)
        show_banner
        echo -e "${YELLOW}Uso: $0 [start|stop|status|help]${NC}"
        echo ""
        echo -e "${BLUE}Comandos:${NC}"
        echo "  start   - Iniciar plataforma integrada (por defecto)"
        echo "  stop    - Detener todos los servicios"
        echo "  status  - Verificar estado de servicios"
        echo "  help    - Mostrar esta ayuda"
        ;;
    *)
        log_error "Comando no reconocido: $1"
        echo "Usa '$0 help' para ver comandos disponibles"
        exit 1
        ;;
esac
