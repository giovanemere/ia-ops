#!/bin/bash

# Script para configurar secrets de GitHub desde archivo .env
set -e

echo "🔐 Configurando Secrets de GitHub desde .env"
echo "============================================"

cd "$(dirname "$0")"

# Verificar que el archivo .env existe
if [[ ! -f ".env" ]]; then
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

echo "✅ Archivo .env encontrado"

# Función para extraer valor de .env
get_env_value() {
    local key=$1
    grep "^${key}=" .env | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//'
}

# Leer variables de Docker Hub del .env
DOCKER_HUB_USERNAME=$(get_env_value "DOCKER_HUB_USERNAME")
DOCKER_HUB_TOKEN=$(get_env_value "DOCKER_HUB_TOKEN")

echo ""
echo "📋 Variables encontradas en .env:"
echo "   DOCKER_HUB_USERNAME: $DOCKER_HUB_USERNAME"
echo "   DOCKER_HUB_TOKEN: ${DOCKER_HUB_TOKEN:0:20}..."

# Verificar que las variables existen
if [[ -z "$DOCKER_HUB_USERNAME" ]]; then
    echo "❌ DOCKER_HUB_USERNAME no encontrado en .env"
    exit 1
fi

if [[ -z "$DOCKER_HUB_TOKEN" ]]; then
    echo "❌ DOCKER_HUB_TOKEN no encontrado en .env"
    exit 1
fi

echo ""
echo "🔧 Configurando secrets en GitHub..."

# Configurar DOCKER_HUB_USERNAME
echo "📝 Configurando DOCKER_HUB_USERNAME..."
if echo "$DOCKER_HUB_USERNAME" | gh secret set DOCKER_HUB_USERNAME; then
    echo "✅ DOCKER_HUB_USERNAME configurado exitosamente"
else
    echo "❌ Error configurando DOCKER_HUB_USERNAME"
    exit 1
fi

# Configurar DOCKER_HUB_TOKEN
echo "📝 Configurando DOCKER_HUB_TOKEN..."
if echo "$DOCKER_HUB_TOKEN" | gh secret set DOCKER_HUB_TOKEN; then
    echo "✅ DOCKER_HUB_TOKEN configurado exitosamente"
else
    echo "❌ Error configurando DOCKER_HUB_TOKEN"
    exit 1
fi

echo ""
echo "🎉 ¡Secrets configurados exitosamente!"

echo ""
echo "📋 Resumen:"
echo "   ✅ DOCKER_HUB_USERNAME = $DOCKER_HUB_USERNAME"
echo "   ✅ DOCKER_HUB_TOKEN = configurado (oculto por seguridad)"

echo ""
echo "🔗 Enlaces útiles:"
echo "   📋 GitHub Secrets: https://github.com/giovanemere/ia-ops/settings/secrets/actions"
echo "   🐳 Docker Hub Repo: https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ia-ops-backstage"
echo "   🏗️ GitHub Actions: https://github.com/giovanemere/ia-ops/actions"

echo ""
echo "🧪 Próximos pasos:"
echo "   1. Verificar secrets: gh secret list"
echo "   2. Ejecutar workflow: gh workflow run docker-hub-push.yml"
echo "   3. Monitorear: ./monitor-docker-hub-workflow.sh"
echo "   4. Verificar imagen: ./scripts/verify-docker-hub.sh"

echo ""
echo "✅ ¡Listo para usar Docker Hub!"
