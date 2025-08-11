#!/bin/bash

# 🧪 Script para validar todos los workflows de GitHub Actions
# Este script verifica que los workflows estén correctamente configurados

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}🧪 GitHub Actions Workflow Validator${NC}"
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

print_status "Iniciando validación de workflows..."

# ============================================================================
# VALIDACIÓN 1: SINTAXIS YAML
# ============================================================================

echo ""
echo "🔍 VALIDACIÓN 1: Sintaxis YAML"
echo "=============================="

yaml_errors=0
for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        echo "Validando $workflow..."
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            print_success "$(basename $workflow) - Sintaxis válida"
        else
            print_error "$(basename $workflow) - Sintaxis inválida"
            yaml_errors=$((yaml_errors + 1))
        fi
    fi
done

if [ $yaml_errors -eq 0 ]; then
    print_success "Todos los workflows tienen sintaxis YAML válida"
else
    print_error "$yaml_errors workflows tienen errores de sintaxis"
fi

# ============================================================================
# VALIDACIÓN 2: ESTRUCTURA DE ARCHIVOS REQUERIDOS
# ============================================================================

echo ""
echo "📁 VALIDACIÓN 2: Estructura de Archivos"
echo "======================================="

structure_errors=0

# Verificar directorios requeridos
required_dirs=("applications/backstage" "applications/openai-service" "applications/proxy-service" "docs")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_success "$dir - Directorio existe"
    else
        print_error "$dir - Directorio no encontrado"
        structure_errors=$((structure_errors + 1))
    fi
done

# Verificar Dockerfiles
dockerfiles=("applications/backstage/Dockerfile" "applications/openai-service/Dockerfile" "applications/proxy-service/Dockerfile")
for dockerfile in "${dockerfiles[@]}"; do
    if [ -f "$dockerfile" ]; then
        print_success "$dockerfile - Dockerfile existe"
    else
        print_error "$dockerfile - Dockerfile no encontrado"
        structure_errors=$((structure_errors + 1))
    fi
done

# Verificar configuración de MkDocs
if [ -f "mkdocs.ci.yml" ] || [ -f "mkdocs.yml" ]; then
    print_success "Configuración de MkDocs encontrada"
else
    print_warning "No se encontró configuración de MkDocs"
fi

if [ $structure_errors -eq 0 ]; then
    print_success "Estructura de archivos correcta"
else
    print_error "$structure_errors archivos/directorios requeridos no encontrados"
fi

# ============================================================================
# VALIDACIÓN 3: CONFIGURACIÓN DE WORKFLOWS
# ============================================================================

echo ""
echo "⚙️ VALIDACIÓN 3: Configuración de Workflows"
echo "==========================================="

config_errors=0

# Verificar workflows principales
main_workflows=("01-main-ci-cd.yml" "02-deploy-docs.yml" "03-release.yml")
for workflow in "${main_workflows[@]}"; do
    if [ -f ".github/workflows/$workflow" ]; then
        print_success "$workflow - Workflow principal encontrado"
        
        # Verificar que no contenga características premium
        if grep -q "upload-sarif" ".github/workflows/$workflow"; then
            print_warning "$workflow - Contiene referencias a SARIF (características premium)"
        fi
        
        # Verificar permisos básicos
        if grep -q "permissions:" ".github/workflows/$workflow"; then
            print_success "$workflow - Permisos configurados"
        else
            print_warning "$workflow - No se encontraron permisos configurados"
        fi
        
    else
        print_error "$workflow - Workflow principal no encontrado"
        config_errors=$((config_errors + 1))
    fi
done

# Verificar que no haya workflows obsoletos activos
obsolete_patterns=("sarif" "premium" "advanced-security")
for pattern in "${obsolete_patterns[@]}"; do
    if find .github/workflows -name "*.yml" -exec grep -l "$pattern" {} \; 2>/dev/null | grep -v archive; then
        print_warning "Encontrados workflows que pueden requerir características premium"
    fi
done

if [ $config_errors -eq 0 ]; then
    print_success "Configuración de workflows correcta"
else
    print_error "$config_errors problemas de configuración encontrados"
fi

# ============================================================================
# VALIDACIÓN 4: DEPENDENCIAS Y HERRAMIENTAS
# ============================================================================

echo ""
echo "🔧 VALIDACIÓN 4: Dependencias y Herramientas"
echo "==========================================="

deps_errors=0

# Verificar Python
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version)
    print_success "Python disponible: $python_version"
else
    print_error "Python3 no encontrado"
    deps_errors=$((deps_errors + 1))
fi

# Verificar Docker
if command -v docker >/dev/null 2>&1; then
    docker_version=$(docker --version)
    print_success "Docker disponible: $docker_version"
else
    print_warning "Docker no encontrado (requerido para builds locales)"
fi

# Verificar MkDocs (si está instalado)
if command -v mkdocs >/dev/null 2>&1; then
    mkdocs_version=$(mkdocs --version)
    print_success "MkDocs disponible: $mkdocs_version"
else
    print_warning "MkDocs no encontrado (se instalará en workflows)"
fi

if [ $deps_errors -eq 0 ]; then
    print_success "Dependencias básicas disponibles"
else
    print_error "$deps_errors dependencias críticas no encontradas"
fi

# ============================================================================
# VALIDACIÓN 5: SIMULACIÓN DE BUILDS
# ============================================================================

echo ""
echo "🧪 VALIDACIÓN 5: Simulación de Builds"
echo "===================================="

build_errors=0

# Test de documentación
print_status "Probando build de documentación..."
if [ -d "docs" ] && ([ -f "mkdocs.ci.yml" ] || [ -f "mkdocs.yml" ]); then
    # Crear entorno virtual temporal si no existe
    if [ ! -d "venv-test" ]; then
        python3 -m venv venv-test
    fi
    
    source venv-test/bin/activate
    pip install -q mkdocs mkdocs-material mkdocs-mermaid2-plugin 2>/dev/null || true
    
    if [ -f "mkdocs.ci.yml" ]; then
        if mkdocs build --config-file mkdocs.ci.yml --clean >/dev/null 2>&1; then
            print_success "Build de documentación exitoso"
        else
            print_error "Build de documentación falló"
            build_errors=$((build_errors + 1))
        fi
    else
        if mkdocs build --clean >/dev/null 2>&1; then
            print_success "Build de documentación exitoso"
        else
            print_error "Build de documentación falló"
            build_errors=$((build_errors + 1))
        fi
    fi
    
    deactivate
    rm -rf venv-test
else
    print_warning "No se puede probar build de documentación (archivos faltantes)"
fi

# Test de validación de archivos
print_status "Probando validación de archivos..."
yaml_test_errors=0
json_test_errors=0

# Test YAML
yaml_files=$(find . -name "*.yml" -o -name "*.yaml" | grep -v ".git" | head -10)
for file in $yaml_files; do
    if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        yaml_test_errors=$((yaml_test_errors + 1))
    fi
done

# Test JSON
json_files=$(find . -name "*.json" | grep -v ".git" | grep -v "node_modules" | head -10)
for file in $json_files; do
    if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        json_test_errors=$((json_test_errors + 1))
    fi
done

if [ $yaml_test_errors -eq 0 ] && [ $json_test_errors -eq 0 ]; then
    print_success "Validación de archivos exitosa"
else
    print_error "Errores en validación: $yaml_test_errors YAML, $json_test_errors JSON"
    build_errors=$((build_errors + 1))
fi

if [ $build_errors -eq 0 ]; then
    print_success "Simulación de builds exitosa"
else
    print_error "$build_errors problemas en simulación de builds"
fi

# ============================================================================
# RESUMEN FINAL
# ============================================================================

echo ""
echo "📊 RESUMEN DE VALIDACIÓN"
echo "========================"

total_errors=$((yaml_errors + structure_errors + config_errors + deps_errors + build_errors))

echo ""
echo "📋 Resultados por categoría:"
echo "- 🔍 Sintaxis YAML: $([ $yaml_errors -eq 0 ] && echo "✅ OK" || echo "❌ $yaml_errors errores")"
echo "- 📁 Estructura: $([ $structure_errors -eq 0 ] && echo "✅ OK" || echo "❌ $structure_errors errores")"
echo "- ⚙️ Configuración: $([ $config_errors -eq 0 ] && echo "✅ OK" || echo "❌ $config_errors errores")"
echo "- 🔧 Dependencias: $([ $deps_errors -eq 0 ] && echo "✅ OK" || echo "❌ $deps_errors errores")"
echo "- 🧪 Builds: $([ $build_errors -eq 0 ] && echo "✅ OK" || echo "❌ $build_errors errores")"

echo ""
if [ $total_errors -eq 0 ]; then
    print_success "🎉 TODOS LOS WORKFLOWS ESTÁN LISTOS PARA FUNCIONAR!"
    echo ""
    echo "✅ Próximos pasos:"
    echo "1. Hacer push para activar workflows"
    echo "2. Verificar ejecución en GitHub Actions"
    echo "3. Revisar despliegue de documentación"
    echo ""
    echo "🔗 Enlaces útiles:"
    echo "- GitHub Actions: https://github.com/giovanemere/ia-ops/actions"
    echo "- GitHub Pages: https://giovanemere.github.io/ia-ops/"
    echo "- Workflows README: .github/workflows/README.md"
else
    print_error "❌ SE ENCONTRARON $total_errors PROBLEMAS"
    echo ""
    echo "🔧 Acciones requeridas:"
    echo "1. Revisar y corregir los errores listados arriba"
    echo "2. Ejecutar este script nuevamente para verificar"
    echo "3. Una vez corregido, hacer push para probar workflows"
    echo ""
    exit 1
fi

echo ""
print_status "Validación completada. Workflows listos para usar."
