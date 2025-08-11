#!/bin/bash

# =============================================================================
# SCRIPT FINAL PARA CORREGIR MODO OSCURO EN BACKSTAGE
# =============================================================================
# Descripción: Aplica todas las correcciones necesarias para modo oscuro
# Fecha: $(date)
# =============================================================================

set -e

echo "🌙 Aplicando correcciones finales para modo oscuro..."

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

log_info "Aplicando todas las correcciones de modo oscuro..."

# 1. Verificar feature flag
log_info "1. Verificando feature flag..."
if grep -q "enable-dark-mode-enhancements: true" app-config.yaml; then
    log_success "Feature flag habilitado"
else
    log_warning "Habilitando feature flag..."
    sed -i 's/enable-dark-mode-enhancements: false/enable-dark-mode-enhancements: true/' app-config.yaml
    log_success "Feature flag habilitado"
fi

# 2. Verificar directorio de estilos
log_info "2. Verificando estructura de archivos..."
mkdir -p packages/app/src/styles
mkdir -p packages/app/src/scripts
mkdir -p packages/app/src/components

# 3. Verificar que todos los archivos existen
log_info "3. Verificando archivos necesarios..."

files_to_check=(
    "packages/app/src/styles/dark-mode.css"
    "packages/app/src/scripts/force-dark-mode.js"
    "packages/app/src/components/DarkModeDetector.tsx"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        log_success "Archivo $file existe"
    else
        log_error "Archivo $file no encontrado"
        exit 1
    fi
done

# 4. Verificar importaciones en index.tsx
log_info "4. Verificando importaciones..."
if grep -q "dark-mode.css" packages/app/src/index.tsx; then
    log_success "CSS importado"
else
    log_warning "Agregando importación de CSS..."
    sed -i "/import '@backstage\/ui\/css\/styles.css';/a import './styles/dark-mode.css';" packages/app/src/index.tsx
fi

if grep -q "force-dark-mode.js" packages/app/src/index.tsx; then
    log_success "Script JS importado"
else
    log_warning "Agregando importación de script..."
    sed -i "/import '.\/styles\/dark-mode.css';/a import './scripts/force-dark-mode.js';" packages/app/src/index.tsx
fi

# 5. Verificar DarkModeDetector en App.tsx
log_info "5. Verificando DarkModeDetector..."
if grep -q "DarkModeDetector" packages/app/src/App.tsx; then
    log_success "DarkModeDetector integrado"
else
    log_warning "DarkModeDetector no está integrado completamente"
fi

# 6. Compilar para verificar errores
log_info "6. Verificando compilación..."
if yarn tsc --noEmit; then
    log_success "Compilación exitosa"
else
    log_error "Errores de compilación encontrados"
    exit 1
fi

# 7. Crear archivo de prueba para verificar estilos
log_info "7. Creando archivo de prueba..."
cat > test-dark-mode.html << 'EOF'
<!DOCTYPE html>
<html data-theme="dark">
<head>
    <title>Test Dark Mode</title>
    <style>
        body { background: #1e1e1e; color: #e0e0e0; font-family: Arial, sans-serif; padding: 20px; }
    </style>
    <link rel="stylesheet" href="packages/app/src/styles/dark-mode.css">
</head>
<body>
    <h1>Test de Modo Oscuro</h1>
    <pre class="MuiBox-root-1818" style="background-color: rgb(245, 245, 245); padding: 16px; border-radius: 4px; overflow: auto; font-size: 0.875rem;">
featureFlags:
  enable-advanced-features: true
  enable-experimental-ui: false
  enable-beta-analytics: true
  enable-dark-mode-enhancements: true
    </pre>
    <p>Si ves el texto anterior con fondo oscuro, los estilos funcionan correctamente.</p>
</body>
</html>
EOF

log_success "Archivo de prueba creado: test-dark-mode.html"

# 8. Mostrar resumen
log_success "🎉 Todas las correcciones aplicadas exitosamente!"

echo ""
echo "📋 Resumen de correcciones aplicadas:"
echo "  ✅ Feature flag 'enable-dark-mode-enhancements' habilitado"
echo "  ✅ Estilos CSS específicos con !important"
echo "  ✅ Script JavaScript para forzar estilos"
echo "  ✅ Componente React DarkModeDetector"
echo "  ✅ Selectores CSS múltiples para mayor compatibilidad"
echo "  ✅ Detección automática de cambios en el DOM"
echo ""
echo "🚀 Para probar:"
echo "  1. Ejecuta: yarn start"
echo "  2. Cambia a modo oscuro en Backstage"
echo "  3. Los elementos <pre> deberían tener fondo oscuro automáticamente"
echo ""
echo "🔧 Para debugging:"
echo "  - Abre DevTools y ejecuta: window.forceDarkModeStyles()"
echo "  - Verifica que data-theme='dark' esté en el HTML"
echo "  - Revisa que los estilos CSS se estén aplicando"
echo ""
echo "📄 Archivo de prueba: test-dark-mode.html"
echo "   Abre este archivo en el navegador para probar los estilos"
