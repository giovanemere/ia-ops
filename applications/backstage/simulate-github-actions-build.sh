#!/bin/bash

# Script para simular el build de GitHub Actions localmente
set -e

echo "🎭 Simulando build de GitHub Actions para Backstage"
echo "=================================================="

cd "$(dirname "$0")"

echo ""
echo "📋 Paso 1: Verificando prerrequisitos..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado"
    exit 1
fi

echo "✅ Docker disponible: $(docker --version)"

# Verificar Docker Buildx
if ! docker buildx version &> /dev/null; then
    echo "❌ Docker Buildx no está disponible"
    exit 1
fi

echo "✅ Docker Buildx disponible: $(docker buildx version)"

echo ""
echo "📋 Paso 2: Verificando archivos necesarios..."

required_files=(
    "Dockerfile.optimized"
    "package.json"
    "yarn.lock"
    ".yarnrc.yml"
    "app-config.yaml"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ $file - FALTANTE"
        exit 1
    fi
done

echo ""
echo "📋 Paso 3: Verificando estructura de directorios..."

required_dirs=(
    "packages"
    ".yarn"
    ".yarn/releases"
)

for dir in "${required_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir/"
    else
        echo "❌ $dir/ - FALTANTE"
        exit 1
    fi
done

echo ""
echo "📋 Paso 4: Simulando contexto de GitHub Actions..."

# Crear un directorio temporal para simular el contexto limpio
TEMP_DIR=$(mktemp -d)
echo "📁 Directorio temporal: $TEMP_DIR"

# Copiar archivos necesarios (simulando git checkout)
echo "📋 Copiando archivos al contexto temporal..."

cp -r . "$TEMP_DIR/backstage"
cd "$TEMP_DIR/backstage"

echo "✅ Contexto preparado"

echo ""
echo "📋 Paso 5: Verificando .dockerignore..."

if [[ -f ".dockerignore" ]]; then
    echo "✅ .dockerignore encontrado"
    echo "📄 Contenido de .dockerignore:"
    head -10 .dockerignore | sed 's/^/   /'
    echo "   ..."
else
    echo "⚠️ .dockerignore no encontrado"
fi

echo ""
echo "📋 Paso 6: Simulando Docker Buildx setup..."

# Crear un builder si no existe
if ! docker buildx ls | grep -q "github-actions-sim"; then
    echo "🔧 Creando builder para simulación..."
    docker buildx create --name github-actions-sim --use
else
    echo "✅ Builder github-actions-sim ya existe"
    docker buildx use github-actions-sim
fi

echo ""
echo "📋 Paso 7: Iniciando build (solo amd64 para prueba local)..."

echo "🏗️ Ejecutando: docker buildx build -f Dockerfile.optimized -t backstage-github-sim:latest --platform linux/amd64 ."

# Ejecutar el build con output detallado
if docker buildx build \
    -f Dockerfile.optimized \
    -t backstage-github-sim:latest \
    --platform linux/amd64 \
    --progress=plain \
    . ; then
    
    echo ""
    echo "✅ Build completado exitosamente!"
    
    echo ""
    echo "📊 Información de la imagen:"
    docker images backstage-github-sim:latest
    
    echo ""
    echo "🔍 Inspeccionando la imagen..."
    docker inspect backstage-github-sim:latest | jq -r '.[0].Config.ExposedPorts // "No ports exposed"'
    
    echo ""
    echo "🧪 Probando la imagen (inicio rápido)..."
    
    # Probar que la imagen se puede ejecutar
    if timeout 30s docker run --rm backstage-github-sim:latest node --version; then
        echo "✅ La imagen puede ejecutar Node.js"
    else
        echo "⚠️ No se pudo verificar Node.js en la imagen (timeout o error)"
    fi
    
else
    echo ""
    echo "❌ Build falló!"
    echo ""
    echo "🔍 Posibles causas:"
    echo "   1. Problemas con dependencias en package.json"
    echo "   2. Errores en Dockerfile.optimized"
    echo "   3. Problemas con Yarn o Node.js"
    echo "   4. Archivos faltantes en el contexto"
    
    echo ""
    echo "🛠️ Para debugging:"
    echo "   1. Revisa los logs arriba"
    echo "   2. Ejecuta: ./diagnose-github-build.sh"
    echo "   3. Verifica manualmente: docker build -f Dockerfile.optimized ."
    
    # Limpiar
    cd /
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo ""
echo "📋 Paso 8: Limpieza..."

cd /
rm -rf "$TEMP_DIR"

# Limpiar builder temporal
docker buildx rm github-actions-sim || true

echo "✅ Limpieza completada"

echo ""
echo "🎉 Simulación completada exitosamente!"
echo ""
echo "📊 Resumen:"
echo "   ✅ Todos los archivos necesarios están presentes"
echo "   ✅ Docker build funciona correctamente"
echo "   ✅ La imagen se crea sin errores"
echo "   ✅ El contexto simula correctamente GitHub Actions"

echo ""
echo "🚀 El build de GitHub Actions debería funcionar correctamente!"
echo ""
echo "🔗 Monitorea el progreso en:"
echo "   https://github.com/giovanemere/ia-ops/actions/workflows/backstage-build.yml"
