#!/bin/bash

# Script para configurar secrets de Docker Hub manualmente
echo "🐳 Configuración Manual de Secrets para Docker Hub"
echo "================================================="

echo ""
echo "Como el token de GitHub no tiene permisos para gestionar secrets,"
echo "necesitas configurarlos manualmente en la interfaz web de GitHub."
echo ""

# Obtener información del repositorio
REPO_OWNER="giovanemere"
REPO_NAME="ia-ops"

echo "📋 Información del repositorio:"
echo "   Owner: $REPO_OWNER"
echo "   Repo: $REPO_NAME"
echo "   URL: https://github.com/$REPO_OWNER/$REPO_NAME"

echo ""
echo "🔗 Ve a la configuración de secrets:"
echo "   https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"

echo ""
echo "🔑 Secrets que necesitas configurar:"
echo ""
echo "1. DOCKER_HUB_USERNAME"
echo "   Valor: giovanemere"
echo ""
echo "2. DOCKER_HUB_TOKEN"
echo "   Valor: [Tu Docker Hub Access Token]"
echo ""

echo "📝 Pasos para crear el Access Token en Docker Hub:"
echo "1. Ve a: https://hub.docker.com/settings/security"
echo "2. Click en 'New Access Token'"
echo "3. Nombre: 'github-actions-ia-ops'"
echo "4. Permisos: 'Read, Write, Delete'"
echo "5. Click 'Generate'"
echo "6. Copia el token generado"
echo ""

echo "⚠️  IMPORTANTE:"
echo "   - Usa un Access Token, NO tu password de Docker Hub"
echo "   - El token solo se muestra una vez, guárdalo bien"
echo "   - Asegúrate de que tenga permisos 'Read, Write, Delete'"

echo ""
echo "🧪 Una vez configurados los secrets, puedes probar el workflow:"
echo "   1. Ve a: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   2. Selecciona 'Push to Docker Hub'"
echo "   3. Click en 'Run workflow'"
echo "   4. Selecciona branch 'trunk'"
echo "   5. Click en 'Run workflow'"

echo ""
echo "🔍 O puedes activarlo automáticamente haciendo un push:"
echo "   git push origin trunk"

echo ""
echo "📊 Monitoreo:"
echo "   - GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/docker-hub-push.yml"
echo "   - Docker Hub: https://hub.docker.com/r/giovanemere/ia-ops-backstage"

echo ""
echo "✅ Una vez configurado, el workflow se ejecutará automáticamente"
echo "   en cada push a 'trunk' que modifique archivos de Backstage."
