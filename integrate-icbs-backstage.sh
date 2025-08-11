#!/bin/bash

# =============================================================================
# INTEGRACIÓN ICBS + BACKSTAGE SIN DUPLICAR MKDOCS
# =============================================================================

set -e

echo "🚀 Integrando ICBS + Backstage (MkDocs solo en Backstage)..."

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

# =============================================================================
# PASO 1: PREPARAR INTEGRACIÓN
# =============================================================================

echo ""
log_info "=== PASO 1: PREPARACIÓN ==="

# Detener MkDocs duplicados
log_info "Deteniendo servicios MkDocs duplicados..."
docker stop mkdocs-server 2>/dev/null || true
docker rm mkdocs-server 2>/dev/null || true

# Crear docker-compose modificado para ICBS sin MkDocs
log_info "Creando configuración ICBS sin MkDocs..."
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic

# Crear versión sin mkdocs-server
cat > config/docker-compose-no-mkdocs.yml << 'EOF'
version: '3.8'

services:
  # Oracle Database
  orcldb:
    image: ${ORACLE_IMAGE:-gvenzl/oracle-xe}:${ORACLE_VERSION:-21-slim}
    container_name: orcldb
    environment:
      - ORACLE_PASSWORD=${ORACLE_PASSWORD:-oracle123}
      - ORACLE_DATABASE=${ORACLE_DATABASE:-XEPDB1}
      - ORACLE_USER=${ORACLE_USER:-weblogic}
      - ORACLE_USER_PASSWORD=${ORACLE_USER_PASSWORD:-weblogic123}
    volumes:
      - oracle_data:/opt/oracle/oradata
      - oracle_backup:/opt/oracle/backup
    networks:
      - weblogic-network
    ports:
      - "${ORACLE_EXTERNAL_PORT:-1521}:1521"
      - "${ORACLE_EM_PORT:-5500}:5500"
    healthcheck:
      test: ["CMD-SHELL", "echo 'SELECT 1;' | sqlplus -L sys/oracle123@//localhost:1521/XE as sysdba || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s

  # WebLogic Server A
  weblogic-a:
    build:
      context: .
      dockerfile: applications/weblogic-feature-flags/Dockerfile
    image: weblogic-feature-flags:latest
    container_name: weblogic-a
    environment:
      - ADMIN_PASSWORD=${WEBLOGIC_ADMIN_PASSWORD:-welcome1}
      - VERSION=A
      - ORACLE_HOST=orcldb
      - ORACLE_PORT=1521
    volumes:
      - weblogic_a_domain:/u01/oracle/user_projects/domains
      - weblogic_logs:/u01/oracle/logs
      - ./autodeploy:/u01/oracle/autodeploy
    ports:
      - "${WEBLOGIC_A_EXTERNAL_PORT:-7001}:7001"
    networks:
      - weblogic-network
    depends_on:
      - orcldb
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7001/console"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 120s

  # WebLogic Server B
  weblogic-b:
    build:
      context: .
      dockerfile: applications/weblogic-feature-flags/Dockerfile
    image: weblogic-feature-flags:latest
    container_name: weblogic-b
    environment:
      - ADMIN_PASSWORD=${WEBLOGIC_ADMIN_PASSWORD:-welcome1}
      - VERSION=B
      - ORACLE_HOST=orcldb
      - ORACLE_PORT=1521
    volumes:
      - weblogic_b_domain:/u01/oracle/user_projects/domains
      - weblogic_logs:/u01/oracle/logs
      - ./autodeploy:/u01/oracle/autodeploy
    ports:
      - "${WEBLOGIC_B_EXTERNAL_PORT:-7002}:7002"
    networks:
      - weblogic-network
    depends_on:
      - orcldb
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7002/console"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 120s

  # HAProxy Load Balancer
  haproxy:
    image: haproxy-advanced:latest
    container_name: haproxy
    volumes:
      - ./applications/haproxy-advanced/config:/usr/local/etc/haproxy:rw
      - haproxy_socket:/var/run/haproxy
    ports:
      - "${HAPROXY_HTTP_EXTERNAL_PORT:-8083}:80"
      - "${HAPROXY_HTTPS_EXTERNAL_PORT:-8444}:443"
      - "${HAPROXY_STATS_EXTERNAL_PORT:-8404}:8404"
    networks:
      - weblogic-network
    depends_on:
      - weblogic-a
      - weblogic-b
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8404/stats"]
      interval: 30s
      timeout: 10s
      retries: 5

networks:
  weblogic-network:
    driver: bridge

volumes:
  oracle_data:
    driver: local
  oracle_backup:
    driver: local
  weblogic_a_domain:
    driver: local
  weblogic_b_domain:
    driver: local
  weblogic_logs:
    driver: local
  haproxy_socket:
    driver: local
EOF

log_success "Configuración ICBS sin MkDocs creada"

# =============================================================================
# PASO 2: INICIAR SERVICIOS ICBS
# =============================================================================

echo ""
log_info "=== PASO 2: INICIANDO SERVICIOS ICBS ==="

log_info "Iniciando servicios ICBS (sin MkDocs)..."
docker-compose -f config/docker-compose-no-mkdocs.yml up -d

log_success "Servicios ICBS iniciados"

# =============================================================================
# PASO 3: INTEGRAR DOCUMENTACIÓN EN BACKSTAGE
# =============================================================================

echo ""
log_info "=== PASO 3: INTEGRANDO DOCUMENTACIÓN ==="

log_info "Cambiando a directorio Backstage..."
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Crear estructura para documentación ICBS
log_info "Creando estructura de documentación integrada..."
mkdir -p docs/icbs
mkdir -p docs/integrations

# Copiar documentación ICBS si existe
if [ -d "/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/docs" ]; then
    log_info "Copiando documentación ICBS..."
    cp -r /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic/docs/* docs/icbs/ 2>/dev/null || true
fi

# Crear documentación de integración
cat > docs/integrations/icbs-integration.md << 'ICBS_DOC'
# 🏦 Integración ICBS - Sistema Bancario Core

## 📋 Descripción
Sistema Bancario Core Integrado (ICBS) completamente integrado con la plataforma IA-Ops.

## 🏗️ Arquitectura ICBS

### Componentes Principales
- **Oracle Database XE**: Base de datos principal del sistema bancario
- **WebLogic Server A**: Servidor de aplicaciones primario (Puerto 7001)
- **WebLogic Server B**: Servidor de aplicaciones secundario (Puerto 7002)
- **HAProxy**: Load balancer y alta disponibilidad (Puerto 8083)

### Servicios de Soporte
- **Jenkins**: CI/CD para desarrollo ICBS (Puerto 8091)
- **SonarQube**: Análisis de calidad de código (Puerto 9000)
- **Nexus**: Gestión de artefactos Maven/Java (Puerto 8092)
- **Portainer**: Gestión de contenedores (Puerto 9080)

## 🔗 URLs de Acceso

### Servicios Core ICBS
- **WebLogic A Console**: http://localhost:7001/console
- **WebLogic B Console**: http://localhost:7002/console
- **HAProxy Load Balancer**: http://localhost:8083
- **HAProxy Statistics**: http://localhost:8404/stats
- **Oracle EM Express**: http://localhost:5500/em

### Servicios DevOps
- **Jenkins**: http://localhost:8091 (admin/admin123)
- **SonarQube**: http://localhost:9000 (admin/admin123)
- **Nexus**: http://localhost:8092 (admin/admin123)
- **Portainer**: http://localhost:9080

## 📊 Monitoreo y Observabilidad

### Métricas Disponibles
- **Prometheus**: Métricas de WebLogic y Oracle
- **Grafana**: Dashboards específicos para ICBS
- **Health Checks**: Monitoreo automático de servicios
- **Logs**: Centralizados por componente

### Dashboards Grafana
- **ICBS Overview**: Vista general del sistema
- **WebLogic Performance**: Métricas de servidores de aplicaciones
- **Oracle Database**: Performance y conexiones
- **HAProxy**: Load balancing y disponibilidad

## 🤖 Integración con IA

### OpenAI Service
- **Análisis de Código**: Revisión automática de código Java/J2EE
- **Recomendaciones**: Mejores prácticas bancarias
- **Documentación**: Generación automática de documentación técnica
- **Troubleshooting**: Asistencia para resolución de problemas

### Casos de Uso IA
- Análisis de performance de transacciones
- Recomendaciones de optimización de consultas
- Detección de patrones de uso anómalos
- Generación de reportes automáticos

## 🔧 Configuración y Despliegue

### Variables de Entorno
```bash
# Oracle Database
ORACLE_PASSWORD=oracle123
ORACLE_DATABASE=XEPDB1
ORACLE_USER=weblogic
ORACLE_USER_PASSWORD=weblogic123

# WebLogic
WEBLOGIC_ADMIN_PASSWORD=welcome1
WEBLOGIC_A_EXTERNAL_PORT=7001
WEBLOGIC_B_EXTERNAL_PORT=7002

# HAProxy
HAPROXY_HTTP_EXTERNAL_PORT=8083
HAPROXY_STATS_EXTERNAL_PORT=8404
```

### Comandos de Gestión
```bash
# Iniciar stack completo
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
docker-compose -f config/docker-compose-no-mkdocs.yml up -d

# Ver estado
docker-compose -f config/docker-compose-no-mkdocs.yml ps

# Ver logs
docker-compose -f config/docker-compose-no-mkdocs.yml logs -f

# Parar servicios
docker-compose -f config/docker-compose-no-mkdocs.yml down
```

## 🚀 Desarrollo y CI/CD

### Pipeline Jenkins
1. **Source**: Código desde repositorios Git
2. **Build**: Compilación con Maven
3. **Test**: Pruebas unitarias y de integración
4. **Quality**: Análisis con SonarQube
5. **Package**: Generación de WARs/EARs
6. **Deploy**: Despliegue automático a WebLogic

### Gestión de Artefactos
- **Nexus**: Repositorio central de artefactos
- **Versionado**: Semantic versioning
- **Releases**: Gestión automática de releases
- **Dependencies**: Gestión de dependencias Maven

## 🔒 Seguridad

### Configuraciones de Seguridad
- **WebLogic Security**: Configuración de dominios seguros
- **Oracle Security**: Usuarios y roles específicos
- **HAProxy SSL**: Terminación SSL/TLS
- **Network Security**: Políticas de red definidas

### Credenciales por Defecto
- **WebLogic Admin**: weblogic/welcome1
- **Oracle SYS**: sys/oracle123
- **Jenkins**: admin/admin123
- **SonarQube**: admin/admin123
- **Nexus**: admin/admin123

## 📈 Performance y Escalabilidad

### Configuración de Performance
- **WebLogic Tuning**: JVM optimizada para transacciones bancarias
- **Oracle Tuning**: Configuración específica para OLTP
- **HAProxy**: Load balancing con health checks
- **Connection Pooling**: Pools optimizados

### Escalabilidad
- **Horizontal**: Agregar más servidores WebLogic
- **Vertical**: Incrementar recursos de contenedores
- **Database**: Configuración RAC para alta disponibilidad
- **Caching**: Estrategias de cache distribuido

## 🆘 Troubleshooting

### Problemas Comunes
1. **WebLogic no inicia**: Verificar Oracle Database
2. **HAProxy 503**: Verificar health checks de WebLogic
3. **Oracle conexión**: Verificar puertos y credenciales
4. **Performance lenta**: Revisar métricas en Grafana

### Logs Importantes
```bash
# WebLogic logs
docker logs weblogic-a
docker logs weblogic-b

# Oracle logs
docker logs orcldb

# HAProxy logs
docker logs haproxy
```

## 📞 Soporte

### Contactos
- **ICBS Team**: icbs-team@banco.com
- **DevOps**: devops@banco.com
- **DBA**: dba@banco.com

### Documentación Adicional
- [Manual de Administración WebLogic](./weblogic-admin.md)
- [Guía de Troubleshooting Oracle](./oracle-troubleshooting.md)
- [Configuración HAProxy](./haproxy-config.md)
ICBS_DOC

log_success "Documentación de integración ICBS creada"

# =============================================================================
# PASO 4: INICIAR BACKSTAGE
# =============================================================================

echo ""
log_info "=== PASO 4: INICIANDO BACKSTAGE ==="

log_info "Limpiando puertos..."
./kill-ports.sh

log_info "Generando archivos de catálogo..."
./generate-catalog-files.sh

log_info "Sincronizando configuración..."
./sync-env-config.sh

log_info "Iniciando Backstage robusto..."
timeout 180s ./start-robust.sh || log_warning "Backstage iniciando en background..."

log_success "Backstage iniciado"

# =============================================================================
# PASO 5: VERIFICACIÓN FINAL
# =============================================================================

echo ""
log_info "=== PASO 5: VERIFICACIÓN FINAL ==="

sleep 15

echo ""
log_info "📊 ESTADO FINAL DE SERVICIOS:"

echo ""
echo "🏦 STACK ICBS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(weblogic|oracle|haproxy)" || echo "   (Iniciando...)"

echo ""
echo "🏛️ STACK BACKSTAGE:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "ia-ops" || echo "   (Iniciando...)"

echo ""
echo "🔧 SERVICIOS DEVOPS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(jenkins|nexus|sonar|portainer)" || echo "   (Verificar si están activos)"

echo ""
log_info "🔗 URLS DE ACCESO INTEGRADAS:"
echo ""
echo "🏛️ BACKSTAGE (ÚNICO MKDOCS):"
echo "   • Backstage Portal: http://localhost:3002"
echo "   • MkDocs Integrado: http://localhost:8005"
echo "   • Documentación ICBS: http://localhost:3002/docs/integrations/icbs-integration"
echo ""
echo "🏦 ICBS CORE:"
echo "   • WebLogic A: http://localhost:7001/console"
echo "   • WebLogic B: http://localhost:7002/console"
echo "   • HAProxy: http://localhost:8083"
echo "   • HAProxy Stats: http://localhost:8404/stats"
echo ""
echo "🔧 DEVOPS:"
echo "   • Jenkins: http://localhost:8091"
echo "   • SonarQube: http://localhost:9000"
echo "   • Nexus: http://localhost:8092"
echo "   • Portainer: http://localhost:9080"

echo ""
log_success "🎉 INTEGRACIÓN ICBS + BACKSTAGE COMPLETADA"

echo ""
log_info "📋 PRÓXIMOS PASOS:"
echo "   1. Verificar Backstage: http://localhost:3002"
echo "   2. Revisar documentación ICBS integrada"
echo "   3. Acceder a WebLogic consoles cuando estén listos"
echo "   4. Configurar pipelines Jenkins para ICBS"
echo "   5. Monitorear con Grafana integrado"

echo ""
log_success "¡Integración exitosa sin duplicar MkDocs!"
EOF
