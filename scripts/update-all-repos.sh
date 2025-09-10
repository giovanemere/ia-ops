#!/bin/bash

set -e

# Configuración
BASE_DIR="/home/giovanemere/ia-ops"
RELEASE_VERSION="v1.3.0"
RELEASE_MESSAGE="IA-Ops v1.3.0 - Gestión Inteligente de Servicios y Auto-Reinicio"

# Lista de repositorios
REPOS=(
    "ia-ops"
    "ia-ops-postgress"
    "ia-ops-minio"
    "ia-ops-dev-core"
    "ia-ops-openai"
    "ia-ops-veritas"
    "ia-ops-docs"
    "ia-ops-backstage"
    "ia-ops-framework"
    "ia-ops-guard"
)

echo "🚀 IA-Ops Release Manager v1.3.0"
echo "================================="
echo ""
echo "📋 Repositorios a actualizar: ${#REPOS[@]}"
echo "🏷️  Nueva versión: $RELEASE_VERSION"
echo ""

# Función para actualizar un repositorio
update_repo() {
    local repo=$1
    local repo_path
    
    # El repositorio principal está en el directorio base
    if [ "$repo" = "ia-ops" ]; then
        repo_path="$BASE_DIR"
    else
        repo_path="$BASE_DIR/$repo"
    fi
    
    if [ ! -d "$repo_path" ]; then
        echo "❌ $repo - Directorio no encontrado"
        return 1
    fi
    
    echo "📦 Procesando $repo..."
    cd "$repo_path"
    
    # Verificar si es un repositorio git
    if [ ! -d ".git" ]; then
        echo "⚠️  $repo - No es un repositorio git, saltando..."
        return 0
    fi
    
    # Verificar estado del repositorio
    if ! git status &>/dev/null; then
        echo "❌ $repo - Error en git status"
        return 1
    fi
    
    # Agregar todos los cambios
    git add .
    
    # Verificar si hay cambios para commit
    if git diff --staged --quiet; then
        echo "✅ $repo - Sin cambios para commit"
    else
        # Hacer commit
        git commit -m "feat: $RELEASE_MESSAGE

- Gestión inteligente de servicios con manage.sh
- Políticas de auto-reinicio configuradas
- Health checks mejorados
- Integración completa entre servicios
- Scripts de gestión optimizados"
        echo "✅ $repo - Cambios commiteados"
    fi
    
    # Push a GitHub
    if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
        echo "✅ $repo - Push exitoso"
    else
        echo "⚠️  $repo - Error en push (verificar remote)"
    fi
    
    # Crear tag y release
    if git tag -a "$RELEASE_VERSION" -m "$RELEASE_MESSAGE" 2>/dev/null; then
        echo "✅ $repo - Tag $RELEASE_VERSION creado"
        
        if git push origin "$RELEASE_VERSION" 2>/dev/null; then
            echo "✅ $repo - Release $RELEASE_VERSION publicado"
        else
            echo "⚠️  $repo - Error publicando release"
        fi
    else
        echo "⚠️  $repo - Tag ya existe o error creando tag"
    fi
    
    echo ""
}

# Procesar todos los repositorios
echo "🔄 Iniciando actualización de repositorios..."
echo ""

for repo in "${REPOS[@]}"; do
    update_repo "$repo"
done

echo "📊 RESUMEN FINAL"
echo "================"
echo "✅ Proceso completado para ${#REPOS[@]} repositorios"
echo "🏷️  Release: $RELEASE_VERSION"
echo "📝 Mensaje: $RELEASE_MESSAGE"
echo ""
echo "🌐 Verificar en GitHub:"
for repo in "${REPOS[@]}"; do
    echo "   https://github.com/giovanemere/$repo/releases"
done
