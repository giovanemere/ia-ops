#!/bin/bash

echo "🔍 VERIFICACIÓN DE PLUGINS SEGÚN PLAN DE IMPLEMENTACIÓN"
echo "======================================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}PLUGINS DEFINIDOS EN EL PLAN DE IMPLEMENTACIÓN${NC}"
echo "----------------------------------------------"
echo ""

# Plugins según el plan
declare -A plan_plugins=(
    ["OpenAI Plugin"]="✅ 100% Completado - Chat IA nativo"
    ["MkDocs Plugin"]="🔄 70% En Progreso - Pipeline automático pendiente"
    ["GitHub Plugin"]="⏳ Pendiente - Integración con repositorios"
    ["Azure Plugin"]="⏳ Pendiente - Azure DevOps integration"
    ["Tech Radar Plugin"]="✅ 100% Completado - Radar interactivo"
    ["Cost Insight Plugin"]="✅ 100% Completado - Dashboards de costos"
)

echo -e "${YELLOW}Estado según el plan:${NC}"
for plugin in "${!plan_plugins[@]}"; do
    echo "  $plugin: ${plan_plugins[$plugin]}"
done

echo ""
echo -e "${BLUE}VERIFICANDO PLUGINS INSTALADOS EN BACKSTAGE${NC}"
echo "-------------------------------------------"

# Verificar plugins en package.json del frontend
echo ""
echo -e "${YELLOW}1. Plugins en Frontend (packages/app/package.json):${NC}"

frontend_plugins=(
    "@backstage/plugin-api-docs"
    "@backstage/plugin-azure-devops"
    "@backstage/plugin-catalog"
    "@backstage/plugin-catalog-graph"
    "@backstage/plugin-catalog-import"
    "@backstage/plugin-cost-insights"
    "@backstage/plugin-github-actions"
    "@backstage/plugin-kubernetes"
    "@backstage/plugin-org"
    "@backstage/plugin-scaffolder"
    "@backstage/plugin-search"
    "@backstage/plugin-tech-radar"
    "@backstage/plugin-techdocs"
    "@backstage/plugin-user-settings"
)

for plugin in "${frontend_plugins[@]}"; do
    if grep -q "$plugin" "packages/app/package.json"; then
        echo -e "  ${GREEN}✅ $plugin${NC}"
    else
        echo -e "  ${RED}❌ $plugin${NC}"
    fi
done

# Verificar plugins en package.json del backend
echo ""
echo -e "${YELLOW}2. Plugins en Backend (packages/backend/package.json):${NC}"

backend_plugins=(
    "@backstage/plugin-app-backend"
    "@backstage/plugin-auth-backend"
    "@backstage/plugin-auth-backend-module-github-provider"
    "@backstage/plugin-auth-backend-module-guest-provider"
    "@backstage/plugin-catalog-backend"
    "@backstage/plugin-kubernetes-backend"
    "@backstage/plugin-permission-backend"
    "@backstage/plugin-proxy-backend"
    "@backstage/plugin-scaffolder-backend"
    "@backstage/plugin-scaffolder-backend-module-github"
    "@backstage/plugin-search-backend"
    "@backstage/plugin-techdocs-backend"
)

for plugin in "${backend_plugins[@]}"; do
    if grep -q "$plugin" "packages/backend/package.json"; then
        echo -e "  ${GREEN}✅ $plugin${NC}"
    else
        echo -e "  ${RED}❌ $plugin${NC}"
    fi
done

# Verificar plugins configurados en el código
echo ""
echo -e "${YELLOW}3. Plugins Configurados en Código:${NC}"

# Frontend App.tsx
echo ""
echo -e "${BLUE}Frontend (App.tsx):${NC}"
frontend_imports=(
    "plugin-api-docs"
    "plugin-catalog"
    "plugin-catalog-import"
    "plugin-scaffolder"
    "plugin-org"
    "plugin-search"
    "plugin-techdocs"
    "plugin-user-settings"
    "plugin-tech-radar"
    "plugin-cost-insights"
    "plugin-catalog-graph"
)

for plugin in "${frontend_imports[@]}"; do
    if grep -q "$plugin" "packages/app/src/App.tsx"; then
        echo -e "  ${GREEN}✅ $plugin importado${NC}"
    else
        echo -e "  ${RED}❌ $plugin no importado${NC}"
    fi
done

# Backend index.ts
echo ""
echo -e "${BLUE}Backend (index.ts):${NC}"
backend_imports=(
    "plugin-app-backend"
    "plugin-proxy-backend"
    "plugin-scaffolder-backend"
    "plugin-techdocs-backend"
    "plugin-auth-backend"
    "plugin-catalog-backend"
    "plugin-permission-backend"
    "plugin-search-backend"
    "plugin-kubernetes-backend"
)

for plugin in "${backend_imports[@]}"; do
    if grep -q "$plugin" "packages/backend/src/index.ts"; then
        echo -e "  ${GREEN}✅ $plugin configurado${NC}"
    else
        echo -e "  ${RED}❌ $plugin no configurado${NC}"
    fi
done

echo ""
echo -e "${BLUE}ANÁLISIS DE DISCREPANCIAS${NC}"
echo "------------------------"

echo ""
echo -e "${YELLOW}Plugins del plan NO implementados:${NC}"

# OpenAI Plugin
if ! grep -q "openai" "packages/app/package.json" && ! grep -q "openai" "packages/backend/package.json"; then
    echo -e "  ${RED}❌ OpenAI Plugin - Según plan: 100% completado${NC}"
    echo -e "     ${YELLOW}Acción: Instalar plugin OpenAI personalizado${NC}"
fi

# GitHub Plugin específico
if ! grep -q "plugin-github-actions" "packages/app/src/App.tsx"; then
    echo -e "  ${RED}❌ GitHub Actions Plugin - No configurado en frontend${NC}"
    echo -e "     ${YELLOW}Acción: Configurar GitHub Actions en App.tsx${NC}"
fi

# Azure Plugin
if grep -q "plugin-azure-devops" "packages/app/package.json"; then
    if ! grep -q "plugin-azure-devops" "packages/app/src/App.tsx"; then
        echo -e "  ${YELLOW}⚠️  Azure DevOps Plugin - Instalado pero no configurado${NC}"
        echo -e "     ${YELLOW}Acción: Configurar Azure DevOps en App.tsx${NC}"
    fi
else
    echo -e "  ${RED}❌ Azure DevOps Plugin - No instalado${NC}"
    echo -e "     ${YELLOW}Acción: Instalar y configurar Azure DevOps plugin${NC}"
fi

# MkDocs/TechDocs
if grep -q "plugin-techdocs" "packages/app/package.json"; then
    echo -e "  ${GREEN}✅ TechDocs Plugin - Instalado (equivale a MkDocs del plan)${NC}"
else
    echo -e "  ${RED}❌ TechDocs Plugin - No encontrado${NC}"
fi

echo ""
echo -e "${YELLOW}Plugins instalados NO mencionados en el plan:${NC}"

extra_plugins=(
    "plugin-kubernetes"
    "plugin-org"
    "plugin-user-settings"
    "plugin-catalog-graph"
    "plugin-catalog-import"
    "plugin-api-docs"
)

for plugin in "${extra_plugins[@]}"; do
    if grep -q "$plugin" "packages/app/package.json"; then
        echo -e "  ${GREEN}✅ $plugin - Instalado (no en plan original)${NC}"
    fi
done

echo ""
echo -e "${BLUE}RECOMENDACIONES PARA ALINEAR CON EL PLAN${NC}"
echo "--------------------------------------"

echo ""
echo -e "${YELLOW}1. Plugins Faltantes Críticos:${NC}"
echo "   • OpenAI Plugin personalizado - Desarrollar e instalar"
echo "   • GitHub Actions Plugin - Configurar en frontend"
echo "   • Azure DevOps Plugin - Configurar completamente"
echo ""

echo -e "${YELLOW}2. Configuraciones Pendientes:${NC}"
echo "   • MkDocs pipeline automático (70% completado según plan)"
echo "   • GitHub integration con repositorios BillPay/ICBS"
echo "   • Azure DevOps pipelines integration"
echo ""

echo -e "${YELLOW}3. Aplicaciones para Integrar:${NC}"
echo "   • https://github.com/giovanemere/poc-billpay-back"
echo "   • https://github.com/giovanemere/poc-billpay-front-a.git"
echo "   • https://github.com/giovanemere/poc-billpay-front-b.git"
echo "   • https://github.com/giovanemere/poc-billpay-front-feature-flags.git"
echo "   • https://github.com/giovanemere/poc-icbs.git"
echo ""

echo -e "${YELLOW}4. Próximos Pasos Inmediatos:${NC}"
echo "   1. Instalar y configurar GitHub Actions plugin"
echo "   2. Configurar Azure DevOps plugin existente"
echo "   3. Desarrollar OpenAI plugin personalizado"
echo "   4. Completar pipeline automático MkDocs"
echo "   5. Catalogar aplicaciones BillPay e ICBS"

echo ""
echo -e "${GREEN}✅ VERIFICACIÓN COMPLETADA${NC}"
echo "========================="
echo ""
echo "Para instalar plugins faltantes:"
echo "  cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "  yarn workspace app add @backstage/plugin-github-actions"
echo "  # Luego configurar en App.tsx"
