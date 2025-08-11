#!/bin/bash

# Guía interactiva para configurar Docker Hub
set -e

echo "🐳 Guía de Configuración de Docker Hub para IA-Ops Backstage"
echo "==========================================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}📋 Esta guía te ayudará a configurar Docker Hub para tu proyecto${NC}"
echo ""

# Paso 1: Verificar prerrequisitos
echo -e "${BLUE}🔍 Paso 1: Verificando prerrequisitos...${NC}"

# Verificar Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker instalado${NC}"
else
    echo -e "${RED}❌ Docker no está instalado${NC}"
    echo "   Instala Docker desde: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar GitHub CLI
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✅ GitHub CLI instalado${NC}"
else
    echo -e "${RED}❌ GitHub CLI no está instalado${NC}"
    echo "   Instala desde: https://cli.github.com/"
    exit 1
fi

# Verificar autenticación con GitHub
if gh auth status &> /dev/null; then
    echo -e "${GREEN}✅ Autenticado con GitHub${NC}"
else
    echo -e "${RED}❌ No autenticado con GitHub${NC}"
    echo "   Ejecuta: gh auth login"
    exit 1
fi

echo ""
echo -e "${BLUE}🐳 Paso 2: Configuración de Docker Hub${NC}"
echo ""
echo "Necesitas:"
echo "1. Una cuenta en Docker Hub (https://hub.docker.com/)"
echo "2. Un Access Token (NO tu password)"
echo ""

read -p "¿Tienes una cuenta en Docker Hub? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}📝 Crea una cuenta en Docker Hub:${NC}"
    echo "   1. Ve a: https://hub.docker.com/signup"
    echo "   2. Crea tu cuenta"
    echo "   3. Verifica tu email"
    echo "   4. Vuelve a ejecutar este script"
    exit 0
fi

echo ""
echo -e "${BLUE}🔑 Paso 3: Crear Access Token${NC}"
echo ""
echo "Necesitas crear un Access Token en Docker Hub:"
echo ""
echo "1. Ve a: https://hub.docker.com/settings/security"
echo "2. Click en 'New Access Token'"
echo "3. Nombre: 'github-actions-ia-ops'"
echo "4. Permisos: 'Read, Write, Delete'"
echo "5. Click 'Generate'"
echo "6. COPIA el token (solo se muestra una vez)"
echo ""

read -p "¿Ya tienes tu Access Token? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}🔗 Abriendo Docker Hub Security Settings...${NC}"
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://hub.docker.com/settings/security"
    elif command -v open &> /dev/null; then
        open "https://hub.docker.com/settings/security"
    else
        echo "   Ve manualmente a: https://hub.docker.com/settings/security"
    fi
    echo ""
    echo "Vuelve a ejecutar este script cuando tengas tu token."
    exit 0
fi

echo ""
echo -e "${BLUE}📝 Paso 4: Configurar credenciales${NC}"
echo ""

# Solicitar username
read -p "Docker Hub Username: " DOCKER_USERNAME
if [[ -z "$DOCKER_USERNAME" ]]; then
    echo -e "${RED}❌ Username es requerido${NC}"
    exit 1
fi

# Solicitar token
echo ""
echo "Docker Hub Access Token (se ocultará mientras escribes):"
read -s DOCKER_TOKEN
echo

if [[ -z "$DOCKER_TOKEN" ]]; then
    echo -e "${RED}❌ Access Token es requerido${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔧 Paso 5: Configurando secrets en GitHub...${NC}"

# Configurar secrets
if gh secret set DOCKER_HUB_USERNAME --body "$DOCKER_USERNAME"; then
    echo -e "${GREEN}✅ DOCKER_HUB_USERNAME configurado${NC}"
else
    echo -e "${RED}❌ Error configurando DOCKER_HUB_USERNAME${NC}"
    exit 1
fi

if gh secret set DOCKER_HUB_TOKEN --body "$DOCKER_TOKEN"; then
    echo -e "${GREEN}✅ DOCKER_HUB_TOKEN configurado${NC}"
else
    echo -e "${RED}❌ Error configurando DOCKER_HUB_TOKEN${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🧪 Paso 6: Probar configuración${NC}"
echo ""

# Obtener info del repo
REPO_INFO=$(gh repo view --json owner,name)
REPO_OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO_NAME=$(echo $REPO_INFO | jq -r '.name')

echo "Repositorio: $REPO_OWNER/$REPO_NAME"
echo "Docker Hub Repo: $DOCKER_USERNAME/ia-ops-backstage"

echo ""
read -p "¿Quieres ejecutar el workflow manualmente para probar? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}🚀 Ejecutando workflow...${NC}"
    
    if gh workflow run docker-hub-push.yml; then
        echo -e "${GREEN}✅ Workflow iniciado${NC}"
        echo ""
        echo "🔗 Monitorea el progreso en:"
        echo "   https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/docker-hub-push.yml"
    else
        echo -e "${RED}❌ Error ejecutando workflow${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎉 ¡Configuración completada!${NC}"
echo ""
echo -e "${BLUE}📋 Resumen:${NC}"
echo "   ✅ Secrets configurados en GitHub"
echo "   ✅ Workflow disponible"
echo "   ✅ Push automático activado"
echo ""
echo -e "${BLUE}🔗 Enlaces útiles:${NC}"
echo "   Docker Hub: https://hub.docker.com/r/$DOCKER_USERNAME/ia-ops-backstage"
echo "   GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   Secrets: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo ""
echo -e "${BLUE}📝 Próximos pasos:${NC}"
echo "   1. El workflow se ejecutará automáticamente en cada push a 'trunk'"
echo "   2. Puedes ejecutar manualmente: gh workflow run docker-hub-push.yml"
echo "   3. Verifica la imagen: ./scripts/verify-docker-hub.sh"
echo "   4. Usa la imagen: docker pull $DOCKER_USERNAME/ia-ops-backstage:latest"
echo ""
echo -e "${GREEN}✅ ¡Docker Hub configurado exitosamente!${NC}"
