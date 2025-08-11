#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN DE DOCUMENTACIÓN AUTOMÁTICA
# =============================================================================
# Descripción: Verifica que todas las funcionalidades estén configuradas
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

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

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔍 Verificando configuración de documentación automática..."

# Contadores
CHECKS_PASSED=0
CHECKS_TOTAL=0

check_result() {
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    if [ $1 -eq 0 ]; then
        log_success "$2"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "$2"
    fi
}

echo ""
log_info "=== VERIFICANDO CONFIGURACIÓN BASE ==="

# Verificar app-config.yaml
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
if [ -f "app-config.yaml" ]; then
    log_success "app-config.yaml existe"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "app-config.yaml no encontrado"
fi

# Verificar configuración TechDocs
grep -q "techdocs:" app-config.yaml
check_result $? "Configuración TechDocs encontrada"

# Verificar configuración GitHub Actions
grep -q "github-actions:" app-config.yaml
check_result $? "Configuración GitHub Actions encontrada"

# Verificar configuración Catalog Discovery
grep -q "providers:" app-config.yaml
check_result $? "Configuración Catalog Discovery encontrada"

echo ""
log_info "=== VERIFICANDO PLUGINS INSTALADOS ==="

# Verificar plugin TechDocs
yarn list @backstage/plugin-techdocs >/dev/null 2>&1
check_result $? "Plugin TechDocs instalado"

# Verificar plugin GitHub Actions
yarn list @backstage/plugin-github-actions >/dev/null 2>&1
check_result $? "Plugin GitHub Actions instalado"

echo ""
log_info "=== VERIFICANDO ARCHIVOS GENERADOS ==="

# Verificar templates
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
if [ -f "catalog-template.yaml" ]; then
    log_success "Template catalog-info.yaml existe"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "Template catalog-info.yaml no encontrado"
fi

CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
if [ -f "mkdocs-template.yml" ]; then
    log_success "Template mkdocs.yml existe"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "Template mkdocs.yml no encontrado"
fi

# Verificar directorio de documentación
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
if [ -d "repo-docs" ]; then
    log_success "Directorio repo-docs existe"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    
    # Verificar archivos por repositorio
    REPOS=("poc-billpay-back" "poc-billpay-front-a" "poc-billpay-front-b" "poc-billpay-front-feature-flags" "poc-icbs")
    
    for repo in "${REPOS[@]}"; do
        CHECKS_TOTAL=$((CHECKS_TOTAL + 4))
        
        if [ -f "repo-docs/$repo/catalog-info.yaml" ]; then
            log_success "catalog-info.yaml generado para $repo"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "catalog-info.yaml faltante para $repo"
        fi
        
        if [ -f "repo-docs/$repo/mkdocs.yml" ]; then
            log_success "mkdocs.yml generado para $repo"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "mkdocs.yml faltante para $repo"
        fi
        
        if [ -d "repo-docs/$repo/docs" ]; then
            log_success "Directorio docs/ generado para $repo"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "Directorio docs/ faltante para $repo"
        fi
        
        if [ -f "repo-docs/$repo/docs/index.md" ]; then
            log_success "Documentación index.md generada para $repo"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "Documentación index.md faltante para $repo"
        fi
    done
else
    log_error "Directorio repo-docs no encontrado"
fi

echo ""
log_info "=== VERIFICANDO VARIABLES DE ENTORNO ==="

# Verificar variables críticas
if [ -n "$GITHUB_TOKEN" ]; then
    log_success "GITHUB_TOKEN configurado"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "GITHUB_TOKEN no configurado"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

if [ -n "$GITHUB_ORG" ]; then
    log_success "GITHUB_ORG configurado ($GITHUB_ORG)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "GITHUB_ORG no configurado"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

echo ""
log_info "=== VERIFICANDO CONECTIVIDAD ==="

# Verificar acceso a GitHub API
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user >/dev/null 2>&1; then
    log_success "Acceso a GitHub API funcionando"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "No se puede acceder a GitHub API"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

# Verificar acceso a repositorios
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/giovanemere/poc-billpay-back >/dev/null 2>&1; then
    log_success "Acceso a repositorios funcionando"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    log_error "No se puede acceder a repositorios"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

echo ""
log_info "=== VERIFICANDO SCRIPTS ==="

# Verificar scripts ejecutables
SCRIPTS=("deploy-docs-to-repos.sh" "commit-docs-to-repos.sh" "generate-catalog-files.sh")

for script in "${SCRIPTS[@]}"; do
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    if [ -x "$script" ]; then
        log_success "Script $script es ejecutable"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "Script $script no es ejecutable o no existe"
    fi
done

echo ""
log_info "=== RESUMEN DE VERIFICACIÓN ==="

# Calcular porcentaje
PERCENTAGE=$((CHECKS_PASSED * 100 / CHECKS_TOTAL))

echo "📊 Resultados:"
echo "   ✅ Verificaciones pasadas: $CHECKS_PASSED"
echo "   📋 Total verificaciones: $CHECKS_TOTAL"
echo "   📈 Porcentaje de éxito: $PERCENTAGE%"

echo ""
if [ $PERCENTAGE -ge 90 ]; then
    log_success "¡Configuración excelente! ($PERCENTAGE%)"
    echo "🎯 Estado: LISTO PARA PRODUCCIÓN"
elif [ $PERCENTAGE -ge 75 ]; then
    log_warning "Configuración buena ($PERCENTAGE%)"
    echo "🔧 Estado: NECESITA AJUSTES MENORES"
else
    log_error "Configuración necesita mejoras ($PERCENTAGE%)"
    echo "⚠️  Estado: REQUIERE ATENCIÓN"
fi

echo ""
log_info "=== PRÓXIMOS PASOS ==="

if [ $PERCENTAGE -ge 90 ]; then
    echo "🚀 Todo listo! Puedes:"
    echo "   1. Ejecutar: ./commit-docs-to-repos.sh"
    echo "   2. Iniciar Backstage: yarn start"
    echo "   3. Verificar en: http://localhost:3002"
elif [ $PERCENTAGE -ge 75 ]; then
    echo "🔧 Corrige los errores menores y luego:"
    echo "   1. Ejecuta este script nuevamente"
    echo "   2. Despliega la documentación"
    echo "   3. Inicia Backstage"
else
    echo "⚠️  Corrige los errores críticos:"
    echo "   1. Revisa la configuración de app-config.yaml"
    echo "   2. Verifica las variables de entorno"
    echo "   3. Instala los plugins faltantes"
    echo "   4. Ejecuta este script nuevamente"
fi

echo ""
log_info "📚 Documentación disponible en: AUTO-DOCUMENTATION-SUMMARY.md"

exit 0
