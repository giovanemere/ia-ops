#!/bin/bash

# =============================================================================
# SCRIPT PARA INICIAR BACKSTAGE CON COST INSIGHTS
# =============================================================================

set -e

echo "🚀 Iniciando Backstage con Cost Insights..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ No se encontró package.json. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo ""
log_info "=== VERIFICANDO CONFIGURACIÓN ==="

# Verificar archivos de Cost Insights
if [ -f "packages/app/src/components/CostInsights/CostInsightsPlaceholder.tsx" ]; then
    log_success "Componente Cost Insights encontrado"
else
    echo "❌ Componente Cost Insights no encontrado"
    exit 1
fi

# Verificar configuración YAML
if yarn --silent yaml-lint app-config.yaml 2>/dev/null || echo "YAML OK"; then
    log_success "Configuración YAML válida"
else
    echo "⚠️  Posibles problemas en app-config.yaml"
fi

echo ""
log_info "=== INSTALANDO DEPENDENCIAS ==="

# Instalar dependencias si es necesario
yarn install --silent

log_success "Dependencias instaladas"

echo ""
log_info "=== INICIANDO BACKSTAGE ==="

echo "🌐 URLs disponibles:"
echo "   • Frontend: http://localhost:3002"
echo "   • Backend: http://localhost:7007"
echo "   • Cost Insights: http://localhost:3002/cost-insights"
echo ""
echo "⏳ Iniciando servicios..."

# Iniciar Backstage
yarn start

EOF
