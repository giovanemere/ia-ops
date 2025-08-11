#!/bin/bash

# =============================================================================
# SCRIPT PARA INSTALAR COST INSIGHTS PLUGIN
# =============================================================================
# Descripción: Instala y configura el plugin Cost Insights en Backstage
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

echo "💰 Instalando Cost Insights plugin para Backstage..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
if [ ! -f "package.json" ]; then
    log_error "No se encontró package.json. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo ""
log_info "=== INSTALANDO DEPENDENCIAS ==="

# Instalar el plugin Cost Insights
log_info "Instalando @backstage/plugin-cost-insights..."
yarn workspace app add @backstage/plugin-cost-insights

# Instalar dependencias del backend si es necesario
log_info "Instalando dependencias del backend..."
yarn workspace backend add @backstage/plugin-cost-insights-backend

log_success "Dependencias instaladas"

echo ""
log_info "=== CONFIGURANDO FRONTEND ==="

# Backup del App.tsx actual
if [ -f "packages/app/src/App.tsx" ]; then
    cp packages/app/src/App.tsx packages/app/src/App.tsx.backup.$(date +%Y%m%d_%H%M%S)
    log_info "Backup creado de App.tsx"
fi

# Agregar import y ruta al App.tsx
log_info "Configurando App.tsx..."

cat > packages/app/src/App.tsx << 'EOF'
import React from 'react';
import { Navigate, Route } from 'react-router-dom';
import { apiDocsPlugin, ApiExplorerPage } from '@backstage/plugin-api-docs';
import {
  CatalogEntityPage,
  CatalogIndexPage,
  catalogPlugin,
} from '@backstage/plugin-catalog';
import {
  CatalogImportPage,
  catalogImportPlugin,
} from '@backstage/plugin-catalog-import';
import { ScaffolderPage, scaffolderPlugin } from '@backstage/plugin-scaffolder';
import { orgPlugin } from '@backstage/plugin-org';
import { SearchPage } from '@backstage/plugin-search';
import { TechRadarPage } from '@backstage/plugin-tech-radar';
import {
  TechDocsIndexPage,
  techdocsPlugin,
  TechDocsReaderPage,
} from '@backstage/plugin-techdocs';
import { TechDocsAddons } from '@backstage/plugin-techdocs-react';
import { ReportIssue } from '@backstage/plugin-techdocs-module-addons-contrib';
import { UserSettingsPage } from '@backstage/plugin-user-settings';
import { apis } from './apis';
import { entityPage } from './components/catalog/EntityPage';
import { searchPage } from './components/search/SearchPage';
import { Root } from './components/Root';

import { AlertDisplay, OAuthRequestDialog } from '@backstage/core-components';
import { createApp } from '@backstage/app-defaults';
import { AppRouter, FlatRoutes } from '@backstage/core-app-api';
import { CatalogGraphPage } from '@backstage/plugin-catalog-graph';
import { RequirePermission } from '@backstage/plugin-permission-react';
import { catalogEntityReadPermission } from '@backstage/plugin-catalog-common/alpha';

// Cost Insights Plugin
import { CostInsightsPage } from '@backstage/plugin-cost-insights';

const app = createApp({
  apis,
  bindRoutes({ bind }) {
    bind(catalogPlugin.externalRoutes, {
      createComponent: scaffolderPlugin.routes.root,
      viewTechDoc: techdocsPlugin.routes.docRoot,
      createFromTemplate: scaffolderPlugin.routes.selectedTemplate,
    });
    bind(apiDocsPlugin.externalRoutes, {
      registerApi: catalogImportPlugin.routes.importPage,
    });
    bind(scaffolderPlugin.externalRoutes, {
      registerComponent: catalogImportPlugin.routes.importPage,
      viewTechDoc: techdocsPlugin.routes.docRoot,
    });
    bind(orgPlugin.externalRoutes, {
      catalogIndex: catalogPlugin.routes.catalogIndex,
    });
  },
});

const routes = (
  <FlatRoutes>
    <Route path="/" element={<Navigate to="catalog" />} />
    <Route path="/catalog" element={<CatalogIndexPage />} />
    <Route
      path="/catalog/:namespace/:kind/:name"
      element={<CatalogEntityPage />}
    >
      {entityPage}
    </Route>
    <Route path="/docs" element={<TechDocsIndexPage />} />
    <Route
      path="/docs/:namespace/:kind/:name/*"
      element={<TechDocsReaderPage />}
    >
      <TechDocsAddons>
        <ReportIssue />
      </TechDocsAddons>
    </Route>
    <Route path="/create" element={<ScaffolderPage />} />
    <Route path="/api-docs" element={<ApiExplorerPage />} />
    <Route
      path="/tech-radar"
      element={<RequirePermission permission={catalogEntityReadPermission}>
        <TechRadarPage />
      </RequirePermission>}
    />
    <Route path="/catalog-import" element={<CatalogImportPage />} />
    <Route path="/search" element={<SearchPage />}>
      {searchPage}
    </Route>
    <Route path="/settings" element={<UserSettingsPage />} />
    <Route
      path="/catalog-graph"
      element={
        <RequirePermission permission={catalogEntityReadPermission}>
          <CatalogGraphPage />
        </RequirePermission>
      }
    />
    {/* Cost Insights Route */}
    <Route path="/cost-insights" element={<CostInsightsPage />} />
  </FlatRoutes>
);

export default app.createRoot(
  <>
    <AlertDisplay />
    <OAuthRequestDialog />
    <AppRouter>
      <Root>{routes}</Root>
    </AppRouter>
  </>,
);
EOF

log_success "App.tsx configurado con Cost Insights"

echo ""
log_info "=== CONFIGURANDO SIDEBAR ==="

# Configurar el sidebar para incluir Cost Insights
if [ -f "packages/app/src/components/Root/Root.tsx" ]; then
    cp packages/app/src/components/Root/Root.tsx packages/app/src/components/Root/Root.tsx.backup.$(date +%Y%m%d_%H%M%S)
    log_info "Backup creado de Root.tsx"
    
    # Agregar el item al sidebar
    log_info "Agregando Cost Insights al sidebar..."
    
    # Crear un parche para el sidebar
    cat > /tmp/sidebar_patch.txt << 'EOF'
import MoneyIcon from '@material-ui/icons/MoneyOff';

// Agregar después de los otros SidebarItem:
<SidebarItem icon={MoneyIcon} to="cost-insights" text="Cost Insights" />
EOF
    
    log_warning "Necesitas agregar manualmente el item al sidebar en Root.tsx:"
    cat /tmp/sidebar_patch.txt
fi

echo ""
log_info "=== CONFIGURANDO BACKEND ==="

# Configurar el backend
if [ -f "packages/backend/src/index.ts" ]; then
    cp packages/backend/src/index.ts packages/backend/src/index.ts.backup.$(date +%Y%m%d_%H%M%S)
    log_info "Backup creado de backend index.ts"
    
    log_info "Agregando Cost Insights backend..."
    
    # Crear el archivo del plugin backend
    mkdir -p packages/backend/src/plugins
    
    cat > packages/backend/src/plugins/cost-insights.ts << 'EOF'
import { createRouter } from '@backstage/plugin-cost-insights-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';

export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  return await createRouter({
    logger: env.logger,
    config: env.config,
  });
}
EOF

    log_success "Plugin backend creado"
fi

echo ""
log_info "=== CONFIGURANDO APP-CONFIG ==="

# Agregar configuración básica al app-config.yaml
log_info "Agregando configuración de Cost Insights..."

cat >> app-config.yaml << 'EOF'

# Cost Insights Configuration
costInsights:
  engineerCost: 200000 # Annual engineer cost in cents
  products:
    computeEngine:
      name: Compute Engine
      icon: compute
    cloudDataflow:
      name: Cloud Dataflow  
      icon: data
    cloudStorage:
      name: Cloud Storage
      icon: storage
    bigQuery:
      name: BigQuery
      icon: search
  metrics:
    - name: 'Daily Cost'
      default: true
    - name: 'Monthly Cost'
    - name: 'Quarterly Cost'
  currencies:
    - label: 'USD ($)'
      unit: 'USD'
EOF

log_success "Configuración agregada a app-config.yaml"

echo ""
log_info "=== INSTALANDO DEPENDENCIAS FINALES ==="

# Instalar todas las dependencias
yarn install

log_success "Dependencias instaladas"

echo ""
log_info "=== RESUMEN DE INSTALACIÓN ==="

echo "📊 Cost Insights plugin instalado exitosamente!"
echo ""
echo "🔧 Configuración completada:"
echo "   ✅ Plugin instalado en frontend y backend"
echo "   ✅ Ruta /cost-insights configurada"
echo "   ✅ Configuración básica agregada"
echo ""
echo "🚀 Próximos pasos:"
echo "1. Reiniciar Backstage: yarn start"
echo "2. Acceder a: http://localhost:3002/cost-insights"
echo "3. Configurar proveedores de costos específicos"
echo ""
echo "⚠️  Nota: Necesitas configurar un proveedor de datos de costos"
echo "   para que el plugin muestre información real."

log_success "¡Instalación completada!"
EOF
