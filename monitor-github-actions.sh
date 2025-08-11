#!/bin/bash

# Script para monitorear workflows de GitHub Actions
set -e

echo "🔍 Monitoreando GitHub Actions para ia-ops"
echo "=========================================="

# Configuración
REPO_OWNER="giovanemere"
REPO_NAME="ia-ops"
BRANCH="trunk"

echo ""
echo "📊 Información del repositorio:"
echo "   Owner: $REPO_OWNER"
echo "   Repo: $REPO_NAME"
echo "   Branch: $BRANCH"

echo ""
echo "🔗 Enlaces útiles:"
echo "   📋 Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   🌿 Branch: https://github.com/$REPO_OWNER/$REPO_NAME/tree/$BRANCH"
echo "   📝 Commits: https://github.com/$REPO_OWNER/$REPO_NAME/commits/$BRANCH"

echo ""
echo "🎯 Workflows específicos a monitorear:"
echo "   🏗️ Build Backstage: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/backstage-build.yml"
echo "   🔧 Main CI: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/main-ci.yml"
echo "   ✅ Trunk Validation: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/trunk-validation.yml"

echo ""
echo "📋 Workflows disponibles en el repositorio:"

# Listar workflows disponibles
if [[ -d ".github/workflows" ]]; then
    for workflow in .github/workflows/*.yml; do
        if [[ -f "$workflow" ]]; then
            workflow_name=$(basename "$workflow" .yml)
            echo "   📄 $workflow_name"
            
            # Extraer el nombre del workflow del archivo
            display_name=$(grep "^name:" "$workflow" | head -1 | cut -d: -f2- | sed 's/^ *//')
            if [[ -n "$display_name" ]]; then
                echo "      🏷️  $display_name"
            fi
            
            # Verificar triggers
            if grep -q "push:" "$workflow"; then
                echo "      🚀 Trigger: push"
            fi
            if grep -q "pull_request:" "$workflow"; then
                echo "      🔄 Trigger: pull_request"
            fi
            if grep -q "workflow_dispatch:" "$workflow"; then
                echo "      🎮 Trigger: manual"
            fi
            echo ""
        fi
    done
else
    echo "   ❌ Directorio .github/workflows no encontrado"
fi

echo ""
echo "🕐 Último commit:"
git log --oneline -1

echo ""
echo "⏰ Esperando que se activen los workflows..."
echo "   (Los workflows pueden tardar unos minutos en aparecer)"

echo ""
echo "🔍 Para verificar el estado manualmente:"
echo "   1. Ve a: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   2. Busca el workflow 'Build Backstage'"
echo "   3. Verifica que esté ejecutándose o completado"

echo ""
echo "📱 Comandos útiles:"
echo "   # Ver logs de git recientes"
echo "   git log --oneline -5"
echo ""
echo "   # Ver estado de archivos"
echo "   git status"
echo ""
echo "   # Ver diferencias del último commit"
echo "   git show --stat"

echo ""
echo "🎯 Qué buscar en el workflow 'Build Backstage':"
echo "   ✅ Checkout exitoso"
echo "   ✅ Setup Docker Buildx exitoso"
echo "   ✅ Login to Container Registry exitoso"
echo "   ✅ Extract metadata exitoso"
echo "   ✅ Build and push exitoso (este era el que fallaba antes)"

echo ""
echo "❌ Si el workflow falla, revisa:"
echo "   1. Los logs del step 'Build and push'"
echo "   2. Que Dockerfile.optimized exista y sea válido"
echo "   3. Que las dependencias se instalen correctamente"
echo "   4. Que el contexto de build sea correcto"

echo ""
echo "🔧 Para debugging adicional:"
echo "   ./applications/backstage/diagnose-github-build.sh"
echo "   ./applications/backstage/test-docker-build.sh"

echo ""
echo "✅ Monitoreo configurado. Revisa los enlaces arriba para ver el progreso."
