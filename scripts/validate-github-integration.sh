#!/bin/bash

# =============================================================================
# VALIDADOR DE INTEGRACIÓN GITHUB - IA-OPS PLATFORM
# =============================================================================
# Descripción: Valida configuración de GitHub y conectividad
# Uso: ./scripts/validate-github-integration.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Cargar variables de entorno
if [ -f .env ]; then
    source .env
    log_info "Cargando variables desde .env"
else
    log_error "Archivo .env no encontrado"
    exit 1
fi

echo "🐙 Validando integración GitHub con Backstage..."
echo "=================================================="

# Contador de errores
ERRORS=0
WARNINGS=0

# =============================================================================
# VALIDAR VARIABLES CRÍTICAS
# =============================================================================

log_info "Validando variables críticas de GitHub..."

# Variables requeridas
REQUIRED_GITHUB_VARS=(
    "GITHUB_TOKEN"
    "GITHUB_ORG"
    "GITHUB_REPO"
    "GITHUB_BASE_URL"
    "AUTH_GITHUB_CLIENT_ID"
    "AUTH_GITHUB_CLIENT_SECRET"
)

for var in "${REQUIRED_GITHUB_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        log_error "Variable requerida $var no está definida"
        ((ERRORS++))
    else
        log_success "$var está definida"
    fi
done

# =============================================================================
# VALIDAR FORMATO DE GITHUB TOKEN
# =============================================================================

log_info "Validando formato del GitHub Token..."

if [[ ! -z "$GITHUB_TOKEN" ]]; then
    # Verificar formato del token (debe empezar con ghp_, gho_, ghu_, ghs_, o ghr_)
    if [[ "$GITHUB_TOKEN" =~ ^gh[pous]_[a-zA-Z0-9]{36}$ ]] || [[ "$GITHUB_TOKEN" =~ ^ghr_[a-zA-Z0-9]{76}$ ]]; then
        log_success "Formato de GITHUB_TOKEN válido"
    else
        log_warning "Formato de GITHUB_TOKEN podría ser inválido o es un token clásico"
        ((WARNINGS++))
    fi
fi

# =============================================================================
# VALIDAR URLs DE GITHUB
# =============================================================================

log_info "Validando URLs de GitHub..."

# Verificar GITHUB_BASE_URL
if [[ "$GITHUB_BASE_URL" =~ ^https?://[a-zA-Z0-9.-]+$ ]]; then
    log_success "GITHUB_BASE_URL tiene formato válido: $GITHUB_BASE_URL"
else
    log_error "GITHUB_BASE_URL debe ser una URL válida"
    ((ERRORS++))
fi

# Verificar GITHUB_API_URL
if [[ "$GITHUB_API_URL" =~ ^https?://[a-zA-Z0-9.-]+$ ]]; then
    log_success "GITHUB_API_URL tiene formato válido: $GITHUB_API_URL"
else
    log_error "GITHUB_API_URL debe ser una URL válida"
    ((ERRORS++))
fi

# Verificar AUTH_GITHUB_CALLBACK_URL
if [[ "$AUTH_GITHUB_CALLBACK_URL" =~ ^https?://[a-zA-Z0-9.-]+:[0-9]+/api/auth/github/handler/frame$ ]]; then
    log_success "AUTH_GITHUB_CALLBACK_URL tiene formato válido"
else
    log_warning "AUTH_GITHUB_CALLBACK_URL podría tener formato incorrecto"
    ((WARNINGS++))
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN OAUTH
# =============================================================================

log_info "Validando configuración OAuth..."

# Verificar Client ID format (GitHub OAuth App Client IDs suelen empezar con Iv1. o Ov23)
if [[ "$AUTH_GITHUB_CLIENT_ID" =~ ^(Iv1\.|Ov23)[a-zA-Z0-9]{16}$ ]]; then
    log_success "AUTH_GITHUB_CLIENT_ID tiene formato válido"
else
    log_warning "AUTH_GITHUB_CLIENT_ID podría tener formato incorrecto"
    ((WARNINGS++))
fi

# Verificar Client Secret length (debe ser 40 caracteres hex)
if [[ ${#AUTH_GITHUB_CLIENT_SECRET} -eq 40 ]] && [[ "$AUTH_GITHUB_CLIENT_SECRET" =~ ^[a-f0-9]{40}$ ]]; then
    log_success "AUTH_GITHUB_CLIENT_SECRET tiene formato válido"
else
    log_warning "AUTH_GITHUB_CLIENT_SECRET podría tener formato incorrecto"
    ((WARNINGS++))
fi

# Verificar scopes
if [[ ! -z "$AUTH_GITHUB_SCOPES" ]]; then
    log_success "AUTH_GITHUB_SCOPES configurado: $AUTH_GITHUB_SCOPES"
else
    log_warning "AUTH_GITHUB_SCOPES no está configurado"
    ((WARNINGS++))
fi

# =============================================================================
# TESTS DE CONECTIVIDAD
# =============================================================================

log_info "Ejecutando tests de conectividad con GitHub..."

# Test 1: Verificar acceso a GitHub API
if command -v curl >/dev/null 2>&1; then
    log_info "Probando conectividad con GitHub API..."
    
    # Test básico de conectividad
    if curl -s --max-time 10 "$GITHUB_API_URL" >/dev/null; then
        log_success "Conectividad con GitHub API exitosa"
    else
        log_error "No se puede conectar con GitHub API"
        ((ERRORS++))
    fi
    
    # Test con token (si está configurado)
    if [[ ! -z "$GITHUB_TOKEN" ]]; then
        log_info "Probando autenticación con GitHub Token..."
        
        RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
            -H "Authorization: token $GITHUB_TOKEN" \
            "$GITHUB_API_URL/user")
        
        case $RESPONSE in
            200)
                log_success "Autenticación con GitHub Token exitosa"
                
                # Obtener información del usuario
                USER_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/user")
                if command -v jq >/dev/null 2>&1; then
                    USERNAME=$(echo "$USER_INFO" | jq -r '.login // "unknown"')
                    log_info "Token pertenece al usuario: $USERNAME"
                fi
                ;;
            401)
                log_error "GitHub Token inválido o expirado"
                ((ERRORS++))
                ;;
            403)
                log_error "GitHub Token sin permisos suficientes o rate limit excedido"
                ((ERRORS++))
                ;;
            *)
                log_warning "Respuesta inesperada de GitHub API: HTTP $RESPONSE"
                ((WARNINGS++))
                ;;
        esac
    fi
    
    # Test acceso a organización
    if [[ ! -z "$GITHUB_TOKEN" ]] && [[ ! -z "$GITHUB_ORG" ]]; then
        log_info "Probando acceso a la organización $GITHUB_ORG..."
        
        ORG_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
            -H "Authorization: token $GITHUB_TOKEN" \
            "$GITHUB_API_URL/orgs/$GITHUB_ORG")
        
        case $ORG_RESPONSE in
            200)
                log_success "Acceso a organización $GITHUB_ORG exitoso"
                ;;
            404)
                log_error "Organización $GITHUB_ORG no encontrada o sin acceso"
                ((ERRORS++))
                ;;
            *)
                log_warning "Respuesta inesperada para organización: HTTP $ORG_RESPONSE"
                ((WARNINGS++))
                ;;
        esac
    fi
    
    # Test acceso a repositorio
    if [[ ! -z "$GITHUB_TOKEN" ]] && [[ ! -z "$GITHUB_ORG" ]] && [[ ! -z "$GITHUB_REPO" ]]; then
        log_info "Probando acceso al repositorio $GITHUB_ORG/$GITHUB_REPO..."
        
        REPO_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
            -H "Authorization: token $GITHUB_TOKEN" \
            "$GITHUB_API_URL/repos/$GITHUB_ORG/$GITHUB_REPO")
        
        case $REPO_RESPONSE in
            200)
                log_success "Acceso a repositorio $GITHUB_ORG/$GITHUB_REPO exitoso"
                ;;
            404)
                log_error "Repositorio $GITHUB_ORG/$GITHUB_REPO no encontrado o sin acceso"
                ((ERRORS++))
                ;;
            *)
                log_warning "Respuesta inesperada para repositorio: HTTP $REPO_RESPONSE"
                ((WARNINGS++))
                ;;
        esac
    fi
    
else
    log_warning "curl no disponible, saltando tests de conectividad"
fi

# =============================================================================
# VALIDAR RATE LIMITS
# =============================================================================

if [[ ! -z "$GITHUB_TOKEN" ]] && command -v curl >/dev/null 2>&1; then
    log_info "Verificando rate limits de GitHub..."
    
    RATE_LIMIT_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/rate_limit")
    
    if command -v jq >/dev/null 2>&1 && echo "$RATE_LIMIT_INFO" | jq . >/dev/null 2>&1; then
        CORE_REMAINING=$(echo "$RATE_LIMIT_INFO" | jq -r '.rate.remaining // 0')
        CORE_LIMIT=$(echo "$RATE_LIMIT_INFO" | jq -r '.rate.limit // 0')
        
        if [ "$CORE_REMAINING" -gt 100 ]; then
            log_success "Rate limit OK: $CORE_REMAINING/$CORE_LIMIT requests restantes"
        elif [ "$CORE_REMAINING" -gt 10 ]; then
            log_warning "Rate limit bajo: $CORE_REMAINING/$CORE_LIMIT requests restantes"
            ((WARNINGS++))
        else
            log_error "Rate limit crítico: $CORE_REMAINING/$CORE_LIMIT requests restantes"
            ((ERRORS++))
        fi
    else
        log_warning "No se pudo obtener información de rate limits"
        ((WARNINGS++))
    fi
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN DE CATÁLOGO
# =============================================================================

log_info "Validando configuración del catálogo..."

# Verificar CATALOG_LOCATIONS
if [[ ! -z "$CATALOG_LOCATIONS" ]]; then
    if [[ "$CATALOG_LOCATIONS" =~ ^https://github\.com/[^/]+/[^/]+/blob/[^/]+/.*\.yaml$ ]]; then
        log_success "CATALOG_LOCATIONS tiene formato válido"
        
        # Test de acceso al archivo de catálogo
        if [[ ! -z "$GITHUB_TOKEN" ]] && command -v curl >/dev/null 2>&1; then
            # Convertir URL de blob a raw
            RAW_URL=$(echo "$CATALOG_LOCATIONS" | sed 's|github\.com|raw.githubusercontent.com|' | sed 's|/blob/|/|')
            
            CATALOG_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
                -H "Authorization: token $GITHUB_TOKEN" \
                "$RAW_URL")
            
            case $CATALOG_RESPONSE in
                200)
                    log_success "Archivo de catálogo accesible"
                    ;;
                404)
                    log_warning "Archivo de catálogo no encontrado: $RAW_URL"
                    ((WARNINGS++))
                    ;;
                *)
                    log_warning "Respuesta inesperada para archivo de catálogo: HTTP $CATALOG_RESPONSE"
                    ((WARNINGS++))
                    ;;
            esac
        fi
    else
        log_error "CATALOG_LOCATIONS no tiene formato válido de GitHub"
        ((ERRORS++))
    fi
else
    log_warning "CATALOG_LOCATIONS no está configurado"
    ((WARNINGS++))
fi

# Verificar configuración de auto-discovery
if [[ "$GITHUB_AUTODISCOVERY_ENABLED" == "true" ]]; then
    log_success "Auto-discovery de repositorios habilitado"
    
    if [[ ! -z "$GITHUB_AUTODISCOVERY_ORG" ]]; then
        log_success "Organización para auto-discovery: $GITHUB_AUTODISCOVERY_ORG"
    else
        log_warning "GITHUB_AUTODISCOVERY_ORG no configurado"
        ((WARNINGS++))
    fi
    
    if [[ ! -z "$GITHUB_AUTODISCOVERY_TOPICS" ]]; then
        log_success "Topics para auto-discovery: $GITHUB_AUTODISCOVERY_TOPICS"
    else
        log_warning "GITHUB_AUTODISCOVERY_TOPICS no configurado"
        ((WARNINGS++))
    fi
else
    log_info "Auto-discovery de repositorios deshabilitado"
fi

# =============================================================================
# VALIDAR CONFIGURACIÓN DE WEBHOOKS
# =============================================================================

log_info "Validando configuración de webhooks..."

if [[ ! -z "$GITHUB_WEBHOOK_URL" ]]; then
    if [[ "$GITHUB_WEBHOOK_URL" =~ ^https?://[a-zA-Z0-9.-]+:[0-9]+/api/github/webhook$ ]]; then
        log_success "GITHUB_WEBHOOK_URL tiene formato válido"
    else
        log_warning "GITHUB_WEBHOOK_URL podría tener formato incorrecto"
        ((WARNINGS++))
    fi
else
    log_warning "GITHUB_WEBHOOK_URL no configurado"
    ((WARNINGS++))
fi

if [[ ! -z "$GITHUB_WEBHOOK_SECRET" ]]; then
    if [[ ${#GITHUB_WEBHOOK_SECRET} -ge 12 ]]; then
        log_success "GITHUB_WEBHOOK_SECRET configurado con longitud adecuada"
    else
        log_warning "GITHUB_WEBHOOK_SECRET debería tener al menos 12 caracteres"
        ((WARNINGS++))
    fi
else
    log_warning "GITHUB_WEBHOOK_SECRET no configurado"
    ((WARNINGS++))
fi

# =============================================================================
# VALIDAR PERMISOS DEL TOKEN
# =============================================================================

if [[ ! -z "$GITHUB_TOKEN" ]] && command -v curl >/dev/null 2>&1; then
    log_info "Verificando permisos del token..."
    
    # Hacer una request para obtener los headers con los scopes
    SCOPES_RESPONSE=$(curl -s -I -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/user")
    
    if echo "$SCOPES_RESPONSE" | grep -i "x-oauth-scopes" >/dev/null; then
        SCOPES=$(echo "$SCOPES_RESPONSE" | grep -i "x-oauth-scopes" | cut -d: -f2 | tr -d ' \r\n')
        log_success "Scopes del token: $SCOPES"
        
        # Verificar scopes críticos
        REQUIRED_SCOPES=("repo" "read:org" "read:user")
        for scope in "${REQUIRED_SCOPES[@]}"; do
            if echo "$SCOPES" | grep -q "$scope"; then
                log_success "Scope requerido '$scope' presente"
            else
                log_warning "Scope requerido '$scope' faltante"
                ((WARNINGS++))
            fi
        done
    else
        log_warning "No se pudieron obtener los scopes del token"
        ((WARNINGS++))
    fi
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================

echo "=================================================="
echo "📊 Resumen de validación GitHub:"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_success "✨ Todas las validaciones pasaron correctamente"
    log_info "La integración GitHub-Backstage está lista para usar"
    
    # Información adicional
    echo ""
    log_info "🔗 Información de configuración:"
    echo "   Organización: $GITHUB_ORG"
    echo "   Repositorio: $GITHUB_REPO"
    echo "   OAuth Client ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
    echo "   Auto-discovery: $GITHUB_AUTODISCOVERY_ENABLED"
    
    exit 0
elif [ $ERRORS -eq 0 ]; then
    log_warning "⚠️  Validación completada con $WARNINGS advertencias"
    log_info "La integración debería funcionar, pero revisa las advertencias"
    
    exit 0
else
    log_error "❌ Se encontraron $ERRORS errores y $WARNINGS advertencias"
    log_info "Por favor, corrige los errores antes de continuar"
    
    echo ""
    log_info "🔧 Pasos para corregir:"
    echo "   1. Revisa las variables en .env"
    echo "   2. Verifica el token de GitHub en https://github.com/settings/tokens"
    echo "   3. Confirma la configuración OAuth en https://github.com/settings/applications"
    echo "   4. Ejecuta nuevamente este script"
    
    exit 1
fi
