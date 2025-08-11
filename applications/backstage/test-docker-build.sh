#!/bin/bash

# Script para probar el build de Docker localmente
set -e

echo "🐳 Probando build de Docker para Backstage..."

# Cambiar al directorio de Backstage
cd "$(dirname "$0")"

# Verificar archivos necesarios
echo "📋 Verificando archivos necesarios..."
required_files=(
    "package.json"
    "yarn.lock"
    ".yarnrc.yml"
    "Dockerfile.optimized"
    "app-config.yaml"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file existe"
    else
        echo "❌ $file no encontrado"
        exit 1
    fi
done

# Verificar directorio packages
if [[ -d "packages" ]]; then
    echo "✅ Directorio packages existe"
else
    echo "❌ Directorio packages no encontrado"
    exit 1
fi

# Verificar directorio .yarn
if [[ -d ".yarn" ]]; then
    echo "✅ Directorio .yarn existe"
else
    echo "❌ Directorio .yarn no encontrado"
    exit 1
fi

echo ""
echo "🏗️ Iniciando build de Docker..."

# Build de la imagen
docker build -f Dockerfile.optimized -t backstage-test:latest .

if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Build completado exitosamente!"
    echo "🎉 Imagen creada: backstage-test:latest"
    
    # Mostrar información de la imagen
    echo ""
    echo "📊 Información de la imagen:"
    docker images backstage-test:latest
    
    echo ""
    echo "🧪 Para probar la imagen ejecuta:"
    echo "docker run -p 7007:7007 backstage-test:latest"
else
    echo ""
    echo "❌ Build falló"
    exit 1
fi
