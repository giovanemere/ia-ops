#!/bin/bash

# Script para hacer push manual a Docker Hub
set -e

echo "🐳 Push Manual a Docker Hub - IA-Ops Backstage"
echo "=============================================="

cd "$(dirname "$0")"

# Configuración
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-giovanemere}"
DOCKER_HUB_REPO="$DOCKER_HUB_USERNAME/ia-ops-backstage"
BUILD_DATE=$(date -u +'%Y.%m.%d')
GIT_SHA=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git branch --show-current)

echo ""
echo "📊 Configuración:"
echo "   Docker Hub Repo: $DOCKER_HUB_REPO"
echo "   Build Date: $BUILD_DATE"
echo "   Git SHA: $GIT_SHA"
echo "   Git Branch: $GIT_BRANCH"

# Verificar que Docker esté corriendo
if ! docker info &> /dev/null; then
    echo "❌ Docker no está corriendo"
    exit 1
fi

echo "✅ Docker está corriendo"

# Verificar autenticación con Docker Hub
echo ""
echo "🔐 Verificando autenticación con Docker Hub..."
if ! docker info | grep -q "Username:"; then
    echo "⚠️  No estás autenticado con Docker Hub"
    echo "   Ejecuta: docker login"
    read -p "¿Quieres autenticarte ahora? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        echo "❌ Autenticación requerida para continuar"
        exit 1
    fi
fi

echo "✅ Autenticado con Docker Hub"

# Verificar archivos necesarios
echo ""
echo "📋 Verificando archivos necesarios..."

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

# Generar tags
TAGS=(
    "$DOCKER_HUB_REPO:latest"
    "$DOCKER_HUB_REPO:$BUILD_DATE-$GIT_SHA"
    "$DOCKER_HUB_REPO:$GIT_BRANCH"
)

if [[ "$GIT_BRANCH" == "trunk" ]]; then
    TAGS+=("$DOCKER_HUB_REPO:stable")
fi

echo ""
echo "🏷️ Tags a crear:"
for tag in "${TAGS[@]}"; do
    echo "   - $tag"
done

echo ""
read -p "¿Continuar con el build y push? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operación cancelada."
    exit 1
fi

# Build de la imagen
echo ""
echo "🏗️ Construyendo imagen..."

# Construir con el primer tag
docker build \
    -f Dockerfile.optimized \
    -t "${TAGS[0]}" \
    --build-arg BUILDTIME="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VERSION="$BUILD_DATE-$GIT_SHA" \
    --build-arg REVISION="$GIT_SHA" \
    --label "org.opencontainers.image.title=IA-Ops Backstage" \
    --label "org.opencontainers.image.description=Backstage Developer Portal for IA-Ops Platform" \
    --label "org.opencontainers.image.vendor=IA-Ops Team" \
    --label "org.opencontainers.image.source=https://github.com/giovanemere/ia-ops" \
    --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --label "org.opencontainers.image.version=$BUILD_DATE-$GIT_SHA" \
    --label "org.opencontainers.image.revision=$GIT_SHA" \
    .

if [[ $? -eq 0 ]]; then
    echo "✅ Build completado exitosamente"
else
    echo "❌ Build falló"
    exit 1
fi

# Crear tags adicionales
echo ""
echo "🏷️ Creando tags adicionales..."
for i in "${!TAGS[@]}"; do
    if [[ $i -gt 0 ]]; then
        docker tag "${TAGS[0]}" "${TAGS[$i]}"
        echo "✅ Tag creado: ${TAGS[$i]}"
    fi
done

# Push de todas las tags
echo ""
echo "📤 Haciendo push a Docker Hub..."

for tag in "${TAGS[@]}"; do
    echo "📤 Pushing $tag..."
    if docker push "$tag"; then
        echo "✅ Push exitoso: $tag"
    else
        echo "❌ Push falló: $tag"
        exit 1
    fi
done

# Mostrar información de la imagen
echo ""
echo "📊 Información de la imagen:"
docker images "$DOCKER_HUB_REPO" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo "🎉 ¡Push completado exitosamente!"

echo ""
echo "🔗 Enlaces útiles:"
echo "   Docker Hub: https://hub.docker.com/r/$DOCKER_HUB_REPO"
echo "   Pull command: docker pull $DOCKER_HUB_REPO:latest"

echo ""
echo "🧪 Para probar la imagen:"
echo "   docker run -p 7007:7007 $DOCKER_HUB_REPO:latest"

echo ""
echo "📋 Tags disponibles:"
for tag in "${TAGS[@]}"; do
    echo "   - $tag"
done

echo ""
echo "✅ ¡Imagen disponible en Docker Hub!"
