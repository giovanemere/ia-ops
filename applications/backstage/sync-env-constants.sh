#!/bin/bash

# Script para sincronizar variables del archivo .env principal
# con las constantes en src/config/env.ts

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Sincronizando variables de entorno a constantes TypeScript...${NC}"

# Rutas de archivos
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
ENV_CONSTANTS_FILE="/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/app/src/config/env.ts"

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

# Crear directorio si no existe
mkdir -p "$(dirname "$ENV_CONSTANTS_FILE")"

# Crear el archivo env.ts con las constantes
echo -e "${YELLOW}✍️  Creando archivo de constantes TypeScript...${NC}"

cat > "$ENV_CONSTANTS_FILE" << EOF
// Configuración de variables de entorno para el AI Chat
// Estas constantes son sincronizadas automáticamente desde $MAIN_ENV_FILE
// Generado el: $(date)

// Variables de OpenAI desde el archivo .env principal
export const OPENAI_CONFIG = {
  API_KEY: '$OPENAI_API_KEY',
  MODEL: '$OPENAI_MODEL',
  MAX_TOKENS: $OPENAI_MAX_TOKENS,
  TEMPERATURE: $OPENAI_TEMPERATURE,
} as const;

// Función helper para verificar si estamos en desarrollo
export const isDevelopment = () => {
  try {
    return typeof window !== 'undefined' && window.location.hostname === 'localhost';
  } catch {
    return false;
  }
};

// Configuración por defecto
export const DEFAULT_CONFIG = {
  apiKey: OPENAI_CONFIG.API_KEY,
  model: OPENAI_CONFIG.MODEL,
  maxTokens: OPENAI_CONFIG.MAX_TOKENS,
  temperature: OPENAI_CONFIG.TEMPERATURE,
} as const;
EOF

echo -e "${GREEN}✅ Constantes sincronizadas exitosamente:${NC}"
echo -e "   📁 Archivo origen: $MAIN_ENV_FILE"
echo -e "   📁 Archivo destino: $ENV_CONSTANTS_FILE"
echo -e "   🔑 API Key: ${OPENAI_API_KEY:0:20}..."
echo -e "   🤖 Modelo: $OPENAI_MODEL"
echo -e "   📊 Max Tokens: $OPENAI_MAX_TOKENS"
echo -e "   🌡️  Temperature: $OPENAI_TEMPERATURE"

echo -e "${BLUE}🚀 Para aplicar los cambios, reinicia Backstage con: yarn start${NC}"
