#!/bin/bash

# 🚀 Start Backstage with Auto-Discovery Enabled
# Este script inicia Backstage con todas las funcionalidades de auto-discovery habilitadas

set -e

echo "🚀 Iniciando Backstage con Auto-Discovery..."
echo "=============================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: No se encontró package.json. Ejecuta desde el directorio de Backstage${NC}"
    exit 1
fi

echo -e "\n${BLUE}🔧 Verificando configuración...${NC}"

# Verificar variables de entorno críticas
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ Error: GITHUB_TOKEN no está configurado${NC}"
    echo "Configura tu GitHub token en el archivo .env"
    exit 1
fi

if [ -z "$POSTGRES_HOST" ]; then
    echo -e "${RED}❌ Error: Variables de PostgreSQL no están configuradas${NC}"
    echo "Verifica la configuración de la base de datos en .env"
    exit 1
fi

echo -e "${GREEN}✅ Variables de entorno configuradas${NC}"

echo -e "\n${BLUE}🗄️ Verificando base de datos...${NC}"

# Verificar conexión a PostgreSQL
if command -v psql &> /dev/null; then
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" &> /dev/null; then
        echo -e "${GREEN}✅ Conexión a PostgreSQL exitosa${NC}"
    else
        echo -e "${YELLOW}⚠️ No se pudo conectar a PostgreSQL. Asegúrate de que esté ejecutándose${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ psql no está instalado. No se puede verificar la conexión a PostgreSQL${NC}"
fi

echo -e "\n${BLUE}📦 Instalando dependencias...${NC}"

# Instalar dependencias si es necesario
if [ ! -d "node_modules" ] || [ ! -f "yarn.lock" ]; then
    echo "📦 Instalando dependencias con yarn..."
    yarn install
else
    echo -e "${GREEN}✅ Dependencias ya instaladas${NC}"
fi

echo -e "\n${BLUE}🔧 Configurando plugins de auto-discovery...${NC}"

# Verificar que los plugins necesarios estén instalados
REQUIRED_PLUGINS=(
    "@backstage/plugin-github-actions"
    "@backstage/plugin-techdocs"
    "@backstage/plugin-github"
    "@backstage/plugin-catalog-backend-module-github"
)

for plugin in "${REQUIRED_PLUGINS[@]}"; do
    if grep -q "$plugin" package.json; then
        echo -e "${GREEN}✅ $plugin instalado${NC}"
    else
        echo -e "${YELLOW}⚠️ Instalando $plugin...${NC}"
        yarn add "$plugin"
    fi
done

echo -e "\n${BLUE}📚 Configurando TechDocs...${NC}"

# Crear directorio para TechDocs si no existe
mkdir -p techdocs

# Verificar Docker para TechDocs
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo -e "${GREEN}✅ Docker está disponible para TechDocs${NC}"
    else
        echo -e "${YELLOW}⚠️ Docker no está ejecutándose. TechDocs usará modo local${NC}"
        export TECHDOCS_GENERATOR_RUNIN=local
    fi
else
    echo -e "${YELLOW}⚠️ Docker no está instalado. TechDocs usará modo local${NC}"
    export TECHDOCS_GENERATOR_RUNIN=local
fi

echo -e "\n${BLUE}🔄 Limpiando procesos anteriores...${NC}"

# Matar procesos existentes de Backstage
pkill -f "yarn dev" || true
pkill -f "backstage" || true
sleep 2

echo -e "\n${BLUE}🚀 Iniciando Backstage...${NC}"

# Configurar variables de entorno para auto-discovery
export NODE_ENV=development
export LOG_LEVEL=info

# Mostrar información de configuración
echo -e "\n${YELLOW}📋 Configuración activa:${NC}"
echo "🌐 Frontend URL: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "🔧 Backend URL: http://localhost:${BACKSTAGE_BACKEND_PORT:-7007}"
echo "📚 TechDocs: ${TECHDOCS_GENERATOR_RUNIN:-docker} mode"
echo "🔍 GitHub Org: ${GITHUB_ORG:-giovanemere}"
echo "🗄️ Database: ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-backstage_db}"

echo -e "\n${GREEN}🎉 Funcionalidades habilitadas:${NC}"
echo "✅ Auto-discovery de repositorios GitHub (cada 30 min)"
echo "✅ Documentación automática con TechDocs"
echo "✅ GitHub Actions integration"
echo "✅ Source code browsing"
echo "✅ Code coverage reports"
echo "✅ Dependency tracking"
echo "✅ API documentation"

echo -e "\n${BLUE}🔗 URLs importantes:${NC}"
echo "📊 Catalog: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}/catalog"
echo "📚 Docs: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}/docs"
echo "🔧 GitHub Actions: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}/github-actions"
echo "🔍 Search: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}/search"

echo -e "\n${YELLOW}⏳ Iniciando servicios... (esto puede tomar unos minutos)${NC}"

# Iniciar Backstage en modo desarrollo
yarn dev &

# Esperar a que los servicios estén listos
echo -e "\n${BLUE}⏳ Esperando a que los servicios estén listos...${NC}"

# Función para verificar si un servicio está listo
check_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $name está listo${NC}"
            return 0
        fi
        echo -e "${YELLOW}⏳ Esperando $name... (intento $attempt/$max_attempts)${NC}"
        sleep 5
        ((attempt++))
    done
    
    echo -e "${RED}❌ $name no respondió después de $max_attempts intentos${NC}"
    return 1
}

# Verificar que los servicios estén listos
sleep 10
check_service "http://localhost:${BACKSTAGE_BACKEND_PORT:-7007}/api/catalog/entities" "Backend API"
check_service "http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}" "Frontend"

echo -e "\n${GREEN}🎉 ¡Backstage está listo!${NC}"
echo -e "\n${BLUE}📋 Próximos pasos:${NC}"
echo "1. Ve a http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}"
echo "2. Explora el catálogo de servicios"
echo "3. Revisa la documentación automática"
echo "4. Verifica los workflows de GitHub Actions"
echo "5. Los repositorios se descubrirán automáticamente"

echo -e "\n${YELLOW}💡 Consejos:${NC}"
echo "• Los repositorios se actualizan cada 30 minutos automáticamente"
echo "• La documentación se genera desde archivos mkdocs.yml en cada repo"
echo "• Los workflows de GitHub Actions aparecen en la pestaña CI/CD"
echo "• Usa Ctrl+C para detener los servicios"

echo -e "\n${GREEN}✨ ¡Disfruta de tu plataforma de desarrollo automatizada!${NC}"

# Mantener el script ejecutándose
wait
