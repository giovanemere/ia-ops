#!/bin/bash

# 🔍 Script para verificar configuración de GitHub Pages
# Este script te ayuda a verificar si GitHub Pages está configurado correctamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}🔍 GitHub Pages Configuration Check${NC}"
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
    echo -e "${YELLOW}[📋 ACTION REQUIRED]${NC} $1"
}

print_header

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
    exit 1
fi

print_status "Verificando configuración local..."

# 1. Verificar workflows de GitHub Pages
echo ""
echo "📁 Verificando workflows de GitHub Pages:"
if [ -f ".github/workflows/pages-simple.yml" ]; then
    print_success "Workflow pages-simple.yml encontrado"
else
    print_error "Workflow pages-simple.yml NO encontrado"
fi

if [ -f ".github/workflows/deploy-docs.yml" ]; then
    print_success "Workflow deploy-docs.yml encontrado"
else
    print_warning "Workflow deploy-docs.yml NO encontrado"
fi

# 2. Verificar configuración de MkDocs
echo ""
echo "📚 Verificando configuración de MkDocs:"
if [ -f "mkdocs.ci.yml" ]; then
    print_success "Configuración mkdocs.ci.yml encontrada"
else
    print_warning "mkdocs.ci.yml NO encontrado, usando mkdocs.yml"
fi

if [ -f "mkdocs.yml" ]; then
    print_success "Configuración mkdocs.yml encontrada"
else
    print_error "mkdocs.yml NO encontrado"
fi

# 3. Verificar directorio docs
echo ""
echo "📖 Verificando contenido de documentación:"
if [ -d "docs" ]; then
    doc_count=$(find docs -name "*.md" | wc -l)
    print_success "Directorio docs encontrado con $doc_count archivos .md"
else
    print_error "Directorio docs NO encontrado"
fi

# 4. Test build local
echo ""
echo "🏗️ Probando build local de documentación:"
if command -v mkdocs >/dev/null 2>&1; then
    print_status "MkDocs instalado, probando build..."
    
    if [ -f "mkdocs.ci.yml" ]; then
        if mkdocs build --config-file mkdocs.ci.yml --clean >/dev/null 2>&1; then
            print_success "Build local exitoso con mkdocs.ci.yml"
        else
            print_error "Build local falló con mkdocs.ci.yml"
        fi
    elif [ -f "mkdocs.yml" ]; then
        if mkdocs build --clean >/dev/null 2>&1; then
            print_success "Build local exitoso con mkdocs.yml"
        else
            print_error "Build local falló con mkdocs.yml"
        fi
    fi
else
    print_warning "MkDocs no está instalado localmente"
    print_status "Para instalar: pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin"
fi

# 5. Verificar archivos generados
if [ -d "site" ]; then
    site_files=$(find site -type f | wc -l)
    print_success "Directorio site generado con $site_files archivos"
else
    print_warning "Directorio site NO encontrado (ejecuta mkdocs build)"
fi

echo ""
echo "🌐 CONFIGURACIÓN MANUAL REQUERIDA EN GITHUB:"
echo "============================================"
echo ""

print_action "1. Habilitar GitHub Pages:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/settings/pages"
echo "   - En 'Source', selecciona: 'GitHub Actions'"
echo "   - Haz clic en 'Save'"
echo ""

print_action "2. Configurar permisos de Actions:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/settings/actions"
echo "   - En 'Workflow permissions': 'Read and write permissions'"
echo "   - Marca: 'Allow GitHub Actions to create and approve pull requests'"
echo "   - Haz clic en 'Save'"
echo ""

print_action "3. Verificar que el workflow se ejecute:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/actions"
echo "   - Busca: 'Deploy Docs to GitHub Pages (Simple)'"
echo "   - Verifica que no haya errores 404"
echo ""

print_action "4. Una vez configurado, la documentación estará en:"
echo "   - https://giovanemere.github.io/ia-ops/"
echo ""

echo "🔍 DIAGNÓSTICO DE ERRORES COMUNES:"
echo "=================================="
echo ""
echo "❌ Error: 'Not Found' o 'Resource not accessible'"
echo "   → GitHub Pages NO está habilitado (paso 1 arriba)"
echo ""
echo "❌ Error: 'Workflow permissions denied'"
echo "   → Permisos de Actions incorrectos (paso 2 arriba)"
echo ""
echo "❌ Error: 'SARIF upload failed'"
echo "   → Usar workflows básicos sin características premium"
echo ""

print_status "Verificación completada. Sigue los pasos manuales arriba."

# Mostrar resumen final
echo ""
echo "📊 RESUMEN:"
echo "==========="
if [ -f ".github/workflows/pages-simple.yml" ] && [ -d "docs" ]; then
    print_success "Configuración local: ✅ Lista"
    print_action "Pendiente: Configuración manual en GitHub"
else
    print_error "Configuración local: ❌ Incompleta"
fi
