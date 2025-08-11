#!/bin/bash

# Script para verificar la imagen privada en Docker Hub
set -e

echo "🔍 Verificación de Docker Hub (Privado) - IA-Ops Backstage"
echo "=========================================================="

# Configuración
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-giovanemere}"
DOCKER_HUB_REPO="$DOCKER_HUB_USERNAME/ia-ops-backstage-private"

echo ""
echo "📊 Información:"
echo "   Docker Hub Repo: $DOCKER_HUB_REPO (PRIVADO)"
echo "   Docker Hub URL: https://hub.docker.com/r/$DOCKER_HUB_REPO"

# Verificar que Docker esté corriendo
if ! docker info &> /dev/null; then
    echo "❌ Docker no está corriendo"
    exit 1
fi

echo "✅ Docker está corriendo"

# Verificar autenticación
echo ""
echo "🔐 Verificando autenticación con Docker Hub..."
if ! docker info | grep -q "Username:"; then
    echo "❌ No estás autenticado con Docker Hub"
    echo "   Para repositorios privados necesitas autenticarte:"
    echo "   docker login"
    exit 1
fi

echo "✅ Autenticado con Docker Hub"

# Función para verificar si una imagen privada existe
check_private_image() {
    local image=$1
    echo "🔍 Verificando: $image (PRIVADO)"
    
    # Para repositorios privados, intentamos hacer pull para verificar
    if docker pull "$image" &> /dev/null; then
        echo "✅ Imagen privada existe: $image"
        
        # Obtener información de la imagen
        local size=$(docker images "$image" --format "{{.Size}}")
        local created=$(docker images "$image" --format "{{.CreatedAt}}")
        
        echo "   📏 Tamaño: $size"
        echo "   📅 Creado: $created"
        
        return 0
    else
        echo "❌ Imagen privada no encontrada o sin acceso: $image"
        return 1
    fi
}

# Verificar tags comunes
echo ""
echo "🏷️ Verificando tags disponibles (PRIVADOS)..."

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
    if check_private_image "$tag"; then
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
    echo "✅ Tags privados disponibles:"
    for tag in "${available_tags[@]}"; do
        echo "   - $tag"
    done
    
    echo ""
    echo "🧪 Comandos para usar (REPOSITORIO PRIVADO):"
    echo "   # Autenticarse (requerido)"
    echo "   docker login"
    echo ""
    echo "   # Pull de la imagen privada"
    echo "   docker pull ${available_tags[0]}"
    echo ""
    echo "   # Ejecutar la imagen"
    echo "   docker run -p 7007:7007 ${available_tags[0]}"
    echo ""
    echo "   # Inspeccionar la imagen"
    echo "   docker inspect ${available_tags[0]}"
    
    echo ""
    echo "🔗 Enlaces útiles:"
    echo "   Docker Hub (Privado): https://hub.docker.com/r/$DOCKER_HUB_REPO"
    echo "   Tags (Privados): https://hub.docker.com/r/$DOCKER_HUB_REPO/tags"
    
    echo ""
    echo "🔒 Información de Seguridad:"
    echo "   - Este es un repositorio PRIVADO"
    echo "   - Solo usuarios autorizados pueden acceder"
    echo "   - Requiere 'docker login' antes de pull"
    echo "   - No aparece en búsquedas públicas"
    
    echo ""
    echo "✅ Verificación completada - Imágenes privadas disponibles en Docker Hub"
else
    echo ""
    echo "❌ No se encontraron imágenes privadas en Docker Hub"
    echo ""
    echo "🔧 Posibles causas:"
    echo "   1. El repositorio privado no existe aún"
    echo "   2. No tienes permisos para acceder al repositorio"
    echo "   3. No estás autenticado con Docker Hub"
    echo "   4. El workflow de GitHub Actions no se ha ejecutado"
    
    echo ""
    echo "🔧 Posibles soluciones:"
    echo "   1. Ejecutar el workflow de GitHub Actions"
    echo "   2. Hacer push manual con: ./applications/backstage/push-to-docker-hub-private.sh"
    echo "   3. Verificar autenticación: docker login"
    echo "   4. Crear el repositorio privado en Docker Hub manualmente"
    
    exit 1
fi

# Función para probar pull de una imagen privada
test_private_pull() {
    local image=$1
    echo ""
    echo "🧪 ¿Quieres probar hacer pull de la imagen privada? (y/N)"
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
            
            echo ""
            echo "🔒 Verificando visibilidad:"
            if docker inspect "$image" | jq -r '.[0].Config.Labels."org.opencontainers.image.visibility"' | grep -q "private"; then
                echo "✅ Confirmado: Imagen marcada como privada"
            else
                echo "⚠️  Advertencia: Imagen no marcada explícitamente como privada"
            fi
            
        else
            echo "❌ Pull falló - Verifica autenticación y permisos"
        fi
    fi
}

# Ofrecer probar pull si hay imágenes disponibles
if [[ ${#available_tags[@]} -gt 0 ]]; then
    test_private_pull "${available_tags[0]}"
fi
