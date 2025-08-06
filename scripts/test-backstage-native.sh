#!/bin/bash

# =============================================================================
# TEST BACKSTAGE NATIVO - IA-OPS PLATFORM
# =============================================================================
# Descripción: Script para probar Backstage nativo paso a paso

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

# Navegar al directorio de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

log_info "=== PRUEBA DE BACKSTAGE NATIVO ==="
echo ""

# Cargar variables de entorno
log_info "Cargando variables de entorno..."
source ../../.env
log_success "Variables de entorno cargadas"

# Verificar variables críticas
log_info "Verificando variables críticas..."
echo "POSTGRES_HOST: ${POSTGRES_HOST:-NOT_SET}"
echo "POSTGRES_USER: ${POSTGRES_USER:-NOT_SET}"
echo "BACKEND_SECRET: ${BACKEND_SECRET:0:10}..."
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}..."

# Verificar que PostgreSQL esté disponible
log_info "Verificando conexión a PostgreSQL..."
if docker-compose -f ../../docker-compose.yml exec -T postgres pg_isready -U postgres -d backstage 2>/dev/null; then
    log_success "PostgreSQL está disponible"
else
    log_error "PostgreSQL no está disponible"
    exit 1
fi

# Verificar que Redis esté disponible
log_info "Verificando conexión a Redis..."
if docker-compose -f ../../docker-compose.yml exec -T redis redis-cli -a redis123 ping 2>/dev/null | grep -q "PONG"; then
    log_success "Redis está disponible"
else
    log_error "Redis no está disponible"
    exit 1
fi

# Verificar que las dependencias estén instaladas
log_info "Verificando dependencias..."
if [[ -d "node_modules" ]]; then
    log_success "Dependencias instaladas"
else
    log_warning "Instalando dependencias..."
    yarn install
fi

# Intentar construir el backend
log_info "Construyendo backend..."
if yarn build:backend; then
    log_success "Backend construido exitosamente"
else
    log_error "Error al construir backend"
    exit 1
fi

# Intentar iniciar el backend en modo desarrollo
log_info "Iniciando backend en modo desarrollo..."
log_info "Esto puede tomar varios minutos..."

# Crear un archivo de configuración temporal más simple
cat > app-config.test.yaml << EOF
app:
  title: IA-Ops Platform Test
  baseUrl: http://localhost:3000

organization:
  name: IA-Ops Organization

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  database:
    client: better-sqlite3
    connection: ':memory:'

catalog:
  locations:
    - type: file
      target: ./examples/entities.yaml
    - type: file
      target: ./examples/org.yaml

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
EOF

log_info "Usando configuración simplificada para prueba..."

# Usar el comando correcto para iniciar solo el backend
yarn workspace backend start --config app-config.test.yaml &

BACKEND_PID=$!
log_info "Backend iniciado con PID: $BACKEND_PID"

# Esperar a que el backend esté listo
log_info "Esperando a que el backend esté listo..."
for i in {1..60}; do
    if curl -s http://localhost:7007/health > /dev/null 2>&1; then
        log_success "¡Backend está funcionando!"
        curl -s http://localhost:7007/health | jq . || curl -s http://localhost:7007/health
        break
    fi
    sleep 2
    if [[ $i -eq 60 ]]; then
        log_error "Timeout esperando al backend"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    echo -n "."
done

echo ""
log_success "¡Backstage nativo está funcionando correctamente!"
echo ""
log_info "URLs disponibles:"
echo "  • Backend: http://localhost:7007"
echo "  • Health: http://localhost:7007/health"
echo "  • Catalog: http://localhost:7007/api/catalog/entities"
echo ""
log_info "Para detener el backend: kill $BACKEND_PID"
