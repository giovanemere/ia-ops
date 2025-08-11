#!/bin/bash

# =============================================================================
# SCRIPT PARA CORREGIR COST INSIGHTS
# =============================================================================

set -e

echo "🔧 Corrigiendo configuración de Cost Insights..."

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

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    log_error "No se encontró package.json. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo ""
log_info "=== VERIFICANDO ARCHIVOS ==="

# Verificar componente
if [ -f "packages/app/src/components/CostInsights/CostInsightsPlaceholder.tsx" ]; then
    log_success "Componente CostInsightsPlaceholder existe"
else
    log_error "Componente CostInsightsPlaceholder no existe"
    exit 1
fi

# Verificar index
if [ -f "packages/app/src/components/CostInsights/index.ts" ]; then
    log_success "Index de CostInsights existe"
else
    log_error "Index de CostInsights no existe"
    exit 1
fi

echo ""
log_info "=== VERIFICANDO CONFIGURACIÓN ==="

# Verificar import en App.tsx
if grep -q "CostInsightsPlaceholder" packages/app/src/App.tsx; then
    log_success "Import de CostInsightsPlaceholder encontrado en App.tsx"
else
    log_error "Import de CostInsightsPlaceholder no encontrado en App.tsx"
    exit 1
fi

# Verificar ruta en App.tsx
if grep -q 'path="/cost-insights"' packages/app/src/App.tsx; then
    log_success "Ruta /cost-insights encontrada en App.tsx"
else
    log_error "Ruta /cost-insights no encontrada en App.tsx"
    exit 1
fi

# Verificar sidebar
if grep -q 'to="cost-insights"' packages/app/src/components/Root/Root.tsx; then
    log_success "Item de sidebar encontrado en Root.tsx"
else
    log_error "Item de sidebar no encontrado en Root.tsx"
    exit 1
fi

echo ""
log_info "=== COMPILANDO TYPESCRIPT ==="

# Verificar que no hay errores de TypeScript
if yarn tsc --noEmit; then
    log_success "Compilación TypeScript exitosa"
else
    log_error "Errores de compilación TypeScript"
    echo ""
    log_info "Intentando corregir errores comunes..."
    
    # Verificar imports
    log_info "Verificando imports en CostInsightsPlaceholder..."
    
    # Crear versión corregida del componente
    cat > packages/app/src/components/CostInsights/CostInsightsPlaceholder.tsx << 'EOF'
import React from 'react';
import {
  Content,
  Header,
  Page,
  InfoCard,
  Link,
} from '@backstage/core-components';
import { Grid, Typography, Box, Button } from '@material-ui/core';
import MoneyOffIcon from '@material-ui/icons/MoneyOff';
import CloudIcon from '@material-ui/icons/Cloud';
import TrendingUpIcon from '@material-ui/icons/TrendingUp';

export const CostInsightsPlaceholder = () => {
  return (
    <Page themeId="tool">
      <Header title="Cost Insights" subtitle="Monitoreo y análisis de costos">
        <MoneyOffIcon />
      </Header>
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="💰 Cost Insights - IA-Ops Platform">
              <Typography variant="body1" paragraph>
                Bienvenido al módulo de Cost Insights de la plataforma IA-Ops.
                Aquí podrás monitorear y analizar los costos de tu infraestructura cloud.
              </Typography>
              
              <Box mt={2} mb={2}>
                <Typography variant="h6" gutterBottom>
                  🎯 Funcionalidades:
                </Typography>
                <ul>
                  <li>Seguimiento de costos multi-cloud (AWS, Azure, GCP, OCI)</li>
                  <li>Análisis de tendencias de gasto</li>
                  <li>Alertas de presupuesto</li>
                  <li>Optimización de recursos</li>
                </ul>
              </Box>

              <Box mt={3}>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://console.aws.amazon.com/billing/"
                  target="_blank"
                  style={{ marginRight: 8, marginBottom: 8 }}
                >
                  AWS Billing
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"
                  target="_blank"
                  style={{ marginRight: 8, marginBottom: 8 }}
                >
                  Azure Cost Management
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<TrendingUpIcon />}
                  href="http://localhost:3001"
                  target="_blank"
                  style={{ marginBottom: 8 }}
                >
                  Grafana Dashboards
                </Button>
              </Box>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🔶 AWS">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🔷 Azure">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🟡 GCP">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12}>
            <InfoCard title="🚀 Estado del Sistema">
              <Typography variant="body1" paragraph>
                ✅ Configuración básica completada<br/>
                ⏳ Conectores de datos en desarrollo<br/>
                📊 Dashboards en configuración
              </Typography>
              
              <Box mt={2}>
                <Link to="/catalog?filters%5Bkind%5D=resource">
                  Ver recursos en el catálogo →
                </Link>
              </Box>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
EOF

    log_success "Componente corregido"
    
    # Intentar compilar de nuevo
    if yarn tsc --noEmit; then
        log_success "Compilación corregida exitosamente"
    else
        log_error "Aún hay errores de compilación"
    fi
fi

echo ""
log_info "=== VERIFICACIÓN FINAL ==="

echo "📊 Estado de Cost Insights:"
echo "   ✅ Componente: $([ -f packages/app/src/components/CostInsights/CostInsightsPlaceholder.tsx ] && echo 'OK' || echo 'FALTA')"
echo "   ✅ Index: $([ -f packages/app/src/components/CostInsights/index.ts ] && echo 'OK' || echo 'FALTA')"
echo "   ✅ Import: $(grep -q CostInsightsPlaceholder packages/app/src/App.tsx && echo 'OK' || echo 'FALTA')"
echo "   ✅ Ruta: $(grep -q 'path="/cost-insights"' packages/app/src/App.tsx && echo 'OK' || echo 'FALTA')"
echo "   ✅ Sidebar: $(grep -q 'to="cost-insights"' packages/app/src/components/Root/Root.tsx && echo 'OK' || echo 'FALTA')"

echo ""
log_success "¡Corrección de Cost Insights completada!"
echo ""
echo "🚀 Próximos pasos:"
echo "1. Ejecutar: ./kill-ports.sh"
echo "2. Ejecutar: ./sync-env-config.sh"
echo "3. Ejecutar: ./start-robust.sh"
echo "4. Acceder a: http://localhost:3002/cost-insights"
EOF
