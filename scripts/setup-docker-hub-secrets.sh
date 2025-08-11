#!/bin/bash

# Script para configurar secrets de Docker Hub en GitHub
set -e

echo "🐳 Configuración de Docker Hub para GitHub Actions"
echo "================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}📋 Información necesaria:${NC}"
echo "   1. Username de Docker Hub"
echo "   2. Access Token de Docker Hub (no password)"
echo "   3. GitHub CLI instalado y autenticado"

echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "   - Usa un Access Token, NO tu password de Docker Hub"
echo "   - El token debe tener permisos de 'Read, Write, Delete'"
echo "   - Puedes crear un token en: https://hub.docker.com/settings/security"

echo ""
read -p "¿Continuar con la configuración? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuración cancelada."
    exit 1
fi

# Verificar que GitHub CLI esté instalado
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI no está instalado${NC}"
    echo "   Instala desde: https://cli.github.com/"
    exit 1
fi

# Verificar autenticación con GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ No estás autenticado con GitHub CLI${NC}"
    echo "   Ejecuta: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI configurado correctamente${NC}"

# Obtener información del repositorio
REPO_INFO=$(gh repo view --json owner,name)
REPO_OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO_NAME=$(echo $REPO_INFO | jq -r '.name')

echo ""
echo -e "${BLUE}📊 Repositorio detectado:${NC}"
echo "   Owner: $REPO_OWNER"
echo "   Repo: $REPO_NAME"

# Solicitar credenciales de Docker Hub
echo ""
echo -e "${BLUE}🔐 Configuración de credenciales:${NC}"

read -p "Docker Hub Username: " DOCKER_USERNAME
if [[ -z "$DOCKER_USERNAME" ]]; then
    echo -e "${RED}❌ Username es requerido${NC}"
    exit 1
fi

echo ""
echo "Docker Hub Access Token:"
echo "  - Ve a: https://hub.docker.com/settings/security"
echo "  - Crea un nuevo token con permisos 'Read, Write, Delete'"
echo "  - Copia el token (NO tu password)"
echo ""
read -s -p "Docker Hub Access Token: " DOCKER_TOKEN
echo

if [[ -z "$DOCKER_TOKEN" ]]; then
    echo -e "${RED}❌ Access Token es requerido${NC}"
    exit 1
fi

# Configurar secrets en GitHub
echo ""
echo -e "${BLUE}🔧 Configurando secrets en GitHub...${NC}"

# DOCKER_HUB_USERNAME
if gh secret set DOCKER_HUB_USERNAME --body "$DOCKER_USERNAME"; then
    echo -e "${GREEN}✅ DOCKER_HUB_USERNAME configurado${NC}"
else
    echo -e "${RED}❌ Error configurando DOCKER_HUB_USERNAME${NC}"
    exit 1
fi

# DOCKER_HUB_TOKEN
if gh secret set DOCKER_HUB_TOKEN --body "$DOCKER_TOKEN"; then
    echo -e "${GREEN}✅ DOCKER_HUB_TOKEN configurado${NC}"
else
    echo -e "${RED}❌ Error configurando DOCKER_HUB_TOKEN${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Configuración completada exitosamente!${NC}"

echo ""
echo -e "${BLUE}📋 Resumen de configuración:${NC}"
echo "   Repository: $REPO_OWNER/$REPO_NAME"
echo "   Docker Hub Username: $DOCKER_USERNAME"
echo "   Docker Hub Repository: $DOCKER_USERNAME/ia-ops-backstage"

echo ""
echo -e "${BLUE}🔗 Enlaces útiles:${NC}"
echo "   Docker Hub Repo: https://hub.docker.com/r/$DOCKER_USERNAME/ia-ops-backstage"
echo "   GitHub Secrets: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo "   GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"

echo ""
echo -e "${YELLOW}📝 Próximos pasos:${NC}"
echo "   1. Verifica que los secrets estén configurados en GitHub"
echo "   2. Haz push de cambios para activar el workflow"
echo "   3. Monitorea el build en GitHub Actions"
echo "   4. Verifica la imagen en Docker Hub"

echo ""
echo -e "${BLUE}🧪 Para probar manualmente:${NC}"
echo "   gh workflow run docker-hub-push.yml"

echo ""
echo -e "${GREEN}✅ ¡Listo para usar Docker Hub!${NC}"
