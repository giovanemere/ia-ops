#!/bin/bash

# Script para sincronizar variables de entorno del archivo principal .env
# con el archivo .env.local del frontend de Backstage

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Sincronizando variables de entorno para AI Chat...${NC}"

# Rutas de archivos
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
FRONTEND_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/app/.env.local"

# Verificar que el archivo principal .env existe
if [ ! -f "$MAIN_ENV_FILE" ]; then
    echo -e "${RED}❌ Error: No se encontró el archivo $MAIN_ENV_FILE${NC}"
    exit 1
fi

# Extraer variables del archivo principal .env
echo -e "${YELLOW}📖 Leyendo variables del archivo principal .env...${NC}"

OPENAI_API_KEY=$(grep "^OPENAI_API_KEY=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
OPENAI_MODEL=$(grep "^OPENAI_MODEL=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
OPENAI_MAX_TOKENS=$(grep "^OPENAI_MAX_TOKENS=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
OPENAI_TEMPERATURE=$(grep "^OPENAI_TEMPERATURE=" "$MAIN_ENV_FILE" | cut -d'=' -f2)

# Verificar que se encontraron las variables
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${RED}❌ Error: No se encontró OPENAI_API_KEY en $MAIN_ENV_FILE${NC}"
    exit 1
fi

# Crear el archivo .env.local para el frontend
echo -e "${YELLOW}✍️  Creando archivo .env.local para el frontend...${NC}"

cat > "$FRONTEND_ENV_FILE" << EOF
# OpenAI Configuration for AI Chat
# Variables sincronizadas automáticamente desde $MAIN_ENV_FILE
# Generado el: $(date)

REACT_APP_OPENAI_API_KEY=$OPENAI_API_KEY
REACT_APP_OPENAI_MODEL=$OPENAI_MODEL
REACT_APP_OPENAI_MAX_TOKENS=$OPENAI_MAX_TOKENS
REACT_APP_OPENAI_TEMPERATURE=$OPENAI_TEMPERATURE

# NOTA: En producción, estas variables deberían manejarse desde el backend por seguridad
# Este archivo es solo para desarrollo local
EOF

echo -e "${GREEN}✅ Variables sincronizadas exitosamente:${NC}"
echo -e "   📁 Archivo origen: $MAIN_ENV_FILE"
echo -e "   📁 Archivo destino: $FRONTEND_ENV_FILE"
echo -e "   🔑 API Key: ${OPENAI_API_KEY:0:20}..."
echo -e "   🤖 Modelo: $OPENAI_MODEL"
echo -e "   📊 Max Tokens: $OPENAI_MAX_TOKENS"
echo -e "   🌡️  Temperature: $OPENAI_TEMPERATURE"

echo -e "${BLUE}🚀 Para aplicar los cambios, reinicia Backstage con: yarn start${NC}"
