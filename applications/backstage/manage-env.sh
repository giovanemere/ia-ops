#!/bin/bash

# Script para gestionar variables de entorno del proyecto IA-OPS
# Mantiene sincronizadas las variables entre backend y frontend

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Rutas
MAIN_ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
FRONTEND_ENV_LINK="/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/app/.env"

show_help() {
    echo -e "${BLUE}🔧 Gestor de Variables de Entorno - IA-OPS${NC}"
    echo -e "${CYAN}Uso: $0 [comando]${NC}"
    echo ""
    echo -e "${YELLOW}Comandos disponibles:${NC}"
    echo -e "  ${GREEN}check${NC}     - Verificar configuración actual"
    echo -e "  ${GREEN}status${NC}    - Mostrar estado de las variables OpenAI"
    echo -e "  ${GREEN}link${NC}      - Crear/recrear enlace simbólico al archivo .env principal"
    echo -e "  ${GREEN}test${NC}      - Probar conexión con OpenAI API"
    echo -e "  ${GREEN}help${NC}      - Mostrar esta ayuda"
    echo ""
    echo -e "${CYAN}Ejemplos:${NC}"
    echo -e "  $0 check    # Verificar que todo esté configurado"
    echo -e "  $0 status   # Ver variables OpenAI actuales"
    echo -e "  $0 test     # Probar API de OpenAI"
}

check_config() {
    echo -e "${BLUE}🔍 Verificando configuración...${NC}"
    
    # Verificar archivo principal .env
    if [ ! -f "$MAIN_ENV_FILE" ]; then
        echo -e "${RED}❌ Error: No se encontró el archivo principal .env en $MAIN_ENV_FILE${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Archivo principal .env encontrado${NC}"
    
    # Verificar enlace simbólico
    if [ ! -L "$FRONTEND_ENV_LINK" ]; then
        echo -e "${YELLOW}⚠️  Enlace simbólico no encontrado, creando...${NC}"
        create_link
    else
        echo -e "${GREEN}✅ Enlace simbólico configurado correctamente${NC}"
    fi
    
    # Verificar variables REACT_APP_
    local react_vars=$(grep -c "^REACT_APP_OPENAI_" "$MAIN_ENV_FILE" || echo "0")
    if [ "$react_vars" -eq 0 ]; then
        echo -e "${RED}❌ Error: No se encontraron variables REACT_APP_OPENAI_ en el archivo .env${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Variables REACT_APP_ encontradas: $react_vars${NC}"
    
    echo -e "${GREEN}🎉 Configuración verificada correctamente${NC}"
}

show_status() {
    echo -e "${BLUE}📊 Estado de variables OpenAI:${NC}"
    echo ""
    
    if [ ! -f "$MAIN_ENV_FILE" ]; then
        echo -e "${RED}❌ Archivo .env no encontrado${NC}"
        return 1
    fi
    
    # Variables del backend
    echo -e "${CYAN}🔧 Variables del Backend:${NC}"
    local api_key=$(grep "^OPENAI_API_KEY=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local model=$(grep "^OPENAI_MODEL=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local max_tokens=$(grep "^OPENAI_MAX_TOKENS=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local temperature=$(grep "^OPENAI_TEMPERATURE=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    
    echo -e "  🔑 API Key: ${api_key:0:20}..."
    echo -e "  🤖 Model: $model"
    echo -e "  📊 Max Tokens: $max_tokens"
    echo -e "  🌡️  Temperature: $temperature"
    
    echo ""
    
    # Variables del frontend
    echo -e "${CYAN}🎨 Variables del Frontend (React):${NC}"
    local react_api_key=$(grep "^REACT_APP_OPENAI_API_KEY=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local react_model=$(grep "^REACT_APP_OPENAI_MODEL=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local react_max_tokens=$(grep "^REACT_APP_OPENAI_MAX_TOKENS=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local react_temperature=$(grep "^REACT_APP_OPENAI_TEMPERATURE=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    
    echo -e "  🔑 API Key: ${react_api_key:0:20}..."
    echo -e "  🤖 Model: $react_model"
    echo -e "  📊 Max Tokens: $react_max_tokens"
    echo -e "  🌡️  Temperature: $react_temperature"
    
    # Verificar sincronización
    if [ "$api_key" = "$react_api_key" ] && [ "$model" = "$react_model" ]; then
        echo -e "${GREEN}✅ Variables sincronizadas correctamente${NC}"
    else
        echo -e "${YELLOW}⚠️  Variables no están sincronizadas${NC}"
    fi
}

create_link() {
    echo -e "${YELLOW}🔗 Creando enlace simbólico...${NC}"
    
    # Remover enlace existente si existe
    if [ -L "$FRONTEND_ENV_LINK" ] || [ -f "$FRONTEND_ENV_LINK" ]; then
        rm -f "$FRONTEND_ENV_LINK"
    fi
    
    # Crear nuevo enlace
    ln -sf "$MAIN_ENV_FILE" "$FRONTEND_ENV_LINK"
    
    if [ -L "$FRONTEND_ENV_LINK" ]; then
        echo -e "${GREEN}✅ Enlace simbólico creado correctamente${NC}"
        echo -e "   📁 Origen: $MAIN_ENV_FILE"
        echo -e "   📁 Destino: $FRONTEND_ENV_LINK"
    else
        echo -e "${RED}❌ Error al crear el enlace simbólico${NC}"
        exit 1
    fi
}

test_openai() {
    echo -e "${BLUE}🧪 Probando conexión con OpenAI API...${NC}"
    
    local api_key=$(grep "^OPENAI_API_KEY=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    local model=$(grep "^OPENAI_MODEL=" "$MAIN_ENV_FILE" | cut -d'=' -f2)
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}❌ Error: No se encontró OPENAI_API_KEY${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}🔄 Enviando petición de prueba...${NC}"
    
    local response=$(curl -s -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$model\",
            \"messages\": [{\"role\": \"user\", \"content\": \"Hola, ¿funciona la API?\"}],
            \"max_tokens\": 50
        }" \
        https://api.openai.com/v1/chat/completions)
    
    if echo "$response" | grep -q "choices"; then
        local content=$(echo "$response" | jq -r '.choices[0].message.content // "Sin respuesta"' 2>/dev/null || echo "Respuesta recibida")
        echo -e "${GREEN}✅ API funcionando correctamente${NC}"
        echo -e "${CYAN}🤖 Respuesta: $content${NC}"
    else
        echo -e "${RED}❌ Error en la API:${NC}"
        echo "$response" | jq -r '.error.message // "Error desconocido"' 2>/dev/null || echo "$response"
        exit 1
    fi
}

# Procesar argumentos
case "${1:-help}" in
    "check")
        check_config
        ;;
    "status")
        show_status
        ;;
    "link")
        create_link
        ;;
    "test")
        test_openai
        ;;
    "help"|*)
        show_help
        ;;
esac
