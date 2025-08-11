#!/bin/bash

# =============================================================================
# CONFIGURACIÓN SIMPLE DE COST INSIGHTS
# =============================================================================

set -e

echo "💰 Configurando Cost Insights de forma simple..."

# Verificar si estamos en el directorio correcto
if [ ! -f "app-config.yaml" ]; then
    echo "❌ No se encontró app-config.yaml. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo "📝 Agregando configuración de Cost Insights..."

# Agregar configuración básica
cat >> app-config.yaml << 'EOF'

# =============================================================================
# COST INSIGHTS CONFIGURATION
# =============================================================================
costInsights:
  engineerCost: 200000 # Annual engineer cost in cents ($2000)
  
  # Productos/servicios para tracking de costos
  products:
    aws:
      name: AWS Services
      icon: cloud
    azure:
      name: Azure Services  
      icon: cloud
    gcp:
      name: GCP Services
      icon: cloud
    kubernetes:
      name: Kubernetes
      icon: compute
    
  # Métricas disponibles
  metrics:
    - name: 'Daily Cost'
      default: true
    - name: 'Weekly Cost'
    - name: 'Monthly Cost'
    - name: 'Quarterly Cost'
    
  # Monedas soportadas
  currencies:
    - label: 'USD ($)'
      unit: 'USD'
    - label: 'EUR (€)'
      unit: 'EUR'
      
  # Configuración de alertas
  alerts:
    - name: 'High Daily Cost'
      threshold: 1000 # $10 in cents
    - name: 'Monthly Budget'
      threshold: 50000 # $500 in cents

# Configuración del plugin en el catálogo
catalog:
  rules:
    - allow: [Component, System, API, Resource, Location, Template, Domain, Group]
  
  # Agregar Cost Insights como recurso
  locations:
    - type: file
      target: ./cost-insights-entities.yaml

EOF

echo "✅ Configuración agregada a app-config.yaml"

# Crear entidades de ejemplo para Cost Insights
echo "📊 Creando entidades de ejemplo..."

cat > cost-insights-entities.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: aws-cost-tracking
  description: Seguimiento de costos AWS
  tags:
    - cost
    - aws
    - monitoring
spec:
  type: cost-tracker
  owner: platform-team
  system: ia-ops-platform
links:
  - url: https://console.aws.amazon.com/billing/
    title: AWS Billing Console
    icon: cloud
  - url: https://console.aws.amazon.com/cost-management/
    title: AWS Cost Explorer
    icon: dashboard

---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: azure-cost-tracking
  description: Seguimiento de costos Azure
  tags:
    - cost
    - azure
    - monitoring
spec:
  type: cost-tracker
  owner: platform-team
  system: ia-ops-platform
links:
  - url: https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/overview
    title: Azure Cost Management
    icon: cloud
  - url: https://portal.azure.com/#blade/Microsoft_Azure_Billing/BillingMenuBlade/Overview
    title: Azure Billing
    icon: dashboard

---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: gcp-cost-tracking
  description: Seguimiento de costos GCP
  tags:
    - cost
    - gcp
    - monitoring
spec:
  type: cost-tracker
  owner: platform-team
  system: ia-ops-platform
links:
  - url: https://console.cloud.google.com/billing
    title: GCP Billing Console
    icon: cloud
  - url: https://console.cloud.google.com/billing/reports
    title: GCP Cost Reports
    icon: dashboard

---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: cost-insights-dashboard
  description: Dashboard de insights de costos para IA-Ops Platform
  tags:
    - cost
    - dashboard
    - monitoring
    - insights
spec:
  type: dashboard
  lifecycle: production
  owner: platform-team
  system: ia-ops-platform
  dependsOn:
    - resource:aws-cost-tracking
    - resource:azure-cost-tracking
    - resource:gcp-cost-tracking
links:
  - url: http://localhost:3002/cost-insights
    title: Cost Insights Dashboard
    icon: dashboard
  - url: http://localhost:3001/d/cost-overview
    title: Grafana Cost Overview
    icon: grafana
  - url: http://localhost:9090/targets?search=cost
    title: Cost Metrics
    icon: dashboard
EOF

echo "✅ Entidades de Cost Insights creadas"

# Crear página de placeholder si el plugin no está instalado
echo "🔧 Creando página de placeholder..."

mkdir -p packages/app/src/components/CostInsights

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
      <Header title="Cost Insights" subtitle="Monitoreo y análisis de costos de infraestructura">
        <MoneyOffIcon />
      </Header>
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="🚧 Cost Insights en Desarrollo">
              <Typography variant="body1" paragraph>
                El plugin de Cost Insights está siendo configurado para la plataforma IA-Ops.
                Esta funcionalidad permitirá monitorear y analizar los costos de infraestructura
                en tiempo real.
              </Typography>
              
              <Box mt={2} mb={2}>
                <Typography variant="h6" gutterBottom>
                  📊 Funcionalidades Planificadas:
                </Typography>
                <ul>
                  <li>Seguimiento de costos por proveedor cloud (AWS, Azure, GCP, OCI)</li>
                  <li>Análisis de tendencias de gasto</li>
                  <li>Alertas de presupuesto</li>
                  <li>Comparación de costos por proyecto</li>
                  <li>Recomendaciones de optimización</li>
                </ul>
              </Box>

              <Box mt={3}>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://console.aws.amazon.com/billing/"
                  target="_blank"
                  style={{ marginRight: 8 }}
                >
                  AWS Billing
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/overview"
                  target="_blank"
                  style={{ marginRight: 8 }}
                >
                  Azure Cost Management
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<TrendingUpIcon />}
                  href="http://localhost:3001"
                  target="_blank"
                >
                  Grafana Dashboards
                </Button>
              </Box>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="AWS Costs">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="Azure Costs">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="GCP Costs">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12}>
            <InfoCard title="📈 Próximos Pasos">
              <Typography variant="body1" paragraph>
                Para habilitar el monitoreo completo de costos:
              </Typography>
              <ol>
                <li>Configurar APIs de billing de cada proveedor cloud</li>
                <li>Instalar el plugin oficial de Cost Insights</li>
                <li>Configurar métricas en Prometheus</li>
                <li>Crear dashboards en Grafana</li>
              </ol>
              
              <Box mt={2}>
                <Link to="/catalog?filters%5Bkind%5D=resource&filters%5Btype%5D=cost-tracker">
                  Ver recursos de seguimiento de costos →
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

echo "✅ Componente placeholder creado"

echo ""
echo "🎯 Configuración completada!"
echo ""
echo "📊 Cost Insights configurado con:"
echo "   ✅ Configuración básica en app-config.yaml"
echo "   ✅ Entidades de seguimiento de costos"
echo "   ✅ Página placeholder funcional"
echo ""
echo "🚀 Para acceder:"
echo "   1. Reinicia Backstage si está corriendo"
echo "   2. Ve a: http://localhost:3002/cost-insights"
echo "   3. O busca 'cost' en el catálogo"
echo ""
echo "💡 Nota: Esta es una configuración básica. Para funcionalidad completa,"
echo "   instala el plugin oficial con: ./install-cost-insights.sh"
EOF
