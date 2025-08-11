#!/bin/bash

# 🌐 Script para configurar GitHub Pages
# Este script ayuda a configurar GitHub Pages para el repositorio

set -e

echo "🌐 Configurando GitHub Pages para IA-Ops Platform..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
    exit 1
fi

print_status "Verificando configuración actual..."

# Verificar si existe el directorio docs
if [ ! -d "docs" ]; then
    print_warning "Directorio 'docs' no encontrado. Creando estructura básica..."
    mkdir -p docs
    
    # Crear index.md básico
    cat > docs/index.md << 'EOF'
# 🚀 IA-Ops Platform

Bienvenido a la documentación de IA-Ops Platform.

## 📋 Descripción

IA-Ops Platform es una solución completa que integra:
- 🏛️ **Backstage**: Portal de desarrolladores
- 🤖 **OpenAI Service**: Servicio nativo de IA con conocimiento DevOps
- 📚 **Documentación Inteligente**: MkDocs + TechDocs
- 🎯 **Templates Multi-Cloud**: Catálogo de despliegues

## 🚀 Inicio Rápido

```bash
# Clonar el repositorio
git clone https://github.com/giovanemere/ia-ops.git
cd ia-ops

# Iniciar servicios
docker-compose up -d
```

## 🔗 Enlaces Útiles

- [🌐 Proxy Gateway](http://localhost:8080)
- [🏛️ Backstage](http://localhost:3000)
- [🤖 OpenAI Service](http://localhost:8000)
- [📊 Prometheus](http://localhost:9090)
- [📈 Grafana](http://localhost:3001)
EOF

    print_success "Estructura de documentación creada"
fi

# Verificar configuración de MkDocs
if [ ! -f "mkdocs.ci.yml" ]; then
    print_warning "Archivo mkdocs.ci.yml no encontrado"
    if [ -f "mkdocs.yml" ]; then
        print_status "Usando mkdocs.yml como configuración"
    else
        print_error "No se encontró configuración de MkDocs"
        exit 1
    fi
fi

# Test build local
print_status "Probando build local de documentación..."

# Crear entorno virtual si no existe
if [ ! -d "venv-docs" ]; then
    print_status "Creando entorno virtual para documentación..."
    python3 -m venv venv-docs
fi

# Activar entorno virtual
source venv-docs/bin/activate

# Instalar dependencias
print_status "Instalando dependencias de MkDocs..."
pip install --upgrade pip
pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Build de prueba
print_status "Construyendo documentación..."
if [ -f "mkdocs.ci.yml" ]; then
    mkdocs build --config-file mkdocs.ci.yml --clean
else
    mkdocs build --clean
fi

if [ -d "site" ] && [ "$(ls -A site)" ]; then
    print_success "Build de documentación exitoso"
    print_status "Archivos generados en ./site/"
    ls -la site/ | head -10
else
    print_error "Build de documentación falló"
    exit 1
fi

# Desactivar entorno virtual
deactivate

print_success "Configuración local completada"

echo ""
echo "🌐 PASOS MANUALES REQUERIDOS:"
echo "================================"
echo ""
echo "1. 📋 Habilitar GitHub Pages:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/settings/pages"
echo "   - En 'Source', selecciona: 'GitHub Actions'"
echo "   - Haz clic en 'Save'"
echo ""
echo "2. 🔧 Configurar permisos de Actions:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/settings/actions"
echo "   - En 'Workflow permissions', selecciona: 'Read and write permissions'"
echo "   - Marca: 'Allow GitHub Actions to create and approve pull requests'"
echo "   - Haz clic en 'Save'"
echo ""
echo "3. 🚀 Ejecutar workflow:"
echo "   - Ve a: https://github.com/giovanemere/ia-ops/actions"
echo "   - Selecciona: 'Deploy Docs to GitHub Pages (Simple)'"
echo "   - Haz clic en 'Run workflow'"
echo ""
echo "4. ✅ Verificar despliegue:"
echo "   - La documentación estará disponible en:"
echo "   - https://giovanemere.github.io/ia-ops/"
echo ""

print_success "Script completado. Sigue los pasos manuales arriba."
