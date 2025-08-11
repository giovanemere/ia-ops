#!/bin/bash

# Script de diagnóstico para GitHub Actions Build
set -e

echo "🔍 Diagnóstico de configuración para GitHub Actions Build"
echo "========================================================"

# Cambiar al directorio de Backstage
cd "$(dirname "$0")"

echo ""
echo "📁 Verificando estructura de archivos..."

# Verificar archivos críticos
critical_files=(
    "package.json"
    "yarn.lock"
    ".yarnrc.yml"
    "Dockerfile"
    "Dockerfile.optimized"
    ".dockerignore"
    "app-config.yaml"
)

for file in "${critical_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
        # Mostrar tamaño del archivo
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "   📏 Tamaño: $size"
    else
        echo "❌ $file - FALTANTE"
    fi
done

echo ""
echo "📂 Verificando directorios..."

critical_dirs=(
    "packages"
    ".yarn"
    ".yarn/releases"
)

for dir in "${critical_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir/"
        # Contar archivos en el directorio
        count=$(find "$dir" -type f | wc -l)
        echo "   📊 Archivos: $count"
    else
        echo "❌ $dir/ - FALTANTE"
    fi
done

echo ""
echo "🔧 Verificando configuración de Yarn..."

if [[ -f ".yarnrc.yml" ]]; then
    echo "📄 Contenido de .yarnrc.yml:"
    cat .yarnrc.yml | sed 's/^/   /'
fi

echo ""
echo "📦 Verificando package.json..."

if [[ -f "package.json" ]]; then
    echo "🏷️  Nombre del proyecto:"
    jq -r '.name // "No definido"' package.json | sed 's/^/   /'
    
    echo "🔢 Versión:"
    jq -r '.version // "No definido"' package.json | sed 's/^/   /'
    
    echo "⚙️  Engines:"
    jq -r '.engines // "No definido"' package.json | sed 's/^/   /'
    
    echo "📋 Scripts principales:"
    jq -r '.scripts | keys[] | select(. | test("build|start"))' package.json | sed 's/^/   - /'
fi

echo ""
echo "🐳 Verificando Dockerfiles..."

for dockerfile in "Dockerfile" "Dockerfile.optimized"; do
    if [[ -f "$dockerfile" ]]; then
        echo "📄 $dockerfile:"
        echo "   🏷️  FROM statements:"
        grep "^FROM" "$dockerfile" | sed 's/^/      /'
        echo "   📂 WORKDIR:"
        grep "^WORKDIR" "$dockerfile" | sed 's/^/      /'
        echo "   🚪 EXPOSE:"
        grep "^EXPOSE" "$dockerfile" | sed 's/^/      /' || echo "      No EXPOSE found"
    fi
done

echo ""
echo "🔍 Verificando workflow de GitHub Actions..."

workflow_file="../../.github/workflows/backstage-build.yml"
if [[ -f "$workflow_file" ]]; then
    echo "✅ Workflow encontrado"
    echo "   🏷️  Dockerfile referenciado:"
    grep "file:" "$workflow_file" | sed 's/^/      /'
    echo "   🎯 Triggers:"
    grep -A 5 "^on:" "$workflow_file" | sed 's/^/      /'
else
    echo "❌ Workflow no encontrado en $workflow_file"
fi

echo ""
echo "💾 Verificando espacio en disco..."
df -h . | tail -1 | awk '{print "   Disponible: " $4 " de " $2}'

echo ""
echo "🧪 Verificando Node.js y Yarn..."
if command -v node &> /dev/null; then
    echo "   Node.js: $(node --version)"
else
    echo "   ❌ Node.js no encontrado"
fi

if command -v yarn &> /dev/null; then
    echo "   Yarn: $(yarn --version)"
else
    echo "   ❌ Yarn no encontrado"
fi

echo ""
echo "🎯 Recomendaciones:"
echo "   1. Asegúrate de que todos los archivos críticos estén presentes"
echo "   2. Verifica que el workflow referencie el Dockerfile correcto"
echo "   3. Confirma que las versiones de Node.js sean consistentes"
echo "   4. Revisa que .dockerignore excluya archivos innecesarios"

echo ""
echo "✅ Diagnóstico completado"
