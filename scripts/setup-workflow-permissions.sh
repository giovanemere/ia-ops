#!/bin/bash

# =============================================================================
# Script para Configurar Permisos de Workflow en Repositorios GitHub
# =============================================================================
# Descripción: Automatiza la configuración de permisos de workflow usando GitHub API
# Equivalente a: Settings → Actions → General → Workflow permissions
# =============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración por defecto
DEFAULT_OWNER="giovanemere"
DEFAULT_REPO="ia-ops"
DEFAULT_PERMISSIONS="write"  # write, read, restricted

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           GitHub Workflow Permissions Setup                ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "║              Automated Configuration                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para mostrar ayuda
show_help() {
    show_banner
    echo -e "${YELLOW}Uso: $0 [opciones]${NC}"
    echo ""
    echo -e "${BLUE}Opciones:${NC}"
    echo "  -o, --owner OWNER       Propietario del repositorio (default: $DEFAULT_OWNER)"
    echo "  -r, --repo REPO         Nombre del repositorio (default: $DEFAULT_REPO)"
    echo "  -p, --permissions PERM  Nivel de permisos (write|read|restricted) (default: $DEFAULT_PERMISSIONS)"
    echo "  -t, --token TOKEN       Token de GitHub (si no está en .env)"
    echo "  -l, --list             Listar configuración actual"
    echo "  -c, --check            Solo verificar configuración actual"
    echo "  -m, --multiple         Configurar múltiples repositorios"
    echo "  -h, --help             Mostrar esta ayuda"
    echo ""
    echo -e "${BLUE}Niveles de permisos:${NC}"
    echo "  write      - Read and write permissions (recomendado para CI/CD)"
    echo "  read       - Read repository contents and packages permissions"
    echo "  restricted - Restricted permissions (solo permisos específicos)"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  $0                                    # Configurar repositorio por defecto"
    echo "  $0 -o usuario -r mi-repo -p write    # Configurar repositorio específico"
    echo "  $0 -l                                # Listar configuración actual"
    echo "  $0 -c                                # Solo verificar configuración"
    echo "  $0 -m                                # Configurar múltiples repositorios"
}

# Cargar variables de entorno
load_environment() {
    local env_file="/home/giovanemere/ia-ops/ia-ops/.env"
    
    if [ -f "$env_file" ]; then
        source "$env_file"
        log "✅ Variables de entorno cargadas desde $env_file"
    else
        log_warning "⚠️ Archivo .env no encontrado en $env_file"
    fi
}

# Verificar token de GitHub
verify_github_token() {
    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "❌ GITHUB_TOKEN no está definido"
        echo "   Opciones:"
        echo "   1. Definir en archivo .env: GITHUB_TOKEN=tu_token"
        echo "   2. Usar parámetro -t: $0 -t tu_token"
        echo "   3. Exportar variable: export GITHUB_TOKEN=tu_token"
        return 1
    fi
    
    # Verificar que el token funciona
    local user_info
    user_info=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                     -H "Accept: application/vnd.github.v3+json" \
                     https://api.github.com/user 2>/dev/null)
    
    if echo "$user_info" | grep -q '"login"'; then
        local username=$(echo "$user_info" | grep -o '"login":"[^"]*' | cut -d'"' -f4)
        log "✅ Token válido para usuario: $username"
        return 0
    else
        log_error "❌ Token inválido o sin permisos suficientes"
        return 1
    fi
}

# Obtener configuración actual de permisos
get_current_permissions() {
    local owner="$1"
    local repo="$2"
    
    log_info "🔍 Obteniendo configuración actual de $owner/$repo..."
    
    local response
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    "https://api.github.com/repos/$owner/$repo/actions/permissions" 2>/dev/null)
    
    if echo "$response" | grep -q '"enabled"'; then
        local enabled=$(echo "$response" | grep -o '"enabled":[^,]*' | cut -d':' -f2 | tr -d ' ')
        local allowed_actions=$(echo "$response" | grep -o '"allowed_actions":"[^"]*' | cut -d'"' -f4)
        
        echo ""
        echo -e "${BLUE}📊 Configuración actual de Actions:${NC}"
        echo "   • Actions habilitadas: $enabled"
        echo "   • Acciones permitidas: $allowed_actions"
    else
        log_warning "⚠️ No se pudo obtener configuración de Actions"
    fi
    
    # Obtener permisos de workflow
    local workflow_response
    workflow_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                             -H "Accept: application/vnd.github.v3+json" \
                             "https://api.github.com/repos/$owner/$repo/actions/permissions/workflow" 2>/dev/null)
    
    if echo "$workflow_response" | grep -q '"default_workflow_permissions"'; then
        local default_perms=$(echo "$workflow_response" | grep -o '"default_workflow_permissions":"[^"]*' | cut -d'"' -f4)
        local can_approve_pr=$(echo "$workflow_response" | grep -o '"can_approve_pull_request_reviews":[^,]*' | cut -d':' -f2 | tr -d ' ')
        
        echo -e "${BLUE}📊 Configuración actual de Workflow:${NC}"
        echo "   • Permisos por defecto: $default_perms"
        echo "   • Puede aprobar PRs: $can_approve_pr"
        echo ""
        
        return 0
    else
        log_warning "⚠️ No se pudo obtener configuración de workflow permissions"
        echo "   Posibles causas:"
        echo "   • El repositorio no existe"
        echo "   • El token no tiene permisos suficientes"
        echo "   • El repositorio es privado y el token no tiene acceso"
        return 1
    fi
}

# Configurar permisos de workflow
set_workflow_permissions() {
    local owner="$1"
    local repo="$2"
    local permissions="$3"
    local can_approve_pr="${4:-false}"
    
    log "🔧 Configurando permisos de workflow para $owner/$repo..."
    
    # Mapear permisos legibles a valores de API
    local api_permissions
    case "$permissions" in
        "write")
            api_permissions="write"
            log_info "📝 Configurando: Read and write permissions"
            ;;
        "read")
            api_permissions="read"
            log_info "📖 Configurando: Read repository contents and packages permissions"
            ;;
        "restricted")
            api_permissions="restricted"
            log_info "🔒 Configurando: Restricted permissions"
            ;;
        *)
            log_error "❌ Nivel de permisos inválido: $permissions"
            echo "   Valores válidos: write, read, restricted"
            return 1
            ;;
    esac
    
    # Crear payload JSON
    local payload
    payload=$(cat << EOF
{
  "default_workflow_permissions": "$api_permissions",
  "can_approve_pull_request_reviews": $can_approve_pr
}
EOF
)
    
    log_info "📤 Enviando configuración a GitHub API..."
    
    # Enviar configuración
    local response
    response=$(curl -s -X PUT \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Content-Type: application/json" \
                    -d "$payload" \
                    "https://api.github.com/repos/$owner/$repo/actions/permissions/workflow" 2>/dev/null)
    
    # Verificar respuesta
    if echo "$response" | grep -q '"default_workflow_permissions"'; then
        log "✅ Permisos de workflow configurados exitosamente"
        
        # Mostrar configuración aplicada
        local applied_perms=$(echo "$response" | grep -o '"default_workflow_permissions":"[^"]*' | cut -d'"' -f4)
        local applied_approve=$(echo "$response" | grep -o '"can_approve_pull_request_reviews":[^,]*' | cut -d':' -f2 | tr -d ' ')
        
        echo ""
        echo -e "${GREEN}✅ Configuración aplicada:${NC}"
        echo "   • Permisos por defecto: $applied_perms"
        echo "   • Puede aprobar PRs: $applied_approve"
        
        return 0
    else
        log_error "❌ Error al configurar permisos"
        
        # Mostrar detalles del error si están disponibles
        if echo "$response" | grep -q '"message"'; then
            local error_msg=$(echo "$response" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
            echo "   Error: $error_msg"
        fi
        
        echo "   Respuesta completa: $response"
        return 1
    fi
}

# Configurar múltiples repositorios
configure_multiple_repos() {
    log "🔄 Configuración de múltiples repositorios"
    echo ""
    
    # Lista de repositorios comunes
    local repos=(
        "giovanemere/ia-ops"
        "giovanemere/templates_backstage"
        "giovanemere/ia-ops-framework"
        "giovanemere/poc-billpay-back"
        "giovanemere/poc-billpay-front-a"
        "giovanemere/poc-billpay-front-b"
        "giovanemere/poc-billpay-front-feature-flags"
        "giovanemere/poc-icbs"
    )
    
    echo -e "${BLUE}📋 Repositorios disponibles:${NC}"
    for i in "${!repos[@]}"; do
        echo "   $((i+1)). ${repos[i]}"
    done
    echo "   0. Configurar repositorio personalizado"
    echo ""
    
    read -p "Selecciona repositorios (ej: 1,2,3 o 'all' para todos): " selection
    
    local selected_repos=()
    
    if [ "$selection" = "all" ]; then
        selected_repos=("${repos[@]}")
    elif [ "$selection" = "0" ]; then
        read -p "Ingresa owner/repo: " custom_repo
        selected_repos=("$custom_repo")
    else
        IFS=',' read -ra indices <<< "$selection"
        for index in "${indices[@]}"; do
            index=$((index - 1))
            if [ $index -ge 0 ] && [ $index -lt ${#repos[@]} ]; then
                selected_repos+=("${repos[index]}")
            fi
        done
    fi
    
    if [ ${#selected_repos[@]} -eq 0 ]; then
        log_error "❌ No se seleccionaron repositorios válidos"
        return 1
    fi
    
    read -p "Nivel de permisos (write/read/restricted) [write]: " perm_level
    perm_level=${perm_level:-write}
    
    read -p "¿Permitir aprobar PRs? (y/n) [n]: " approve_prs
    approve_prs=${approve_prs:-n}
    local can_approve="false"
    [ "$approve_prs" = "y" ] && can_approve="true"
    
    echo ""
    log "🚀 Configurando ${#selected_repos[@]} repositorio(s)..."
    
    local success_count=0
    local total_count=${#selected_repos[@]}
    
    for repo_full in "${selected_repos[@]}"; do
        IFS='/' read -r owner repo <<< "$repo_full"
        
        echo ""
        echo "----------------------------------------"
        log_info "📦 Procesando: $owner/$repo"
        
        if set_workflow_permissions "$owner" "$repo" "$perm_level" "$can_approve"; then
            success_count=$((success_count + 1))
        else
            log_warning "⚠️ Error configurando $owner/$repo"
        fi
    done
    
    echo ""
    echo "========================================"
    log "📊 Resumen final:"
    echo "   • Total repositorios: $total_count"
    echo "   • Configurados exitosamente: $success_count"
    echo "   • Con errores: $((total_count - success_count))"
    
    if [ $success_count -eq $total_count ]; then
        log "🎉 ¡Todos los repositorios configurados exitosamente!"
    else
        log_warning "⚠️ Algunos repositorios tuvieron errores"
    fi
}

# Función principal
main() {
    local owner="$DEFAULT_OWNER"
    local repo="$DEFAULT_REPO"
    local permissions="$DEFAULT_PERMISSIONS"
    local list_only=false
    local check_only=false
    local multiple_repos=false
    local custom_token=""
    
    # Procesar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--owner)
                owner="$2"
                shift 2
                ;;
            -r|--repo)
                repo="$2"
                shift 2
                ;;
            -p|--permissions)
                permissions="$2"
                shift 2
                ;;
            -t|--token)
                custom_token="$2"
                shift 2
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -c|--check)
                check_only=true
                shift
                ;;
            -m|--multiple)
                multiple_repos=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa '$0 --help' para ver opciones disponibles"
                exit 1
                ;;
        esac
    done
    
    show_banner
    
    # Cargar entorno
    load_environment
    
    # Usar token personalizado si se proporcionó
    if [ -n "$custom_token" ]; then
        GITHUB_TOKEN="$custom_token"
    fi
    
    # Verificar token
    if ! verify_github_token; then
        exit 1
    fi
    
    # Ejecutar acción solicitada
    if [ "$multiple_repos" = true ]; then
        configure_multiple_repos
    elif [ "$list_only" = true ] || [ "$check_only" = true ]; then
        get_current_permissions "$owner" "$repo"
    else
        echo ""
        log "🎯 Configurando repositorio: $owner/$repo"
        log_info "📋 Nivel de permisos: $permissions"
        echo ""
        
        # Mostrar configuración actual primero
        get_current_permissions "$owner" "$repo"
        
        if [ "$check_only" = false ]; then
            echo ""
            read -p "¿Continuar con la configuración? (y/n) [y]: " confirm
            confirm=${confirm:-y}
            
            if [ "$confirm" = "y" ]; then
                echo ""
                if set_workflow_permissions "$owner" "$repo" "$permissions" "false"; then
                    echo ""
                    log "🎉 ¡Configuración completada exitosamente!"
                    log_info "💡 Los workflows ahora tendrán permisos '$permissions' por defecto"
                else
                    echo ""
                    log_error "❌ Error en la configuración"
                    exit 1
                fi
            else
                log "🚫 Configuración cancelada por el usuario"
            fi
        fi
    fi
}

# Ejecutar función principal
main "$@"
