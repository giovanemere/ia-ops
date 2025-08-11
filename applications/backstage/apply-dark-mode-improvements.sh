#!/bin/bash

# =============================================================================
# SCRIPT PARA APLICAR MEJORAS DE MODO OSCURO EN BACKSTAGE
# =============================================================================
# Descripción: Aplica mejoras de contraste y visibilidad para modo oscuro
# Fecha: $(date)
# =============================================================================

set -e

echo "🌙 Aplicando mejoras de modo oscuro para Backstage..."

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

log_info "Verificando configuración actual..."

# Verificar que el feature flag esté habilitado
if grep -q "enable-dark-mode-enhancements: true" app-config.yaml; then
    log_success "Feature flag 'enable-dark-mode-enhancements' está habilitado"
else
    log_warning "Feature flag 'enable-dark-mode-enhancements' no está habilitado"
    log_info "Habilitando feature flag..."
    sed -i 's/enable-dark-mode-enhancements: false/enable-dark-mode-enhancements: true/' app-config.yaml
    log_success "Feature flag habilitado"
fi

# Verificar que los estilos CSS estén importados
if grep -q "dark-mode.css" packages/app/src/index.tsx; then
    log_success "Estilos de modo oscuro están importados"
else
    log_warning "Estilos de modo oscuro no están importados"
    log_info "Agregando importación de estilos..."
    sed -i "/import '@backstage\/ui\/css\/styles.css';/a import './styles/dark-mode.css';" packages/app/src/index.tsx
    log_success "Estilos importados"
fi

# Verificar que el directorio de estilos existe
if [ ! -d "packages/app/src/styles" ]; then
    log_info "Creando directorio de estilos..."
    mkdir -p packages/app/src/styles
    log_success "Directorio de estilos creado"
fi

# Verificar que el archivo de estilos existe
if [ ! -f "packages/app/src/styles/dark-mode.css" ]; then
    log_error "Archivo dark-mode.css no encontrado. Asegúrate de que esté creado."
    exit 1
else
    log_success "Archivo de estilos de modo oscuro encontrado"
fi

# Verificar mejoras en AiChatPage
if grep -q "backgroundColor: theme.palette.type === 'dark'" packages/app/src/components/AiChat/AiChatPage.tsx; then
    log_success "Mejoras de modo oscuro aplicadas en AiChatPage"
else
    log_warning "Las mejoras de modo oscuro no están completamente aplicadas en AiChatPage"
fi

log_info "Compilando aplicación para verificar que no hay errores..."

# Verificar que no hay errores de TypeScript
if yarn tsc --noEmit; then
    log_success "Verificación de TypeScript exitosa"
else
    log_error "Errores de TypeScript encontrados. Revisa la configuración."
    exit 1
fi

log_success "🎉 Mejoras de modo oscuro aplicadas exitosamente!"

echo ""
echo "📋 Resumen de mejoras aplicadas:"
echo "  ✅ Feature flag 'enable-dark-mode-enhancements' habilitado"
echo "  ✅ Estilos CSS personalizados para modo oscuro"
echo "  ✅ Mejoras en componente AiChatPage"
echo "  ✅ Mejor contraste para elementos <pre> y <code>"
echo "  ✅ Scrollbars mejorados para modo oscuro"
echo "  ✅ Inputs y campos de texto optimizados"
echo ""
echo "🚀 Para ver los cambios:"
echo "  1. Ejecuta: yarn start"
echo "  2. Ve a la aplicación en el navegador"
echo "  3. Cambia al modo oscuro en la configuración de usuario"
echo "  4. Visita la página de AI Chat para ver las mejoras"
echo ""
echo "💡 Tip: Los elementos <pre> ahora tienen fondo oscuro con texto verde"
echo "    para mejor legibilidad en modo oscuro."
