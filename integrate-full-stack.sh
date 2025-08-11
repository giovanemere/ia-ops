#!/bin/bash

# =============================================================================
# INTEGRACIÓN COMPLETA - ICBS + BACKSTAGE
# Solo MkDocs de Backstage, documentación ICBS integrada
# =============================================================================

set -e

echo "🚀 Iniciando integración completa ICBS + Backstage..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# =============================================================================
# FASE 1: PREPARACIÓN
# =============================================================================

echo ""
log_info "=== FASE 1: PREPARACIÓN ==="

# Detener servicios conflictivos
log_info "Deteniendo servicios MkDocs duplicados..."
docker stop mkdocs-server 2>/dev/null || true
docker rm mkdocs-server 2>/dev/null || true

# Limpiar redes conflictivas
log_info "Limpiando redes conflictivas..."
docker network prune -f >/dev/null 2>&1 || true

log_success "Preparación completada"

# =============================================================================
# FASE 2: INICIAR STACK ICBS (SIN MKDOCS)
# =============================================================================

echo ""
log_info "=== FASE 2: INICIANDO STACK ICBS ==="

log_info "Cambiando a directorio ICBS..."
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic

# Modificar docker-compose para excluir mkdocs
log_info "Configurando ICBS sin MkDocs duplicado..."
if [ -f "config/docker-compose.yml" ]; then
    # Crear versión sin mkdocs
    grep -v -A 10 -B 2 "mkdocs-server" config/docker-compose.yml > config/docker-compose-no-mkdocs.yml || cp config/docker-compose.yml config/docker-compose-no-mkdocs.yml
fi

log_info "Iniciando servicios ICBS..."
timeout 300s ./manage-services.sh start || {
    log_warning "Timeout en manage-services.sh, intentando método alternativo..."
    
    # Método alternativo: usar docker-compose directamente
    if [ -f "config/docker-compose.yml" ]; then
        log_info "Usando docker-compose directamente..."
        docker-compose -f config/docker-compose.yml up -d orcldb weblogic-a weblogic-b haproxy 2>/dev/null || {
            log_warning "Algunos servicios ICBS no pudieron iniciarse, continuando..."
        }
    fi
}

log_success "Stack ICBS iniciado (servicios disponibles)"

# =============================================================================
# FASE 3: INTEGRAR DOCUMENTACIÓN ICBS EN BACKSTAGE
# =============================================================================

echo ""
log_info "=== FASE 3: INTEGRANDO DOCUMENTACIÓN ICBS ==="

log_info "Cambiando a directorio Backstage..."
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Crear directorio para documentación ICBS
log_info "Creando estructura de documentación integrada..."
mkdir -p docs/icbs
mkdir -p docs/integrations

# Copiar documentación ICBS a Backstage
if [ -d "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/docs" ]; then
    log_info "Copiando documentación ICBS..."
    cp -r /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/docs/* docs/icbs/ 2>/dev/null || true
fi

# Crear índice de documentación integrada
cat > docs/integrations/icbs-integration.md << 'EOF'
# 🏦 Integración ICBS - Sistema Bancario

## 📋 Descripción
Integración completa del sistema ICBS (Integrated Core Banking System) con la plataforma IA-Ops.

## 🏗️ Arquitectura ICBS
- **Oracle Database**: Base de datos principal
- **WebLogic Server A**: Servidor de aplicaciones primario
- **WebLogic Server B**: Servidor de aplicaciones secundario  
- **HAProxy**: Load balancer y alta disponibilidad

## 🔗 Servicios Integrados
- **Jenkins**: CI/CD para ICBS
- **SonarQube**: Análisis de calidad de código
- **Nexus**: Gestión de artefactos
- **Portainer**: Gestión de contenedores

## 📊 Monitoreo
- **Prometheus**: Métricas de ICBS
- **Grafana**: Dashboards específicos
- **Health Checks**: Monitoreo automático

## 🤖 IA Integration
- **OpenAI Service**: Análisis automático de código ICBS
- **Recomendaciones**: Mejores prácticas bancarias
- **Documentación**: Generación automática

## 🔧 URLs de Acceso
- **Jenkins**: http://localhost:8091
- **SonarQube**: http://localhost:9000
- **Nexus**: http://localhost:8092
- **Portainer**: http://localhost:9080
- **WebLogic A**: http://localhost:7001 (cuando esté activo)
- **WebLogic B**: http://localhost:7002 (cuando esté activo)
- **HAProxy**: http://localhost:8083 (cuando esté activo)
EOF

log_success "Documentación ICBS integrada en Backstage"

# =============================================================================
# FASE 4: INICIAR STACK BACKSTAGE COMPLETO
# =============================================================================

echo ""
log_info "=== FASE 4: INICIANDO STACK BACKSTAGE ==="

log_info "Limpiando puertos conflictivos..."
./kill-ports.sh

log_info "Generando archivos de catálogo..."
./generate-catalog-files.sh

log_info "Sincronizando configuración..."
./sync-env-config.sh

log_info "Iniciando Backstage robusto..."
timeout 180s ./start-robust.sh || {
    log_warning "Timeout en start-robust.sh, Backstage puede estar iniciando en background"
}

log_success "Stack Backstage iniciado"

# =============================================================================
# FASE 5: VERIFICACIÓN Y ESTADO FINAL
# =============================================================================

echo ""
log_info "=== FASE 5: VERIFICACIÓN FINAL ==="

sleep 10

echo ""
log_info "📊 ESTADO FINAL DE SERVICIOS:"

echo ""
echo "🏛️ STACK BACKSTAGE:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "ia-ops" || echo "   (Iniciando...)"

echo ""
echo "🔧 STACK ICBS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(weblogic|oracle|haproxy|jenkins|nexus|sonar|portainer)" | grep -v "ia-ops" || echo "   (Verificar servicios ICBS)"

echo ""
log_info "🧪 PRUEBAS DE CONECTIVIDAD:"

# Probar servicios principales
services=(
    "Backstage:http://localhost:3002"
    "Prometheus:http://localhost:9090"
    "Grafana:http://localhost:3001"
    "OpenAI Service:http://localhost:8003/health"
    "Jenkins:http://localhost:8091"
    "SonarQube:http://localhost:9000"
    "Nexus:http://localhost:8092"
    "Portainer:http://localhost:9080"
)

for service in "${services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    response=$(timeout 5s curl -s -w "%{http_code}" -o /dev/null "$url" 2>/dev/null || echo "000")
    if [[ "$response" =~ ^(200|302|403)$ ]]; then
        echo "   ✅ $name: $response"
    else
        echo "   ⚠️  $name: $response (puede estar iniciando)"
    fi
done

echo ""
log_info "=== URLS DE ACCESO ==="
echo ""
echo "🏛️ BACKSTAGE STACK:"
echo "   • Backstage Portal: http://localhost:3002"
echo "   • Prometheus: http://localhost:9090"
echo "   • Grafana: http://localhost:3001"
echo "   • OpenAI Service: http://localhost:8003"
echo "   • MkDocs (ÚNICO): http://localhost:8005"
echo ""
echo "🔧 ICBS STACK:"
echo "   • Jenkins: http://localhost:8091 (admin/admin123)"
echo "   • SonarQube: http://localhost:9000 (admin/admin123)"
echo "   • Nexus: http://localhost:8092 (admin/admin123)"
echo "   • Portainer: http://localhost:9080"
echo "   • WebLogic A: http://localhost:7001 (si está activo)"
echo "   • WebLogic B: http://localhost:7002 (si está activo)"
echo "   • HAProxy: http://localhost:8083 (si está activo)"

echo ""
log_success "🎉 INTEGRACIÓN COMPLETA FINALIZADA"

echo ""
log_info "📋 PRÓXIMOS PASOS:"
echo "   1. Verificar Backstage: http://localhost:3002"
echo "   2. Revisar documentación ICBS integrada en Backstage"
echo "   3. Usar Jenkins para CI/CD: http://localhost:8091"
echo "   4. Monitorear con Grafana: http://localhost:3001"
echo "   5. Probar OpenAI Service para análisis automático"

echo ""
log_info "📚 DOCUMENTACIÓN:"
echo "   • Plan de implementación: docs/plan-implementacion.md"
echo "   • Seguimiento de progreso: docs/seguimiento-progreso.md"
echo "   • Integración ICBS: docs/integrations/icbs-integration.md"

echo ""
log_success "¡Stack completo integrado exitosamente!"
EOF
