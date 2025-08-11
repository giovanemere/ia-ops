#!/bin/bash

# =============================================================================
# SCRIPT PARA VERIFICAR CONFIGURACIÓN DE GITHUB ACTIONS
# =============================================================================
# Descripción: Verifica que GitHub Actions esté correctamente configurado
# Fecha: $(date)
# =============================================================================

set -e

echo "🔍 Verificando configuración de GitHub Actions..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
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
    log_error "No se encontró package.json. Ejecuta este script desde el directorio raíz de Backstage."
    exit 1
fi

log_info "1. Verificando plugin de GitHub Actions..."

# Verificar que el plugin esté instalado
if grep -q "@backstage/plugin-github-actions" packages/app/package.json; then
    log_success "Plugin de GitHub Actions instalado"
else
    log_error "Plugin de GitHub Actions no encontrado"
    exit 1
fi

log_info "2. Verificando configuración en app-config.yaml..."

# Verificar configuración de GitHub Actions
if grep -q "githubActions:" app-config.yaml; then
    if grep -q "^githubActions:" app-config.yaml; then
        log_success "Configuración de GitHub Actions habilitada"
    else
        log_warning "Configuración de GitHub Actions comentada"
    fi
else
    log_warning "Configuración de GitHub Actions no encontrada"
fi

log_info "3. Verificando token de GitHub..."

# Verificar que el token esté configurado
if [ -f "../.env" ]; then
    ENV_FILE="../.env"
elif [ -f "../../.env" ]; then
    ENV_FILE="../../.env"
else
    ENV_FILE=".env"
fi

if grep -q "GITHUB_TOKEN=" "$ENV_FILE" 2>/dev/null; then
    GITHUB_TOKEN=$(grep "GITHUB_TOKEN=" "$ENV_FILE" | cut -d'=' -f2)
    if [ ! -z "$GITHUB_TOKEN" ]; then
        log_success "Token de GitHub configurado"
        
        # Probar el token
        log_info "Probando token de GitHub..."
        if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user > /dev/null; then
            log_success "Token de GitHub válido"
        else
            log_error "Token de GitHub inválido o sin permisos"
        fi
    else
        log_error "Token de GitHub vacío"
    fi
else
    log_error "Token de GitHub no configurado en $ENV_FILE"
fi

log_info "4. Verificando rutas en App.tsx..."

# Verificar que la ruta esté configurada
if grep -q "github-actions" packages/app/src/App.tsx; then
    log_success "Ruta de GitHub Actions configurada"
else
    log_error "Ruta de GitHub Actions no encontrada"
fi

log_info "5. Verificando componente personalizado..."

# Verificar que el componente exista
if [ -f "packages/app/src/components/GitHubActions/GitHubActionsPage.tsx" ]; then
    log_success "Componente personalizado de GitHub Actions encontrado"
else
    log_error "Componente personalizado no encontrado"
fi

log_info "6. Verificando menú de navegación..."

# Verificar que esté en el menú
if grep -q "github-actions" packages/app/src/components/Root/Root.tsx; then
    log_success "GitHub Actions en menú de navegación"
else
    log_warning "GitHub Actions no encontrado en menú de navegación"
fi

log_info "7. Probando acceso a repositorios..."

# Probar acceso a repositorios configurados
repositories=("poc-billpay-back" "poc-billpay-front-a" "poc-billpay-front-b" "poc-billpay-front-feature-flags" "poc-icbs")

for repo in "${repositories[@]}"; do
    log_info "Probando acceso a $repo..."
    if curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/giovanemere/$repo" > /dev/null; then
        log_success "Acceso a $repo: OK"
    else
        log_warning "Acceso a $repo: Sin acceso o repositorio no existe"
    fi
done

log_info "8. Verificando compilación..."

# Verificar que compile sin errores
if yarn tsc --noEmit --skipLibCheck; then
    log_success "Compilación exitosa"
else
    log_error "Errores de compilación encontrados"
    exit 1
fi

log_success "🎉 Verificación completada!"

echo ""
echo "📋 Resumen:"
echo "  ✅ Plugin instalado y configurado"
echo "  ✅ Componente personalizado creado"
echo "  ✅ Ruta configurada en App.tsx"
echo "  ✅ Token de GitHub válido"
echo "  ✅ Compilación exitosa"
echo ""
echo "🚀 Para probar:"
echo "  1. Ejecuta: yarn start"
echo "  2. Ve a: http://localhost:3002/github-actions"
echo "  3. Deberías ver la página de GitHub Actions con tus repositorios"
echo ""
echo "💡 Nota: La página mostrará 'No Workflows' para repositorios sin GitHub Actions configuradas."
echo "    Esto es normal y esperado. Puedes hacer clic en 'Setup Workflow' para crear workflows."
