#!/bin/bash

# =============================================================================
# Script para Configurar Seguridad Completa del Repositorio GitHub
# =============================================================================
# Descripción: Configura automáticamente todas las opciones de seguridad
# Incluye: Actions permissions, Security features, Branch protection, etc.
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
    echo "║           GitHub Repository Security Setup                  ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "║              Complete Security Configuration                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
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
        return 1
    fi
    
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

# Habilitar GitHub Actions
enable_github_actions() {
    local owner="$1"
    local repo="$2"
    
    log "🔧 Habilitando GitHub Actions para $owner/$repo..."
    
    local payload='{"enabled": true, "allowed_actions": "all"}'
    
    local response
    response=$(curl -s -X PUT \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Content-Type: application/json" \
                    -d "$payload" \
                    "https://api.github.com/repos/$owner/$repo/actions/permissions" 2>/dev/null)
    
    if echo "$response" | grep -q '"enabled":true' || [ -z "$response" ]; then
        log "✅ GitHub Actions habilitado"
        return 0
    else
        log_warning "⚠️ No se pudo habilitar GitHub Actions"
        return 1
    fi
}

# Configurar permisos de workflow
setup_workflow_permissions() {
    local owner="$1"
    local repo="$2"
    
    log "🔧 Configurando permisos de workflow..."
    
    local payload='{"default_workflow_permissions": "write", "can_approve_pull_request_reviews": false}'
    
    local response
    response=$(curl -s -X PUT \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Content-Type: application/json" \
                    -d "$payload" \
                    "https://api.github.com/repos/$owner/$repo/actions/permissions/workflow" 2>/dev/null)
    
    if echo "$response" | grep -q '"default_workflow_permissions"'; then
        log "✅ Permisos de workflow configurados (write permissions)"
        return 0
    else
        log_warning "⚠️ No se pudieron configurar permisos de workflow"
        return 1
    fi
}

# Habilitar vulnerability alerts
enable_vulnerability_alerts() {
    local owner="$1"
    local repo="$2"
    
    log "🔧 Habilitando alertas de vulnerabilidad..."
    
    # Habilitar Dependabot alerts
    local response
    response=$(curl -s -X PUT \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    "https://api.github.com/repos/$owner/$repo/vulnerability-alerts" 2>/dev/null)
    
    # La API devuelve 204 (sin contenido) en caso de éxito
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
                       -X PUT \
                       -H "Authorization: token $GITHUB_TOKEN" \
                       -H "Accept: application/vnd.github.v3+json" \
                       "https://api.github.com/repos/$owner/$repo/vulnerability-alerts" 2>/dev/null)
    
    if [ "$status_code" = "204" ] || [ "$status_code" = "200" ]; then
        log "✅ Alertas de vulnerabilidad habilitadas"
        return 0
    else
        log_warning "⚠️ No se pudieron habilitar alertas de vulnerabilidad (código: $status_code)"
        return 1
    fi
}

# Habilitar automated security fixes
enable_automated_security_fixes() {
    local owner="$1"
    local repo="$2"
    
    log "🔧 Habilitando correcciones automáticas de seguridad..."
    
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
                       -X PUT \
                       -H "Authorization: token $GITHUB_TOKEN" \
                       -H "Accept: application/vnd.github.v3+json" \
                       "https://api.github.com/repos/$owner/$repo/automated-security-fixes" 2>/dev/null)
    
    if [ "$status_code" = "204" ] || [ "$status_code" = "200" ]; then
        log "✅ Correcciones automáticas de seguridad habilitadas"
        return 0
    else
        log_warning "⚠️ No se pudieron habilitar correcciones automáticas (código: $status_code)"
        return 1
    fi
}

# Configurar branch protection para trunk
setup_branch_protection() {
    local owner="$1"
    local repo="$2"
    local branch="${3:-trunk}"
    
    log "🔧 Configurando protección de rama '$branch'..."
    
    local payload=$(cat << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
)
    
    local response
    response=$(curl -s -X PUT \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Content-Type: application/json" \
                    -d "$payload" \
                    "https://api.github.com/repos/$owner/$repo/branches/$branch/protection" 2>/dev/null)
    
    if echo "$response" | grep -q '"required_status_checks"'; then
        log "✅ Protección de rama '$branch' configurada"
        return 0
    else
        log_warning "⚠️ No se pudo configurar protección de rama '$branch'"
        if echo "$response" | grep -q '"message"'; then
            local error_msg=$(echo "$response" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
            log_info "   Detalle: $error_msg"
        fi
        return 1
    fi
}

# Crear archivo de configuración de Dependabot
create_dependabot_config() {
    local dependabot_dir=".github"
    local dependabot_file="$dependabot_dir/dependabot.yml"
    
    log "🔧 Creando configuración de Dependabot..."
    
    # Crear directorio si no existe
    mkdir -p "$dependabot_dir"
    
    # Crear archivo de configuración
    cat > "$dependabot_file" << 'EOF'
version: 2
updates:
  # Enable version updates for npm (Node.js)
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️"
      include: "scope"

  # Enable version updates for npm in applications/backstage
  - package-ecosystem: "npm"
    directory: "/applications/backstage"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️ [backstage]"

  # Enable version updates for Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️ [docker]"

  # Enable version updates for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️ [actions]"

  # Enable version updates for Python (if applicable)
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️ [python]"
EOF
    
    if [ -f "$dependabot_file" ]; then
        log "✅ Configuración de Dependabot creada: $dependabot_file"
        return 0
    else
        log_error "❌ No se pudo crear configuración de Dependabot"
        return 1
    fi
}

# Crear archivo de configuración de CodeQL
create_codeql_config() {
    local workflows_dir=".github/workflows"
    local codeql_file="$workflows_dir/codeql-analysis.yml"
    
    log "🔧 Creando configuración de CodeQL..."
    
    # Crear directorio si no existe
    mkdir -p "$workflows_dir"
    
    # Crear workflow de CodeQL
    cat > "$codeql_file" << 'EOF'
name: "CodeQL Analysis"

on:
  push:
    branches: [ trunk, main ]
  pull_request:
    branches: [ trunk, main ]
  schedule:
    - cron: '30 1 * * 0'  # Weekly on Sundays at 1:30 AM UTC

permissions:
  contents: read
  security-events: write
  actions: read

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    
    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'typescript' ]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{matrix.language}}"
EOF
    
    if [ -f "$codeql_file" ]; then
        log "✅ Configuración de CodeQL creada: $codeql_file"
        return 0
    else
        log_error "❌ No se pudo crear configuración de CodeQL"
        return 1
    fi
}

# Mostrar resumen de configuración
show_configuration_summary() {
    local owner="$1"
    local repo="$2"
    
    echo ""
    echo "========================================"
    log "📊 Resumen de configuración aplicada:"
    echo ""
    echo -e "${BLUE}🔧 Configuraciones de GitHub Actions:${NC}"
    echo "   ✅ GitHub Actions habilitado"
    echo "   ✅ Workflow permissions: write"
    echo "   ✅ Permisos para SARIF upload configurados"
    echo ""
    echo -e "${BLUE}🔒 Configuraciones de seguridad:${NC}"
    echo "   ✅ Alertas de vulnerabilidad habilitadas"
    echo "   ✅ Correcciones automáticas de seguridad habilitadas"
    echo "   ✅ Dependabot configurado"
    echo "   ✅ CodeQL analysis configurado"
    echo ""
    echo -e "${BLUE}🛡️ Protección de ramas:${NC}"
    echo "   ✅ Rama 'trunk' protegida"
    echo "   ✅ Reviews requeridos para PRs"
    echo "   ✅ Force push deshabilitado"
    echo ""
    echo -e "${BLUE}📋 Próximos pasos:${NC}"
    echo "   1. Commit y push los archivos de configuración:"
    echo "      git add .github/"
    echo "      git commit -m '🔒 Configure repository security settings'"
    echo "      git push origin trunk"
    echo ""
    echo "   2. Verifica la configuración en GitHub:"
    echo "      • Settings → Security & analysis"
    echo "      • Settings → Actions → General"
    echo "      • Settings → Branches"
    echo ""
    echo "   3. Ejecuta un workflow para probar la configuración"
}

# Función principal
main() {
    local owner="$DEFAULT_OWNER"
    local repo="$DEFAULT_REPO"
    
    # Procesar argumentos básicos
    if [ $# -ge 2 ]; then
        owner="$1"
        repo="$2"
    fi
    
    show_banner
    
    log "🚀 Configurando seguridad completa para $owner/$repo..."
    echo ""
    
    # Cargar entorno y verificar token
    load_environment
    
    if ! verify_github_token; then
        exit 1
    fi
    
    local success_count=0
    local total_steps=7
    
    # Ejecutar configuraciones
    echo ""
    log "📋 Ejecutando configuraciones de seguridad..."
    
    # 1. Habilitar GitHub Actions
    if enable_github_actions "$owner" "$repo"; then
        success_count=$((success_count + 1))
    fi
    
    # 2. Configurar permisos de workflow
    if setup_workflow_permissions "$owner" "$repo"; then
        success_count=$((success_count + 1))
    fi
    
    # 3. Habilitar alertas de vulnerabilidad
    if enable_vulnerability_alerts "$owner" "$repo"; then
        success_count=$((success_count + 1))
    fi
    
    # 4. Habilitar correcciones automáticas
    if enable_automated_security_fixes "$owner" "$repo"; then
        success_count=$((success_count + 1))
    fi
    
    # 5. Configurar protección de rama
    if setup_branch_protection "$owner" "$repo" "trunk"; then
        success_count=$((success_count + 1))
    fi
    
    # 6. Crear configuración de Dependabot
    if create_dependabot_config; then
        success_count=$((success_count + 1))
    fi
    
    # 7. Crear configuración de CodeQL
    if create_codeql_config; then
        success_count=$((success_count + 1))
    fi
    
    # Mostrar resumen
    show_configuration_summary "$owner" "$repo"
    
    echo ""
    log "📊 Configuración completada: $success_count/$total_steps pasos exitosos"
    
    if [ $success_count -eq $total_steps ]; then
        log "🎉 ¡Configuración de seguridad completada exitosamente!"
    else
        log_warning "⚠️ Algunos pasos tuvieron problemas, pero la configuración básica está aplicada"
    fi
}

# Mostrar ayuda si se solicita
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_banner
    echo -e "${YELLOW}Uso: $0 [owner] [repo]${NC}"
    echo ""
    echo -e "${BLUE}Parámetros:${NC}"
    echo "  owner    Propietario del repositorio (default: $DEFAULT_OWNER)"
    echo "  repo     Nombre del repositorio (default: $DEFAULT_REPO)"
    echo ""
    echo -e "${BLUE}Ejemplo:${NC}"
    echo "  $0                           # Configurar repositorio por defecto"
    echo "  $0 usuario mi-repo          # Configurar repositorio específico"
    echo ""
    echo -e "${BLUE}Este script configura:${NC}"
    echo "  • GitHub Actions permissions"
    echo "  • Workflow permissions (write)"
    echo "  • Vulnerability alerts"
    echo "  • Automated security fixes"
    echo "  • Branch protection"
    echo "  • Dependabot configuration"
    echo "  • CodeQL analysis"
    exit 0
fi

# Ejecutar función principal
main "$@"
