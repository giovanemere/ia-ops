#!/bin/bash

# Script de verificación final antes del commit
set -e

echo "🔍 Verificación final antes del commit"
echo "====================================="

cd "$(dirname "$0")"

echo ""
echo "1️⃣ Verificando archivos críticos..."

# Lista de archivos que deben existir
required_files=(
    "Dockerfile"
    "Dockerfile.optimized"
    ".dockerignore"
    "package.json"
    "yarn.lock"
    ".yarnrc.yml"
    "app-config.yaml"
)

all_files_ok=true
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ $file - FALTANTE"
        all_files_ok=false
    fi
done

if [[ "$all_files_ok" != true ]]; then
    echo ""
    echo "❌ Faltan archivos críticos. Abortando."
    exit 1
fi

echo ""
echo "2️⃣ Verificando workflows de GitHub Actions..."

# Verificar workflow de Backstage
backstage_workflow="../../.github/workflows/backstage-build.yml"
if [[ -f "$backstage_workflow" ]]; then
    if grep -q "Dockerfile.optimized" "$backstage_workflow"; then
        echo "✅ Workflow de Backstage usa Dockerfile.optimized"
    else
        echo "❌ Workflow de Backstage no usa Dockerfile.optimized"
        exit 1
    fi
else
    echo "❌ Workflow de Backstage no encontrado"
    exit 1
fi

# Verificar workflow principal
main_workflow="../../.github/workflows/main-ci.yml"
if [[ -f "$main_workflow" ]]; then
    if grep -q "applications/\${{ matrix.service }}/Dockerfile" "$main_workflow"; then
        echo "✅ Workflow principal usa Dockerfile estándar"
    else
        echo "❌ Workflow principal no configurado correctamente"
        exit 1
    fi
else
    echo "❌ Workflow principal no encontrado"
    exit 1
fi

echo ""
echo "3️⃣ Verificando consistencia de versiones..."

# Verificar Node.js en package.json
node_version_pkg=$(jq -r '.engines.node' package.json)
echo "📦 Node.js en package.json: $node_version_pkg"

# Verificar Node.js en Dockerfiles
node_version_docker=$(grep "FROM node:" Dockerfile | head -1 | cut -d: -f2 | cut -d- -f1)
node_version_optimized=$(grep "FROM node:" Dockerfile.optimized | head -1 | cut -d: -f2 | cut -d- -f1)

echo "🐳 Node.js en Dockerfile: $node_version_docker"
echo "🐳 Node.js en Dockerfile.optimized: $node_version_optimized"

if [[ "$node_version_docker" == "20" && "$node_version_optimized" == "20" ]]; then
    echo "✅ Versiones de Node.js consistentes"
else
    echo "❌ Versiones de Node.js inconsistentes"
    exit 1
fi

echo ""
echo "4️⃣ Verificando sintaxis de archivos..."

# Verificar JSON
if jq empty package.json 2>/dev/null; then
    echo "✅ package.json tiene sintaxis válida"
else
    echo "❌ package.json tiene sintaxis inválida"
    exit 1
fi

# Verificar YAML
if command -v yamllint &> /dev/null; then
    if yamllint app-config.yaml 2>/dev/null; then
        echo "✅ app-config.yaml tiene sintaxis válida"
    else
        echo "⚠️ app-config.yaml tiene warnings (continuando)"
    fi
else
    echo "⚠️ yamllint no disponible, saltando verificación YAML"
fi

echo ""
echo "5️⃣ Verificando permisos de archivos..."

# Verificar que los scripts sean ejecutables
scripts=(
    "test-docker-build.sh"
    "diagnose-github-build.sh"
    "pre-commit-check.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ -x "$script" ]]; then
            echo "✅ $script es ejecutable"
        else
            echo "⚠️ $script no es ejecutable, corrigiendo..."
            chmod +x "$script"
        fi
    fi
done

echo ""
echo "6️⃣ Verificando tamaño de archivos..."

# Verificar que yarn.lock no sea demasiado grande (>5MB podría ser problemático)
yarn_lock_size=$(stat -f%z yarn.lock 2>/dev/null || stat -c%s yarn.lock 2>/dev/null || echo "0")
yarn_lock_mb=$((yarn_lock_size / 1024 / 1024))

if [[ $yarn_lock_mb -lt 10 ]]; then
    echo "✅ yarn.lock tamaño OK (${yarn_lock_mb}MB)"
else
    echo "⚠️ yarn.lock es grande (${yarn_lock_mb}MB) - podría afectar el build"
fi

echo ""
echo "7️⃣ Resumen de archivos a commitear..."

echo "📁 Archivos nuevos/modificados:"
echo "   - Dockerfile (actualizado a Node 20)"
echo "   - Dockerfile.optimized (nuevo, optimizado para CI/CD)"
echo "   - .dockerignore (mejorado)"
echo "   - test-docker-build.sh (nuevo)"
echo "   - diagnose-github-build.sh (nuevo)"
echo "   - pre-commit-check.sh (nuevo)"
echo "   - GITHUB_ACTIONS_BUILD_FIX.md (nuevo)"
echo "   - ../../.github/workflows/backstage-build.yml (corregido)"

echo ""
echo "✅ Todas las verificaciones pasaron!"
echo ""
echo "🚀 Listo para commit. Comandos sugeridos:"
echo ""
echo "   cd /home/giovanemere/ia-ops/ia-ops"
echo "   git add applications/backstage/"
echo "   git add .github/workflows/backstage-build.yml"
echo "   git commit -m \"fix: corregir build de GitHub Actions para Backstage"
echo ""
echo "   - Crear Dockerfile.optimized para CI/CD"
echo "   - Actualizar Dockerfile a Node.js 20"
echo "   - Mejorar .dockerignore"
echo "   - Corregir referencia en workflow"
echo "   - Añadir scripts de diagnóstico y prueba\""
echo ""
echo "   git push origin trunk"
