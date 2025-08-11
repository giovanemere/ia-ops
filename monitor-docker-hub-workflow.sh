#!/bin/bash

# Script para monitorear el workflow de Docker Hub
echo "🐳 Monitoreo del Workflow de Docker Hub"
echo "======================================"

# Información del repositorio
REPO_OWNER="giovanemere"
REPO_NAME="ia-ops"
DOCKER_HUB_REPO="giovanemere/ia-ops-backstage"

echo ""
echo "📊 Información:"
echo "   Repository: $REPO_OWNER/$REPO_NAME"
echo "   Docker Hub: $DOCKER_HUB_REPO"
echo "   Workflow: docker-hub-push.yml"

echo ""
echo "🔗 Enlaces importantes:"
echo "   📋 GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   🐳 Docker Hub Push: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/docker-hub-push.yml"
echo "   🏗️ Build Backstage: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/backstage-build.yml"
echo "   🐳 Docker Hub Repo: https://hub.docker.com/r/$DOCKER_HUB_REPO"
echo "   🔑 GitHub Secrets: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"

echo ""
echo "📋 Estado actual:"

# Verificar último commit
echo "🕐 Último commit:"
git log --oneline -1

echo ""
echo "🔍 Workflows que deberían activarse:"
echo "   ✅ Push to Docker Hub (docker-hub-push.yml)"
echo "   ✅ Build Backstage (backstage-build.yml)"
echo "   ✅ Trunk Branch Validation (trunk-validation.yml)"

echo ""
echo "🎯 Qué buscar en el workflow 'Push to Docker Hub':"
echo "   1. ✅ Checkout code"
echo "   2. ✅ Set up Docker Buildx"
echo "   3. ✅ Login to Docker Hub (aquí puede fallar si no hay secrets)"
echo "   4. ✅ Extract metadata"
echo "   5. ✅ Build and push to Docker Hub"
echo "   6. ✅ Success notification"

echo ""
echo "❌ Posibles errores y soluciones:"
echo ""
echo "🔐 Error: 'Login to Docker Hub' falla"
echo "   Causa: Secrets no configurados o incorrectos"
echo "   Solución:"
echo "   1. Ve a: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo "   2. Configura DOCKER_HUB_USERNAME = giovanemere"
echo "   3. Configura DOCKER_HUB_TOKEN = [tu access token]"
echo ""

echo "🏗️ Error: 'Build and push' falla"
echo "   Causa: Problemas con Dockerfile.optimized"
echo "   Solución:"
echo "   1. Ejecuta: ./applications/backstage/diagnose-github-build.sh"
echo "   2. Prueba local: ./applications/backstage/simulate-github-actions-build.sh"
echo ""

echo "🐳 Error: 'unauthorized: authentication required'"
echo "   Causa: Access token inválido o sin permisos"
echo "   Solución:"
echo "   1. Ve a: https://hub.docker.com/settings/security"
echo "   2. Crea nuevo token con permisos 'Read, Write, Delete'"
echo "   3. Actualiza DOCKER_HUB_TOKEN en GitHub secrets"

echo ""
echo "🧪 Para probar manualmente:"
echo "   # Ejecutar workflow desde GitHub"
echo "   1. Ve a: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/docker-hub-push.yml"
echo "   2. Click 'Run workflow'"
echo "   3. Selecciona 'trunk'"
echo "   4. Click 'Run workflow'"
echo ""
echo "   # Probar build local"
echo "   ./applications/backstage/push-to-docker-hub.sh"

echo ""
echo "🔍 Verificar resultado:"
echo "   # Verificar imagen en Docker Hub"
echo "   ./scripts/verify-docker-hub.sh"
echo ""
echo "   # Pull manual"
echo "   docker pull $DOCKER_HUB_REPO:latest"

echo ""
echo "📱 Comandos útiles:"
echo "   # Ver workflows recientes (requiere gh cli con permisos)"
echo "   # gh run list --workflow=docker-hub-push.yml"
echo ""
echo "   # Ver logs de un run específico"
echo "   # gh run view [RUN_ID] --log"
echo ""
echo "   # Ejecutar workflow manualmente"
echo "   # gh workflow run docker-hub-push.yml"

echo ""
echo "⏰ Los workflows pueden tardar 1-2 minutos en aparecer después del push."
echo "   Revisa los enlaces arriba para monitorear el progreso."

echo ""
echo "✅ Monitoreo configurado. ¡Revisa GitHub Actions para ver el progreso!"
