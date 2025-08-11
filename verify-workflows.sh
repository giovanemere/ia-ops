#!/bin/bash

# 🔍 Script de Verificación de GitHub Actions Workflows
# Este script verifica que todos los workflows y configuraciones estén correctamente aplicados

set -e

echo "🚀 Verificando GitHub Actions Workflows..."
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Función para verificar archivos
check_file() {
    local file_path="$1"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✅${NC} $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌${NC} $description"
        echo -e "   ${YELLOW}Missing:${NC} $file_path"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Función para verificar directorio
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -d "$dir_path" ]; then
        echo -e "${GREEN}✅${NC} $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌${NC} $description"
        echo -e "   ${YELLOW}Missing:${NC} $dir_path"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Rutas base
BILLPAY_BASE="/home/giovanemere/periferia/billpay/Repositorios-Github"
ICBS_BASE="/home/giovanemere/periferia/icbs/docker-for-oracle-weblogic"

echo -e "\n${BLUE}📋 Verificando Repositorio: poc-billpay-back${NC}"
echo "----------------------------------------"
check_directory "$BILLPAY_BASE/poc-billpay-back/.github" "Directorio .github existe"
check_file "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "Workflow CI/CD para Spring Boot"
check_file "$BILLPAY_BASE/poc-billpay-back/.github/dependabot.yml" "Configuración Dependabot"
check_file "$BILLPAY_BASE/poc-billpay-back/.github/README.md" "README de GitHub Actions"

echo -e "\n${BLUE}📋 Verificando Repositorio: poc-billpay-front-a${NC}"
echo "----------------------------------------"
check_directory "$BILLPAY_BASE/poc-billpay-front-a/.github" "Directorio .github existe"
check_file "$BILLPAY_BASE/poc-billpay-front-a/.github/workflows/ci-cd.yml" "Workflow CI/CD para Angular Frontend A"
check_file "$BILLPAY_BASE/poc-billpay-front-a/.github/dependabot.yml" "Configuración Dependabot"
check_file "$BILLPAY_BASE/poc-billpay-front-a/.github/README.md" "README de GitHub Actions"
check_file "$BILLPAY_BASE/poc-billpay-front-a/.lighthouserc.json" "Configuración Lighthouse"
check_file "$BILLPAY_BASE/poc-billpay-front-a/playwright.config.ts" "Configuración Playwright"

echo -e "\n${BLUE}📋 Verificando Repositorio: poc-billpay-front-b${NC}"
echo "----------------------------------------"
check_directory "$BILLPAY_BASE/poc-billpay-front-b/.github" "Directorio .github existe"
check_file "$BILLPAY_BASE/poc-billpay-front-b/.github/workflows/ci-cd.yml" "Workflow CI/CD para Angular Frontend B (A/B Testing)"
check_file "$BILLPAY_BASE/poc-billpay-front-b/.github/dependabot.yml" "Configuración Dependabot"
check_file "$BILLPAY_BASE/poc-billpay-front-b/.github/README.md" "README de GitHub Actions"
check_file "$BILLPAY_BASE/poc-billpay-front-b/.lighthouserc.json" "Configuración Lighthouse"
check_file "$BILLPAY_BASE/poc-billpay-front-b/playwright.config.ts" "Configuración Playwright"

echo -e "\n${BLUE}📋 Verificando Repositorio: poc-billpay-front-feature-flags${NC}"
echo "----------------------------------------"
check_directory "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github" "Directorio .github existe"
check_file "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/workflows/ci-cd.yml" "Workflow CI/CD para Feature Flags"
check_file "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/dependabot.yml" "Configuración Dependabot"
check_file "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/README.md" "README de GitHub Actions"
check_file "$BILLPAY_BASE/poc-billpay-front-feature-flags/.lighthouserc.json" "Configuración Lighthouse"
check_file "$BILLPAY_BASE/poc-billpay-front-feature-flags/playwright.config.ts" "Configuración Playwright"

echo -e "\n${BLUE}📋 Verificando Repositorio: poc-icbs${NC}"
echo "----------------------------------------"
check_directory "$ICBS_BASE/.github" "Directorio .github existe"
check_file "$ICBS_BASE/.github/workflows/ci-cd.yml" "Workflow CI/CD para Oracle WebLogic Platform"
check_file "$ICBS_BASE/.github/dependabot.yml" "Configuración Dependabot"
check_file "$ICBS_BASE/.github/README.md" "README de GitHub Actions"

echo -e "\n${BLUE}📋 Verificando Documentación General${NC}"
echo "----------------------------------------"
check_file "/home/giovanemere/ia-ops/ia-ops/GITHUB_ACTIONS_SETUP.md" "Guía completa de setup"
check_file "/home/giovanemere/ia-ops/ia-ops/verify-workflows.sh" "Script de verificación"

# Verificar contenido de workflows
echo -e "\n${BLUE}🔍 Verificando Contenido de Workflows${NC}"
echo "----------------------------------------"

# Función para verificar contenido
check_workflow_content() {
    local file_path="$1"
    local search_term="$2"
    local description="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file_path" ] && grep -q "$search_term" "$file_path"; then
        echo -e "${GREEN}✅${NC} $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌${NC} $description"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Verificar contenido específico de workflows
check_workflow_content "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "Spring Boot Backend" "Workflow contiene configuración Spring Boot"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-a/.github/workflows/ci-cd.yml" "Angular Frontend A" "Workflow contiene configuración Angular"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-b/.github/workflows/ci-cd.yml" "A/B Testing" "Workflow contiene configuración A/B Testing"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/workflows/ci-cd.yml" "Feature Flags" "Workflow contiene configuración Feature Flags"
check_workflow_content "$ICBS_BASE/.github/workflows/ci-cd.yml" "Oracle WebLogic" "Workflow contiene configuración Oracle WebLogic"

# Verificar estructura de jobs
echo -e "\n${BLUE}🏗️ Verificando Estructura de Jobs${NC}"
echo "----------------------------------------"

check_workflow_content "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "jobs:" "Backend: Estructura de jobs definida"
check_workflow_content "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "test:" "Backend: Job de testing definido"
check_workflow_content "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "build:" "Backend: Job de build definido"
check_workflow_content "$BILLPAY_BASE/poc-billpay-back/.github/workflows/ci-cd.yml" "docker:" "Backend: Job de Docker definido"

check_workflow_content "$BILLPAY_BASE/poc-billpay-front-a/.github/workflows/ci-cd.yml" "lighthouse:" "Frontend A: Job de Lighthouse definido"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-a/.github/workflows/ci-cd.yml" "e2e-tests:" "Frontend A: Job de E2E tests definido"

check_workflow_content "$BILLPAY_BASE/poc-billpay-front-b/.github/workflows/ci-cd.yml" "canary-deployment:" "Frontend B: Job de Canary deployment definido"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-b/.github/workflows/ci-cd.yml" "a-b-testing:" "Frontend B: Job de A/B testing definido"

check_workflow_content "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/workflows/ci-cd.yml" "feature-flag-validation:" "Feature Flags: Job de validación definido"
check_workflow_content "$BILLPAY_BASE/poc-billpay-front-feature-flags/.github/workflows/ci-cd.yml" "feature-rollout:" "Feature Flags: Job de rollout definido"

check_workflow_content "$ICBS_BASE/.github/workflows/ci-cd.yml" "build-images:" "ICBS: Job de build de imágenes definido"
check_workflow_content "$ICBS_BASE/.github/workflows/ci-cd.yml" "integration-test:" "ICBS: Job de integration test definido"

# Verificar triggers
echo -e "\n${BLUE}🔄 Verificando Triggers de Workflows${NC}"
echo "----------------------------------------"

for repo in "poc-billpay-back" "poc-billpay-front-a" "poc-billpay-front-b" "poc-billpay-front-feature-flags"; do
    workflow_file="$BILLPAY_BASE/$repo/.github/workflows/ci-cd.yml"
    check_workflow_content "$workflow_file" "on:" "Repo $repo: Triggers definidos"
    check_workflow_content "$workflow_file" "push:" "Repo $repo: Push trigger definido"
    check_workflow_content "$workflow_file" "pull_request:" "Repo $repo: PR trigger definido"
    check_workflow_content "$workflow_file" "workflow_dispatch:" "Repo $repo: Manual trigger definido"
done

check_workflow_content "$ICBS_BASE/.github/workflows/ci-cd.yml" "on:" "ICBS: Triggers definidos"
check_workflow_content "$ICBS_BASE/.github/workflows/ci-cd.yml" "push:" "ICBS: Push trigger definido"

# Resumen final
echo -e "\n${BLUE}📊 RESUMEN DE VERIFICACIÓN${NC}"
echo "=================================================="
echo -e "Total de verificaciones: ${BLUE}$TOTAL_CHECKS${NC}"
echo -e "Verificaciones exitosas: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Verificaciones fallidas: ${RED}$FAILED_CHECKS${NC}"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ¡TODOS LOS WORKFLOWS ESTÁN CORRECTAMENTE CONFIGURADOS!${NC}"
    echo -e "${GREEN}✅ Los repositorios están listos para CI/CD${NC}"
    echo -e "\n${YELLOW}📋 Próximos pasos:${NC}"
    echo "1. Configurar secrets en GitHub para cada repositorio"
    echo "2. Crear environments (development/production)"
    echo "3. Configurar branch protection rules"
    echo "4. Hacer push de los cambios para activar los workflows"
    echo ""
    echo -e "${BLUE}📖 Consulta GITHUB_ACTIONS_SETUP.md para instrucciones detalladas${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  ALGUNOS ARCHIVOS ESTÁN FALTANDO${NC}"
    echo -e "${YELLOW}Por favor, revisa los archivos faltantes arriba${NC}"
    exit 1
fi
