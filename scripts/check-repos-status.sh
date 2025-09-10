#!/bin/bash

BASE_DIR="/home/giovanemere/ia-ops"

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

echo "🔍 Verificando estado de repositorios..."
echo "========================================"
echo ""

for repo in "${REPOS[@]}"; do
    repo_path="$BASE_DIR/$repo"
    
    if [ ! -d "$repo_path" ]; then
        echo "❌ $repo - Directorio no encontrado"
        continue
    fi
    
    cd "$repo_path"
    
    if [ ! -d ".git" ]; then
        echo "⚠️  $repo - No es repositorio git"
        continue
    fi
    
    echo "📦 $repo:"
    
    # Estado de cambios
    if git diff --quiet && git diff --staged --quiet; then
        echo "   ✅ Sin cambios pendientes"
    else
        echo "   📝 Tiene cambios pendientes"
        git status --porcelain | head -3
    fi
    
    # Último commit
    last_commit=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null)
    echo "   📄 Último commit: $last_commit"
    
    # Remote URL
    remote_url=$(git remote get-url origin 2>/dev/null || echo "Sin remote")
    echo "   🌐 Remote: $remote_url"
    
    echo ""
done
