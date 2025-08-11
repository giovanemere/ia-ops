#!/bin/bash

# =============================================================================
# SCRIPT DE VALIDACIÓN - CONFIGURACIÓN OPENAI + BACKSTAGE
# =============================================================================
# Valida que todas las variables de OpenAI estén configuradas correctamente
# Uso: ./scripts/validate-openai-config.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar si una variable está definida
check_var() {
    local var_name=$1
    local var_value=$2
    local required=$3
    local description=$4
    
    if [ -z "$var_value" ]; then
        if [ "$required" = "true" ]; then
            print_error "$var_name no está definida - $description"
            return 1
        else
            print_warning "$var_name no está definida (opcional) - $description"
            return 0
        fi
    else
        print_success "$var_name está definida"
        return 0
    fi
}

# Función para validar API key de OpenAI
validate_openai_key() {
    local api_key=$1
    
    if [ -z "$api_key" ]; then
        print_error "OPENAI_API_KEY no está definida"
        return 1
    fi
    
    # Verificar formato de la API key
    if [[ ! "$api_key" =~ ^sk-proj-.+ ]] && [[ ! "$api_key" =~ ^sk-.+ ]]; then
        print_error "OPENAI_API_KEY no tiene el formato correcto (debe empezar con 'sk-' o 'sk-proj-')"
        return 1
    fi
    
    # Verificar longitud mínima
    if [ ${#api_key} -lt 20 ]; then
        print_error "OPENAI_API_KEY parece ser demasiado corta"
        return 1
    fi
    
    print_success "OPENAI_API_KEY tiene formato válido"
    return 0
}

# Función para validar modelo de OpenAI
validate_openai_model() {
    local model=$1
    local valid_models=("gpt-4o" "gpt-4o-mini" "gpt-4-turbo" "gpt-4" "gpt-3.5-turbo")
    
    if [ -z "$model" ]; then
        print_error "OPENAI_MODEL no está definido"
        return 1
    fi
    
    for valid_model in "${valid_models[@]}"; do
        if [ "$model" = "$valid_model" ]; then
            print_success "OPENAI_MODEL ($model) es válido"
            return 0
        fi
    done
    
    print_warning "OPENAI_MODEL ($model) no está en la lista de modelos recomendados"
    return 0
}

# Función para validar parámetros numéricos
validate_numeric() {
    local var_name=$1
    local var_value=$2
    local min_val=$3
    local max_val=$4
    
    if [ -z "$var_value" ]; then
        print_warning "$var_name no está definido"
        return 0
    fi
    
    if ! [[ "$var_value" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        print_error "$var_name ($var_value) no es un número válido"
        return 1
    fi
    
    if (( $(echo "$var_value < $min_val" | bc -l) )); then
        print_error "$var_name ($var_value) es menor que el mínimo permitido ($min_val)"
        return 1
    fi
    
    if (( $(echo "$var_value > $max_val" | bc -l) )); then
        print_error "$var_name ($var_value) es mayor que el máximo permitido ($max_val)"
        return 1
    fi
    
    print_success "$var_name ($var_value) está en el rango válido"
    return 0
}

# Función para probar conectividad con OpenAI
test_openai_connection() {
    local api_key=$1
    
    if [ -z "$api_key" ]; then
        print_error "No se puede probar conexión: API key no definida"
        return 1
    fi
    
    print_status "Probando conexión con OpenAI API..."
    
    local response=$(curl -s -w "%{http_code}" -o /tmp/openai_test.json \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        "https://api.openai.com/v1/models")
    
    if [ "$response" = "200" ]; then
        print_success "Conexión con OpenAI API exitosa"
        return 0
    elif [ "$response" = "401" ]; then
        print_error "API key inválida o sin permisos"
        return 1
    elif [ "$response" = "429" ]; then
        print_warning "Rate limit alcanzado, pero API key parece válida"
        return 0
    else
        print_error "Error de conexión con OpenAI API (HTTP $response)"
        return 1
    fi
}

# Cargar variables de entorno
if [ -f ".env" ]; then
    print_status "Cargando variables desde .env"
    source .env
else
    print_error "Archivo .env no encontrado"
    exit 1
fi

print_status "=== VALIDACIÓN DE CONFIGURACIÓN OPENAI + BACKSTAGE ==="
echo

# Contador de errores
errors=0

print_status "1. Validando variables básicas de OpenAI..."
check_var "OPENAI_API_KEY" "$OPENAI_API_KEY" "true" "Clave de API de OpenAI" || ((errors++))
validate_openai_key "$OPENAI_API_KEY" || ((errors++))

check_var "OPENAI_MODEL" "$OPENAI_MODEL" "true" "Modelo principal de OpenAI" || ((errors++))
validate_openai_model "$OPENAI_MODEL" || ((errors++))

check_var "OPENAI_API_BASE" "$OPENAI_API_BASE" "false" "URL base de la API de OpenAI"
check_var "OPENAI_ORG_ID" "$OPENAI_ORG_ID" "false" "ID de organización OpenAI"
echo

print_status "2. Validando parámetros de generación..."
validate_numeric "OPENAI_MAX_TOKENS" "$OPENAI_MAX_TOKENS" "1" "8192" || ((errors++))
validate_numeric "OPENAI_TEMPERATURE" "$OPENAI_TEMPERATURE" "0.0" "2.0" || ((errors++))
validate_numeric "OPENAI_TOP_P" "$OPENAI_TOP_P" "0.0" "1.0" || ((errors++))
validate_numeric "OPENAI_FREQUENCY_PENALTY" "$OPENAI_FREQUENCY_PENALTY" "-2.0" "2.0" || ((errors++))
validate_numeric "OPENAI_PRESENCE_PENALTY" "$OPENAI_PRESENCE_PENALTY" "-2.0" "2.0" || ((errors++))
echo

print_status "3. Validando configuración de servicio..."
validate_numeric "OPENAI_TIMEOUT" "$OPENAI_TIMEOUT" "1" "300" || ((errors++))
validate_numeric "OPENAI_MAX_RETRIES" "$OPENAI_MAX_RETRIES" "0" "10" || ((errors++))
validate_numeric "OPENAI_RATE_LIMIT" "$OPENAI_RATE_LIMIT" "1" "1000" || ((errors++))
echo

print_status "4. Validando integración con Backstage..."
check_var "OPENAI_BACKSTAGE_ENABLED" "$OPENAI_BACKSTAGE_ENABLED" "true" "Habilitar integración con Backstage" || ((errors++))
check_var "OPENAI_SERVICE_URL" "$OPENAI_SERVICE_URL" "true" "URL del servicio OpenAI" || ((errors++))
check_var "OPENAI_BACKSTAGE_PROXY_PATH" "$OPENAI_BACKSTAGE_PROXY_PATH" "false" "Path del proxy en Backstage"
echo

print_status "5. Validando funcionalidades..."
check_var "OPENAI_FUNCTION_CALLING_ENABLED" "$OPENAI_FUNCTION_CALLING_ENABLED" "false" "Function calling"
check_var "OPENAI_STREAMING_ENABLED" "$OPENAI_STREAMING_ENABLED" "false" "Streaming de respuestas"
check_var "OPENAI_EMBEDDINGS_ENABLED" "$OPENAI_EMBEDDINGS_ENABLED" "false" "Embeddings para búsqueda"
check_var "OPENAI_CODE_ANALYSIS_ENABLED" "$OPENAI_CODE_ANALYSIS_ENABLED" "false" "Análisis de código"
echo

print_status "6. Validando base de conocimiento..."
if [ "$OPENAI_KNOWLEDGE_BASE_ENABLED" = "true" ]; then
    check_var "OPENAI_KNOWLEDGE_BASE_PATH" "$OPENAI_KNOWLEDGE_BASE_PATH" "true" "Path de la base de conocimiento" || ((errors++))
    
    if [ -n "$OPENAI_KNOWLEDGE_BASE_PATH" ] && [ ! -f "$OPENAI_KNOWLEDGE_BASE_PATH" ]; then
        print_warning "Archivo de base de conocimiento no existe: $OPENAI_KNOWLEDGE_BASE_PATH"
    fi
    
    validate_numeric "OPENAI_KNOWLEDGE_BASE_UPDATE_INTERVAL" "$OPENAI_KNOWLEDGE_BASE_UPDATE_INTERVAL" "60" "86400" || ((errors++))
fi
echo

print_status "7. Validando seguridad..."
check_var "OPENAI_PII_FILTERING_ENABLED" "$OPENAI_PII_FILTERING_ENABLED" "false" "Filtrado de PII"
check_var "OPENAI_AUDIT_ENABLED" "$OPENAI_AUDIT_ENABLED" "false" "Auditoría de requests"
validate_numeric "OPENAI_LOG_RETENTION_DAYS" "$OPENAI_LOG_RETENTION_DAYS" "1" "365" || ((errors++))
echo

print_status "8. Validando monitoreo..."
check_var "OPENAI_METRICS_ENABLED" "$OPENAI_METRICS_ENABLED" "false" "Métricas de uso"
check_var "OPENAI_COST_TRACKING_ENABLED" "$OPENAI_COST_TRACKING_ENABLED" "false" "Tracking de costos"

if [ "$OPENAI_COST_TRACKING_ENABLED" = "true" ]; then
    validate_numeric "OPENAI_DAILY_COST_LIMIT" "$OPENAI_DAILY_COST_LIMIT" "0.01" "1000" || ((errors++))
fi
echo

print_status "9. Probando conectividad..."
if [ "$OPENAI_DEMO_MODE" != "true" ]; then
    test_openai_connection "$OPENAI_API_KEY" || ((errors++))
else
    print_warning "Modo demo habilitado, saltando prueba de conectividad"
fi
echo

# Validaciones adicionales
print_status "10. Validaciones adicionales..."

# Verificar que los puertos no estén en conflicto
if [ "$OPENAI_SERVICE_PORT" = "$BACKSTAGE_FRONTEND_PORT" ] || [ "$OPENAI_SERVICE_PORT" = "$BACKSTAGE_BACKEND_PORT" ]; then
    print_error "Puerto del servicio OpenAI en conflicto con puertos de Backstage"
    ((errors++))
fi

# Verificar que las URLs sean válidas
if [[ ! "$OPENAI_SERVICE_URL" =~ ^https?:// ]]; then
    print_error "OPENAI_SERVICE_URL no es una URL válida"
    ((errors++))
fi

# Verificar dependencias de Docker
if ! command -v docker &> /dev/null; then
    print_warning "Docker no está instalado o no está en el PATH"
fi

# Verificar dependencias de curl
if ! command -v curl &> /dev/null; then
    print_error "curl no está instalado (requerido para pruebas de conectividad)"
    ((errors++))
fi

echo
print_status "=== RESUMEN DE VALIDACIÓN ==="

if [ $errors -eq 0 ]; then
    print_success "✅ Todas las validaciones pasaron correctamente"
    print_success "La configuración de OpenAI está lista para usar con Backstage"
    exit 0
else
    print_error "❌ Se encontraron $errors errores en la configuración"
    print_error "Por favor, corrige los errores antes de continuar"
    exit 1
fi
