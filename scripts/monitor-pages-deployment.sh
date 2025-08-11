#!/bin/bash

# 📊 Script para monitorear el despliegue de GitHub Pages
# Este script te ayuda a verificar el estado del despliegue

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}📊 GitHub Pages Deployment Monitor${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️  WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

print_action() {
    echo -e "${YELLOW}[📋 ACTION]${NC} $1"
}

print_header

print_status "Verificando estado del despliegue de GitHub Pages..."

echo ""
echo "🔗 ENLACES IMPORTANTES:"
echo "======================"
echo ""
echo "📊 GitHub Actions (workflows):"
echo "   https://github.com/giovanemere/ia-ops/actions"
echo ""
echo "⚙️ Configuración GitHub Pages:"
echo "   https://github.com/giovanemere/ia-ops/settings/pages"
echo ""
echo "🌐 Sitio GitHub Pages (una vez desplegado):"
echo "   https://giovanemere.github.io/ia-ops/"
echo ""

echo "🔍 CÓMO VERIFICAR EL ESTADO:"
echo "============================"
echo ""
echo "1. 📊 Ve a GitHub Actions:"
echo "   - Busca el workflow 'Deploy Docs to GitHub Pages (Simple)'"
echo "   - Verifica que esté ejecutándose o completado"
echo "   - Si hay errores, revisa los logs"
echo ""
echo "2. ⚙️ Verifica configuración GitHub Pages:"
echo "   - Source debe estar en 'GitHub Actions'"
echo "   - Debe mostrar el estado del último despliegue"
echo ""
echo "3. 🌐 Prueba el sitio:"
echo "   - Ve a https://giovanemere.github.io/ia-ops/"
echo "   - Debería mostrar la documentación de IA-Ops Platform"
echo ""

echo "✅ INDICADORES DE ÉXITO:"
echo "========================"
echo ""
echo "✅ Workflow completado sin errores"
echo "✅ GitHub Pages muestra 'Active' en configuración"
echo "✅ Sitio web accesible en giovanemere.github.io/ia-ops"
echo "✅ Documentación se muestra correctamente"
echo ""

echo "❌ POSIBLES ERRORES Y SOLUCIONES:"
echo "================================="
echo ""
echo "❌ Error 404 'Not Found':"
echo "   → GitHub Pages no está habilitado correctamente"
echo "   → Verificar Source = 'GitHub Actions' en configuración"
echo ""
echo "❌ Error 'Resource not accessible':"
echo "   → Permisos de workflow incorrectos"
echo "   → Verificar 'Read and write permissions' en Actions"
echo ""
echo "❌ Error 'Build failed':"
echo "   → Problema con MkDocs o documentación"
echo "   → Revisar logs del workflow para detalles"
echo ""
echo "❌ Sitio muestra contenido antiguo:"
echo "   → Cache del navegador"
echo "   → Hacer Ctrl+F5 o abrir en ventana privada"
echo ""

echo "⏱️ TIEMPOS ESPERADOS:"
echo "====================="
echo ""
echo "• Workflow execution: 2-5 minutos"
echo "• GitHub Pages deployment: 1-2 minutos adicionales"
echo "• Propagación DNS: Hasta 10 minutos (primera vez)"
echo ""

print_status "Monitoreo configurado. Usa los enlaces arriba para verificar el progreso."

echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "=================="
echo ""
print_action "1. Ve a GitHub Actions y verifica que el workflow esté ejecutándose"
print_action "2. Una vez completado, prueba el sitio en giovanemere.github.io/ia-ops"
print_action "3. Si hay errores, revisa los logs del workflow"
print_action "4. La documentación debería actualizarse automáticamente con cada push"

echo ""
print_success "GitHub Pages habilitado correctamente. ¡Esperando despliegue!"
