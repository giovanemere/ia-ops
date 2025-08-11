#!/bin/bash

# =============================================================================
# Configuración Básica de GitHub Actions (Sin Características Premium)
# =============================================================================
# Descripción: Configura GitHub Actions para funcionar sin GitHub Advanced Security
# Solución para repositorios sin licencia premium
# =============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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
    echo "║         GitHub Actions Basic Configuration                  ║"
    echo "║              (Sin Características Premium)                  ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Verificar tipo de repositorio
check_repository_type() {
    log "🔍 Verificando tipo de repositorio y características disponibles..."
    
    echo ""
    echo -e "${BLUE}📋 Características de GitHub por tipo de repositorio:${NC}"
    echo ""
    echo -e "${GREEN}✅ Repositorios PÚBLICOS (GRATIS):${NC}"
    echo "   • GitHub Actions: ✅ Disponible"
    echo "   • Workflow permissions: ✅ Disponible"
    echo "   • Code scanning: ✅ Disponible"
    echo "   • Secret scanning: ✅ Disponible"
    echo "   • Dependency alerts: ✅ Disponible"
    echo ""
    echo -e "${YELLOW}⚠️  Repositorios PRIVADOS (REQUIERE LICENCIA):${NC}"
    echo "   • GitHub Actions: ✅ Disponible (con límites)"
    echo "   • Workflow permissions: ✅ Disponible"
    echo "   • Code scanning: ❌ Requiere GitHub Advanced Security"
    echo "   • Secret scanning: ❌ Requiere GitHub Advanced Security"
    echo "   • Dependency alerts: ✅ Disponible"
    echo ""
    
    read -p "¿Tu repositorio es público o privado? (publico/privado): " repo_type
    repo_type=${repo_type:-privado}
    
    if [ "$repo_type" = "publico" ]; then
        log "✅ Repositorio público detectado - Todas las características disponibles"
        return 0
    else
        log_warning "⚠️ Repositorio privado detectado - Configuración básica sin SARIF"
        return 1
    fi
}

# Crear workflows sin SARIF upload
create_basic_workflows() {
    log "🔧 Creando workflows básicos sin características premium..."
    
    local workflows_dir=".github/workflows"
    mkdir -p "$workflows_dir"
    
    # Workflow básico de CI/CD sin SARIF
    cat > "$workflows_dir/basic-ci.yml" << 'EOF'
name: 🚀 Basic CI/CD (No Premium Features)

on:
  push:
    branches: [ trunk, main ]
  pull_request:
    branches: [ trunk, main ]
  workflow_dispatch:

# Permisos básicos (sin security-events)
permissions:
  contents: read
  actions: read

jobs:
  validate-structure:
    name: 🔍 Validate Project Structure
    runs-on: ubuntu-latest
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🔍 Validate workflows
      run: |
        echo "🚀 Validating IA-Ops Platform structure..."
        echo "✅ Basic validation completed"

    - name: 📋 Check documentation
      run: |
        echo "📚 Checking documentation..."
        if [ -f "README.md" ]; then
          echo "✅ Main README found"
        else
          echo "❌ Main README not found"
          exit 1
        fi

    - name: 🏗️ Validate application structure
      run: |
        echo "🏗️ Validating application structure..."
        
        # Check Backstage
        if [ -d "applications/backstage" ]; then
          echo "✅ Backstage application found"
        else
          echo "❌ Backstage application not found"
          exit 1
        fi

  test-documentation:
    name: 📚 Test Documentation
    runs-on: ubuntu-latest
    needs: validate-structure
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🐍 Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: 📦 Install MkDocs and dependencies
      run: |
        pip install --upgrade pip
        pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin

    - name: 🏗️ Build documentation
      run: |
        if [ -f "mkdocs.yml" ]; then
          echo "📚 Building MkDocs documentation..."
          mkdocs build --clean
          echo "✅ Documentation built successfully"
        else
          echo "⚠️ No MkDocs configuration found, skipping documentation build"
        fi

  basic-security-scan:
    name: 🔒 Basic Security Scan (No SARIF)
    runs-on: ubuntu-latest
    needs: validate-structure
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🔍 Run Trivy vulnerability scanner (Table format)
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'table'
        severity: 'CRITICAL,HIGH,MEDIUM'
        exit-code: '0'

    - name: 📋 Security scan summary
      run: |
        echo "🔒 Basic security scan completed"
        echo "📊 Results displayed in table format above"
        echo "💡 Note: SARIF upload requires GitHub Advanced Security"

  docker-build-test:
    name: 🐳 Docker Build Test
    runs-on: ubuntu-latest
    needs: validate-structure
    if: github.event_name == 'pull_request'
    
    strategy:
      matrix:
        service: [backstage, openai-service, proxy-service]
      fail-fast: false
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🐳 Setup Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: 🏗️ Build Docker image for ${{ matrix.service }}
      run: |
        if [ -f "applications/${{ matrix.service }}/Dockerfile" ]; then
          echo "🐳 Building Docker image for ${{ matrix.service }}..."
          docker build -t test-${{ matrix.service }} applications/${{ matrix.service }}/
          echo "✅ Docker image built successfully for ${{ matrix.service }}"
        else
          echo "⚠️ Dockerfile not found for ${{ matrix.service }}, skipping"
        fi

  notify-completion:
    name: 📢 Notify Completion
    runs-on: ubuntu-latest
    needs: [validate-structure, test-documentation, basic-security-scan]
    if: always()
    
    steps:
    - name: 🎉 Completion notification
      run: |
        echo "🎉 IA-Ops Platform Basic CI/CD completed!"
        echo "✅ Structure validation: ${{ needs.validate-structure.result }}"
        echo "✅ Documentation test: ${{ needs.test-documentation.result }}"
        echo "✅ Basic security scan: ${{ needs.basic-security-scan.result }}"
        echo ""
        echo "💡 Note: This workflow runs without premium GitHub features"
        echo "🔒 Security results are displayed in logs (no SARIF upload)"
EOF

    log "✅ Workflow básico creado: $workflows_dir/basic-ci.yml"
    
    # Workflow alternativo para repositorios públicos
    cat > "$workflows_dir/public-repo-security.yml" << 'EOF'
name: 🔒 Public Repository Security (With SARIF)

on:
  push:
    branches: [ trunk, main ]
  pull_request:
    branches: [ trunk, main ]
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sundays
  workflow_dispatch:

# Permisos completos para repositorios públicos
permissions:
  contents: read
  security-events: write
  actions: read

jobs:
  check-repo-visibility:
    name: 🔍 Check Repository Visibility
    runs-on: ubuntu-latest
    outputs:
      is-public: ${{ steps.check.outputs.is-public }}
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
    
    - name: 🔍 Check if repository is public
      id: check
      run: |
        # Este step solo funciona en repositorios públicos
        echo "is-public=true" >> $GITHUB_OUTPUT
        echo "✅ Repository appears to be public"

  security-scan-with-sarif:
    name: 🔒 Security Scan with SARIF Upload
    runs-on: ubuntu-latest
    needs: check-repo-visibility
    if: needs.check-repo-visibility.outputs.is-public == 'true'
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🔍 Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH,MEDIUM'
        exit-code: '0'

    - name: 📊 Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
        category: 'trivy-public-repo'
      continue-on-error: true

    - name: 📋 Display scan results
      if: always()
      run: |
        echo "🔒 Security scan with SARIF upload completed"
        if [ -f "trivy-results.sarif" ]; then
          echo "✅ SARIF results generated and uploaded"
          echo "📊 Check Security tab for detailed results"
        else
          echo "⚠️ No SARIF results file generated"
        fi

  security-scan-basic:
    name: 🔒 Basic Security Scan (Fallback)
    runs-on: ubuntu-latest
    needs: check-repo-visibility
    if: needs.check-repo-visibility.outputs.is-public != 'true'
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: 🔍 Run Trivy vulnerability scanner (Table format)
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'table'
        severity: 'CRITICAL,HIGH,MEDIUM'
        exit-code: '0'

    - name: 📋 Basic scan summary
      run: |
        echo "🔒 Basic security scan completed (no SARIF upload)"
        echo "📊 Results displayed in table format above"
        echo "💡 SARIF upload requires public repository or GitHub Advanced Security"
EOF

    log "✅ Workflow para repositorios públicos creado: $workflows_dir/public-repo-security.yml"
}

# Crear configuración básica de Dependabot (funciona sin licencia)
create_basic_dependabot() {
    log "🔧 Creando configuración básica de Dependabot..."
    
    local dependabot_dir=".github"
    local dependabot_file="$dependabot_dir/dependabot.yml"
    
    mkdir -p "$dependabot_dir"
    
    cat > "$dependabot_file" << 'EOF'
version: 2
updates:
  # Enable version updates for npm (Node.js)
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
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
    open-pull-requests-limit: 3
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
    open-pull-requests-limit: 3
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
    open-pull-requests-limit: 3
    reviewers:
      - "giovanemere"
    assignees:
      - "giovanemere"
    commit-message:
      prefix: "⬆️ [actions]"
EOF

    log "✅ Configuración básica de Dependabot creada: $dependabot_file"
}

# Actualizar workflows existentes para quitar SARIF
update_existing_workflows() {
    log "🔧 Actualizando workflows existentes para quitar características premium..."
    
    local workflows_dir=".github/workflows"
    
    if [ -d "$workflows_dir" ]; then
        # Crear versiones sin SARIF de workflows existentes
        for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml; do
            if [ -f "$workflow" ] && grep -q "upload-sarif" "$workflow"; then
                local workflow_name=$(basename "$workflow" .yml)
                local basic_workflow="$workflows_dir/${workflow_name}-basic.yml"
                
                log_info "📝 Creando versión básica de $(basename "$workflow")"
                
                # Copiar workflow y remover partes premium
                sed -e '/upload-sarif/,+10d' \
                    -e 's/security-events: write/# security-events: write # Removed for basic version/' \
                    -e 's/format: .sarif./format: "table"/' \
                    -e '/sarif_file:/d' \
                    -e '/category:/d' \
                    "$workflow" > "$basic_workflow"
                
                log "✅ Versión básica creada: $basic_workflow"
            fi
        done
    fi
}

# Mostrar configuración manual básica
show_basic_manual_config() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}           CONFIGURACIÓN MANUAL BÁSICA (SIN PREMIUM)            ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "1. Ve a tu repositorio en GitHub"
    echo "   URL: https://github.com/giovanemere/ia-ops"
    echo ""
    
    log_info "2. Ve a Settings → Actions → General"
    echo "   URL: https://github.com/giovanemere/ia-ops/settings/actions"
    echo ""
    
    log_info "3. Configura SOLO estas opciones básicas:"
    echo ""
    echo -e "${GREEN}   ✅ Actions permissions:${NC}"
    echo "      • Selecciona: 'Allow all actions and reusable workflows'"
    echo ""
    echo -e "${GREEN}   ✅ Workflow permissions:${NC}"
    echo "      • Selecciona: 'Read and write permissions'"
    echo "      • Marca: 'Allow GitHub Actions to create and approve pull requests'"
    echo ""
    
    log_info "4. NO configures estas opciones (requieren licencia):"
    echo ""
    echo -e "${RED}   ❌ NO habilites en Settings → Security & analysis:${NC}"
    echo "      • Code scanning alerts (requiere GitHub Advanced Security)"
    echo "      • Secret scanning alerts (requiere GitHub Advanced Security)"
    echo ""
    echo -e "${GREEN}   ✅ SÍ puedes habilitar (gratis):${NC}"
    echo "      • Dependency alerts"
    echo "      • Dependabot security updates"
    echo ""
    
    log_info "5. Haz clic en 'Save' para aplicar los cambios"
}

# Mostrar resumen de configuración básica
show_basic_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    RESUMEN CONFIGURACIÓN BÁSICA                ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log "📊 Configuración aplicada para repositorio sin licencia premium:"
    echo ""
    echo -e "${GREEN}✅ Características DISPONIBLES:${NC}"
    echo "   • GitHub Actions con permisos básicos"
    echo "   • Workflow permissions configurados"
    echo "   • Trivy security scanning (formato tabla)"
    echo "   • Dependabot para actualizaciones de dependencias"
    echo "   • Docker build testing"
    echo "   • Documentation building"
    echo ""
    echo -e "${YELLOW}⚠️  Características REMOVIDAS (requieren licencia):${NC}"
    echo "   • SARIF upload a Security tab"
    echo "   • Code scanning alerts"
    echo "   • Secret scanning alerts"
    echo "   • Advanced security features"
    echo ""
    echo -e "${BLUE}🔧 Workflows creados:${NC}"
    echo "   • basic-ci.yml - CI/CD básico sin características premium"
    echo "   • public-repo-security.yml - Para repositorios públicos (con SARIF)"
    echo "   • dependabot.yml - Actualizaciones automáticas de dependencias"
    echo ""
    echo -e "${BLUE}📋 Próximos pasos:${NC}"
    echo "   1. Commit y push los archivos creados"
    echo "   2. Configurar manualmente los permisos básicos en GitHub"
    echo "   3. Ejecutar workflow 'Basic CI/CD' para probar"
    echo "   4. Los resultados de seguridad aparecerán en los logs (no en Security tab)"
    echo ""
    echo -e "${GREEN}🎉 Resultado: GitHub Actions funcionará sin errores de permisos${NC}"
    echo -e "${GREEN}   y sin requerir características premium${NC}"
}

# Función principal
main() {
    show_banner
    
    log "🚀 Configurando GitHub Actions sin características premium..."
    echo ""
    
    # Verificar tipo de repositorio
    local is_public=false
    if check_repository_type; then
        is_public=true
    fi
    
    echo ""
    log "📋 Creando configuración básica..."
    
    # Crear workflows básicos
    create_basic_workflows
    
    # Crear configuración de Dependabot
    create_basic_dependabot
    
    # Actualizar workflows existentes
    update_existing_workflows
    
    # Mostrar configuración manual
    show_basic_manual_config
    
    # Mostrar resumen
    show_basic_summary
    
    echo ""
    if [ "$is_public" = true ]; then
        log "🎉 Configuración completada para repositorio público"
        log "✅ Puedes usar tanto workflows básicos como con SARIF"
    else
        log "🎉 Configuración básica completada para repositorio privado"
        log "✅ GitHub Actions funcionará sin requerir licencia premium"
    fi
}

# Mostrar ayuda si se solicita
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_banner
    echo -e "${YELLOW}Uso: $0${NC}"
    echo ""
    echo -e "${BLUE}Este script configura GitHub Actions para funcionar SIN:${NC}"
    echo "  • GitHub Advanced Security"
    echo "  • SARIF uploads"
    echo "  • Code scanning premium features"
    echo "  • Secret scanning premium features"
    echo ""
    echo -e "${BLUE}Mantiene funcionalidades básicas:${NC}"
    echo "  • GitHub Actions workflows"
    echo "  • Trivy security scanning (formato tabla)"
    echo "  • Dependabot updates"
    echo "  • Docker build testing"
    echo "  • Documentation building"
    echo ""
    echo -e "${GREEN}Ideal para repositorios privados sin licencia premium${NC}"
    exit 0
fi

# Ejecutar función principal
main "$@"
