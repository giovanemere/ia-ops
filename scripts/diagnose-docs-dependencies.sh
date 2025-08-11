#!/bin/bash

# 🔍 Script para diagnosticar problemas con dependencias de documentación
# Este script identifica problemas comunes con MkDocs y sus dependencias

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}🔍 Documentation Dependencies Diagnostics${NC}"
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

print_header

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
    exit 1
fi

print_status "Iniciando diagnóstico de dependencias de documentación..."

# ============================================================================
# DIAGNÓSTICO 1: PYTHON Y PIP
# ============================================================================

echo ""
echo "🐍 DIAGNÓSTICO 1: Python y Pip"
echo "==============================="

# Verificar Python
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version)
    print_success "Python disponible: $python_version"
    
    # Verificar versión mínima
    python_major=$(python3 -c "import sys; print(sys.version_info.major)")
    python_minor=$(python3 -c "import sys; print(sys.version_info.minor)")
    
    if [ "$python_major" -eq 3 ] && [ "$python_minor" -ge 8 ]; then
        print_success "Versión de Python compatible (>= 3.8)"
    else
        print_warning "Versión de Python puede ser incompatible (recomendado >= 3.8)"
    fi
else
    print_error "Python3 no encontrado"
    exit 1
fi

# Verificar pip
if command -v pip3 >/dev/null 2>&1; then
    pip_version=$(pip3 --version)
    print_success "Pip disponible: $pip_version"
else
    print_error "Pip3 no encontrado"
    exit 1
fi

# ============================================================================
# DIAGNÓSTICO 2: DEPENDENCIAS DEL SISTEMA
# ============================================================================

echo ""
echo "🔧 DIAGNÓSTICO 2: Dependencias del Sistema"
echo "=========================================="

# Lista de dependencias del sistema necesarias para MkDocs Material
system_deps=("build-essential" "libcairo2-dev" "libfreetype6-dev" "libffi-dev" "libjpeg-dev" "libpng-dev" "libz-dev")

for dep in "${system_deps[@]}"; do
    if dpkg -l | grep -q "^ii  $dep "; then
        print_success "$dep instalado"
    else
        print_warning "$dep no instalado (puede causar problemas con algunas características)"
    fi
done

# ============================================================================
# DIAGNÓSTICO 3: INSTALACIÓN DE MKDOCS
# ============================================================================

echo ""
echo "📚 DIAGNÓSTICO 3: Instalación de MkDocs"
echo "======================================="

# Crear entorno virtual temporal para testing
print_status "Creando entorno virtual temporal para testing..."
if [ -d "venv-test-docs" ]; then
    rm -rf venv-test-docs
fi

python3 -m venv venv-test-docs
source venv-test-docs/bin/activate

# Actualizar pip
print_status "Actualizando pip..."
pip install --upgrade pip setuptools wheel

# Crear archivo de requirements
print_status "Creando archivo de requirements..."
cat > requirements-test.txt << 'EOF'
# MkDocs core
mkdocs>=1.5.0,<2.0.0

# Material theme
mkdocs-material>=9.4.0,<10.0.0

# Plugins
mkdocs-mermaid2-plugin>=1.1.0,<2.0.0

# Additional dependencies
Pygments>=2.16.0
pymdown-extensions>=10.3.0

# Optional but useful
pillow>=10.0.0
cairosvg>=2.7.0
EOF

# Intentar instalar dependencias
print_status "Intentando instalar dependencias de MkDocs..."
install_success=true

if pip install -r requirements-test.txt --no-cache-dir; then
    print_success "Dependencias instaladas correctamente"
else
    print_error "Falló la instalación de dependencias"
    install_success=false
fi

# Verificar instalaciones individuales
if [ "$install_success" = true ]; then
    echo ""
    echo "🔍 Verificando instalaciones individuales:"
    
    # MkDocs
    if python -c "import mkdocs; print(f'MkDocs: {mkdocs.__version__}')" 2>/dev/null; then
        print_success "MkDocs importado correctamente"
    else
        print_error "MkDocs no se puede importar"
        install_success=false
    fi
    
    # Material theme
    if python -c "import mkdocs_material; print(f'Material: {mkdocs_material.__version__}')" 2>/dev/null; then
        print_success "Material theme importado correctamente"
    else
        print_error "Material theme no se puede importar"
        install_success=false
    fi
    
    # Mermaid plugin
    if python -c "import mermaid" 2>/dev/null; then
        print_success "Mermaid plugin importado correctamente"
    else
        print_warning "Mermaid plugin no se puede importar (opcional)"
    fi
    
    # Pygments
    if python -c "import pygments; print(f'Pygments: {pygments.__version__}')" 2>/dev/null; then
        print_success "Pygments importado correctamente"
    else
        print_error "Pygments no se puede importar"
        install_success=false
    fi
fi

# ============================================================================
# DIAGNÓSTICO 4: CONFIGURACIÓN DE MKDOCS
# ============================================================================

echo ""
echo "⚙️ DIAGNÓSTICO 4: Configuración de MkDocs"
echo "========================================="

# Verificar archivos de configuración
if [ -f "mkdocs.ci.yml" ]; then
    print_success "mkdocs.ci.yml encontrado"
    
    # Verificar sintaxis
    if python -c "import yaml; yaml.safe_load(open('mkdocs.ci.yml'))" 2>/dev/null; then
        print_success "mkdocs.ci.yml tiene sintaxis válida"
    else
        print_error "mkdocs.ci.yml tiene sintaxis inválida"
        python -c "import yaml; yaml.safe_load(open('mkdocs.ci.yml'))" 2>&1 | head -3
    fi
elif [ -f "mkdocs.yml" ]; then
    print_success "mkdocs.yml encontrado"
    
    # Verificar sintaxis
    if python -c "import yaml; yaml.safe_load(open('mkdocs.yml'))" 2>/dev/null; then
        print_success "mkdocs.yml tiene sintaxis válida"
    else
        print_error "mkdocs.yml tiene sintaxis inválida"
        python -c "import yaml; yaml.safe_load(open('mkdocs.yml'))" 2>&1 | head -3
    fi
else
    print_warning "No se encontró configuración de MkDocs"
fi

# Verificar directorio docs
if [ -d "docs" ]; then
    md_count=$(find docs -name "*.md" | wc -l)
    print_success "Directorio docs encontrado con $md_count archivos .md"
    
    if [ $md_count -eq 0 ]; then
        print_warning "No hay archivos markdown en docs/"
    fi
else
    print_error "Directorio docs no encontrado"
fi

# ============================================================================
# DIAGNÓSTICO 5: TEST DE BUILD
# ============================================================================

echo ""
echo "🏗️ DIAGNÓSTICO 5: Test de Build"
echo "==============================="

if [ "$install_success" = true ]; then
    print_status "Intentando build de prueba..."
    
    # Crear configuración mínima si no existe
    if [ ! -f "mkdocs.ci.yml" ] && [ ! -f "mkdocs.yml" ]; then
        print_status "Creando configuración mínima para test..."
        cat > mkdocs-test.yml << 'EOF'
site_name: Test Documentation
theme:
  name: material
nav:
  - Home: index.md
plugins:
  - search
strict: false
EOF
        config_file="mkdocs-test.yml"
    elif [ -f "mkdocs.ci.yml" ]; then
        config_file="mkdocs.ci.yml"
    else
        config_file="mkdocs.yml"
    fi
    
    # Crear docs mínimos si no existen
    if [ ! -d "docs" ] || [ $(find docs -name "*.md" | wc -l) -eq 0 ]; then
        print_status "Creando documentación mínima para test..."
        mkdir -p docs
        echo "# Test Documentation" > docs/index.md
        echo "This is a test." >> docs/index.md
    fi
    
    # Intentar build
    if mkdocs build --config-file "$config_file" --clean 2>/dev/null; then
        print_success "Build de prueba exitoso"
        
        # Verificar archivos generados
        if [ -f "site/index.html" ]; then
            print_success "index.html generado correctamente"
        else
            print_error "index.html no generado"
        fi
        
        # Limpiar archivos de test
        rm -rf site
        if [ -f "mkdocs-test.yml" ]; then
            rm mkdocs-test.yml
        fi
        if [ ! -f "docs/index.md.original" ] && [ "$(cat docs/index.md)" = "# Test Documentation
This is a test." ]; then
            rm -rf docs
        fi
        
    else
        print_error "Build de prueba falló"
        echo "Error details:"
        mkdocs build --config-file "$config_file" --clean 2>&1 | head -10
    fi
else
    print_warning "Saltando test de build debido a problemas de instalación"
fi

# Limpiar entorno virtual
deactivate
rm -rf venv-test-docs requirements-test.txt

# ============================================================================
# RESUMEN Y RECOMENDACIONES
# ============================================================================

echo ""
echo "📊 RESUMEN Y RECOMENDACIONES"
echo "============================"

if [ "$install_success" = true ]; then
    print_success "✅ Diagnóstico completado - No se encontraron problemas críticos"
    echo ""
    echo "🔧 Recomendaciones para GitHub Actions:"
    echo "1. Usar Python 3.11 (actions/setup-python@v4)"
    echo "2. Instalar dependencias del sistema antes de pip install"
    echo "3. Usar versiones fijas de dependencias"
    echo "4. Implementar retry logic para instalación"
    echo "5. Usar --no-cache-dir para evitar problemas de cache"
else
    print_error "❌ Se encontraron problemas críticos"
    echo ""
    echo "🔧 Acciones requeridas:"
    echo "1. Verificar que Python >= 3.8 esté disponible"
    echo "2. Instalar dependencias del sistema faltantes"
    echo "3. Verificar conectividad a PyPI"
    echo "4. Revisar configuración de MkDocs"
fi

echo ""
echo "📋 Comando para instalar dependencias del sistema:"
echo "sudo apt-get update && sudo apt-get install -y build-essential libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev"

echo ""
echo "📋 Comando para instalar dependencias de Python:"
echo "pip install --upgrade pip setuptools wheel"
echo "pip install 'mkdocs>=1.5.0,<2.0.0' 'mkdocs-material>=9.4.0,<10.0.0' 'mkdocs-mermaid2-plugin>=1.1.0,<2.0.0' --no-cache-dir"

print_status "Diagnóstico completado."
