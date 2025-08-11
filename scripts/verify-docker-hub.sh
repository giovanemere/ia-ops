#!/bin/bash

# Script para verificar la imagen en Docker Hub
set -e

echo "🔍 Verificación de Docker Hub - IA-Ops Backstage"
echo "==============================================="

# Configuración
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-giovanemere}"
DOCKER_HUB_REPO="$DOCKER_HUB_USERNAME/ia-ops-backstage"

echo ""
echo "📊 Información:"
echo "   Docker Hub Repo: $DOCKER_HUB_REPO"
echo "   Docker Hub URL: https://hub.docker.com/r/$DOCKER_HUB_REPO"

# Verificar que Docker esté corriendo
if ! docker info &> /dev/null; then
    echo "❌ Docker no está corriendo"
    exit 1
fi

echo "✅ Docker está corriendo"

# Función para verificar si una imagen existe
check_image() {
    local image=$1
    echo "🔍 Verificando: $image"
    
    if docker manifest inspect "$image" &> /dev/null; then
        echo "✅ Imagen existe: $image"
        
        # Obtener información de la imagen
        local size=$(docker manifest inspect "$image" | jq -r '.config.size // "N/A"')
        local digest=$(docker manifest inspect "$image" | jq -r '.config.digest // "N/A"')
        
        echo "   📏 Tamaño config: $size bytes"
        echo "   🔑 Digest: ${digest:0:20}..."
        
        return 0
    else
        echo "❌ Imagen no encontrada: $image"
        return 1
    fi
}

# Verificar tags comunes
echo ""
echo "🏷️ Verificando tags disponibles..."

TAGS_TO_CHECK=(
    "$DOCKER_HUB_REPO:latest"
    "$DOCKER_HUB_REPO:stable"
)

# Agregar tag de branch actual si estamos en un repo git
if git rev-parse --git-dir &> /dev/null; then
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ -n "$CURRENT_BRANCH" ]]; then
        TAGS_TO_CHECK+=("$DOCKER_HUB_REPO:$CURRENT_BRANCH")
    fi
fi

available_tags=()
for tag in "${TAGS_TO_CHECK[@]}"; do
    if check_image "$tag"; then
        available_tags+=("$tag")
    fi
    echo ""
done

# Mostrar resumen
echo "📋 Resumen de verificación:"
echo "   Total tags verificados: ${#TAGS_TO_CHECK[@]}"
echo "   Tags disponibles: ${#available_tags[@]}"

if [[ ${#available_tags[@]} -gt 0 ]]; then
    echo ""
    echo "✅ Tags disponibles:"
    for tag in "${available_tags[@]}"; do
        echo "   - $tag"
    done
    
    echo ""
    echo "🧪 Comandos para probar:"
    echo "   # Pull de la imagen"
    echo "   docker pull ${available_tags[0]}"
    echo ""
    echo "   # Ejecutar la imagen"
    echo "   docker run -p 7007:7007 ${available_tags[0]}"
    echo ""
    echo "   # Inspeccionar la imagen"
    echo "   docker inspect ${available_tags[0]}"
    
    echo ""
    echo "🔗 Enlaces útiles:"
    echo "   Docker Hub: https://hub.docker.com/r/$DOCKER_HUB_REPO"
    echo "   Tags: https://hub.docker.com/r/$DOCKER_HUB_REPO/tags"
    
    echo ""
    echo "✅ Verificación completada - Imágenes disponibles en Docker Hub"
else
    echo ""
    echo "❌ No se encontraron imágenes en Docker Hub"
    echo ""
    echo "🔧 Posibles soluciones:"
    echo "   1. Ejecutar el workflow de GitHub Actions"
    echo "   2. Hacer push manual con: ./applications/backstage/push-to-docker-hub.sh"
    echo "   3. Verificar credenciales de Docker Hub"
    echo "   4. Revisar logs de GitHub Actions"
    
    exit 1
fi

# Función para probar pull de una imagen
test_pull() {
    local image=$1
    echo ""
    echo "🧪 ¿Quieres probar hacer pull de la imagen? (y/N)"
    read -p "Imagen: $image: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📥 Haciendo pull de $image..."
        if docker pull "$image"; then
            echo "✅ Pull exitoso"
            
            # Mostrar información de la imagen local
            echo ""
            echo "📊 Información de la imagen local:"
            docker images "$image" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
            
            echo ""
            echo "🔍 Labels de la imagen:"
            docker inspect "$image" | jq -r '.[0].Config.Labels // {} | to_entries[] | "   \(.key): \(.value)"'
            
        else
            echo "❌ Pull falló"
        fi
    fi
}

# Ofrecer probar pull si hay imágenes disponibles
if [[ ${#available_tags[@]} -gt 0 ]]; then
    test_pull "${available_tags[0]}"
fi
