#!/bin/bash

# =============================================================================
# Diagnóstico de Problemas de GitHub Actions
# =============================================================================
# Descripción: Script para diagnosticar y solucionar problemas comunes
# de GitHub Actions, especialmente relacionados con permisos y SARIF uploads
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
    echo "║            GitHub Actions Diagnostic Tool                   ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Verificar estructura de workflows
check_workflows_structure() {
    log "🔍 Verificando estructura de workflows..."
    
    local workflows_dir=".github/workflows"
    
    if [ ! -d "$workflows_dir" ]; then
        log_error "Directorio $workflows_dir no encontrado"
        return 1
    fi
    
    log "✅ Directorio de workflows encontrado: $workflows_dir"
    
    # Listar workflows
    log_info "📋 Workflows encontrados:"
    for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml; do
        if [ -f "$workflow" ]; then
            echo "   • $(basename "$workflow")"
        fi
    done
}

# Verificar permisos en workflows
check_workflow_permissions() {
    log "🔐 Verificando permisos en workflows..."
    
    local workflows_dir=".github/workflows"
    local issues_found=0
    
    for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml; do
        if [ -f "$workflow" ]; then
            local workflow_name=$(basename "$workflow")
            log_info "📄 Analizando: $workflow_name"
            
            # Verificar si tiene permisos definidos
            if grep -q "permissions:" "$workflow"; then
                log "✅ Permisos definidos en $workflow_name"
                
                # Mostrar permisos
                echo "   Permisos encontrados:"
                grep -A 10 "permissions:" "$workflow" | grep -E "^\s+[a-z-]+:" | sed 's/^/     /'
            else
                log_warning "⚠️ No se encontraron permisos definidos en $workflow_name"
                issues_found=$((issues_found + 1))
            fi
            
            # Verificar si usa upload-sarif
            if grep -q "upload-sarif" "$workflow"; then
                log_info "🔍 Workflow $workflow_name usa upload-sarif"
                
                if grep -q "security-events: write" "$workflow"; then
                    log "✅ Permiso security-events: write encontrado"
                else
                    log_error "❌ Falta permiso security-events: write para upload-sarif"
                    issues_found=$((issues_found + 1))
                fi
            fi
        fi
    done
    
    if [ $issues_found -eq 0 ]; then
        log "✅ No se encontraron problemas de permisos"
    else
        log_warning "⚠️ Se encontraron $issues_found problemas de permisos"
    fi
    
    return $issues_found
}

# Verificar configuración de seguridad del repositorio
check_repository_security_settings() {
    log "🔒 Verificando configuración de seguridad del repositorio..."
    
    log_info "📋 Configuraciones recomendadas para GitHub Actions:"
    echo "   • Code scanning alerts: Habilitado"
    echo "   • Dependency alerts: Habilitado"
    echo "   • Secret scanning: Habilitado"
    echo "   • Actions permissions: Allow all actions and reusable workflows"
    echo "   • Workflow permissions: Read repository contents and packages permissions"
    
    log_warning "⚠️ Estas configuraciones deben verificarse manualmente en:"
    echo "   Settings → Security & analysis"
    echo "   Settings → Actions → General"
}

# Generar workflow corregido
generate_fixed_workflow() {
    log "🔧 Generando workflow corregido..."
    
    local fixed_workflow=".github/workflows/security-scan-fixed.yml"
    
    cat > "$fixed_workflow" << 'EOF'
name: 🔒 Security Scan (Fixed)

on:
  push:
    branches: [ trunk, main ]
  pull_request:
    branches: [ trunk, main ]
  workflow_dispatch:

# Permisos necesarios para security scanning
permissions:
  contents: read
  security-events: write
  actions: read

jobs:
  security-scan:
    name: 🔍 Trivy Security Scan
    runs-on: ubuntu-latest
    
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

    - name: 📊 Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
        category: 'trivy-security-scan'
      continue-on-error: true

    - name: 📋 Display scan results
      if: always()
      run: |
        echo "🔒 Security scan completed"
        if [ -f "trivy-results.sarif" ]; then
          echo "✅ SARIF results generated successfully"
          echo "📊 Results file size: $(du -h trivy-results.sarif | cut -f1)"
        else
          echo "❌ No SARIF results file generated"
        fi
EOF

    log "✅ Workflow corregido generado: $fixed_workflow"
    log_info "📋 Para usar este workflow:"
    echo "   1. Revisa el archivo generado"
    echo "   2. Renombra o reemplaza tu workflow actual"
    echo "   3. Commit y push los cambios"
    echo "   4. Verifica que el workflow se ejecute correctamente"
}

# Mostrar soluciones comunes
show_common_solutions() {
    log "💡 Soluciones comunes para problemas de GitHub Actions:"
    
    echo ""
    echo -e "${YELLOW}🔧 Problema: Resource not accessible by integration${NC}"
    echo "   Solución:"
    echo "   1. Agregar permisos al workflow:"
    echo "      permissions:"
    echo "        contents: read"
    echo "        security-events: write"
    echo "        actions: read"
    echo ""
    
    echo -e "${YELLOW}🔧 Problema: SARIF upload fails${NC}"
    echo "   Solución:"
    echo "   1. Verificar que el repositorio tenga Code Scanning habilitado"
    echo "   2. Usar continue-on-error: true en el step de upload"
    echo "   3. Verificar que el archivo SARIF sea válido"
    echo ""
    
    echo -e "${YELLOW}🔧 Problema: Workflow permissions denied${NC}"
    echo "   Solución:"
    echo "   1. Ir a Settings → Actions → General"
    echo "   2. En 'Workflow permissions' seleccionar:"
    echo "      'Read and write permissions' o configurar permisos específicos"
    echo ""
    
    echo -e "${YELLOW}🔧 Problema: Token permissions insufficient${NC}"
    echo "   Solución:"
    echo "   1. Verificar que GITHUB_TOKEN tenga los permisos necesarios"
    echo "   2. Considerar usar un Personal Access Token si es necesario"
    echo "   3. Verificar configuración de branch protection rules"
}

# Función principal
main() {
    show_banner
    
    log "🚀 Iniciando diagnóstico de GitHub Actions..."
    
    # Verificar que estamos en un repositorio git
    if [ ! -d ".git" ]; then
        log_error "No estás en un repositorio Git"
        exit 1
    fi
    
    # Ejecutar verificaciones
    check_workflows_structure
    echo ""
    
    local permission_issues=0
    check_workflow_permissions || permission_issues=$?
    echo ""
    
    check_repository_security_settings
    echo ""
    
    # Generar workflow corregido si hay problemas
    if [ $permission_issues -gt 0 ]; then
        generate_fixed_workflow
        echo ""
    fi
    
    show_common_solutions
    
    log "✅ Diagnóstico completado"
    
    if [ $permission_issues -gt 0 ]; then
        log_warning "⚠️ Se encontraron $permission_issues problemas que requieren atención"
        exit 1
    else
        log "🎉 No se encontraron problemas críticos"
    fi
}

# Verificar argumentos
case "${1:-diagnose}" in
    diagnose)
        main
        ;;
    fix)
        log "🔧 Aplicando correcciones automáticas..."
        generate_fixed_workflow
        log "✅ Correcciones aplicadas"
        ;;
    help|--help|-h)
        show_banner
        echo -e "${YELLOW}Uso: $0 [diagnose|fix|help]${NC}"
        echo ""
        echo -e "${BLUE}Comandos:${NC}"
        echo "  diagnose  - Ejecutar diagnóstico completo (por defecto)"
        echo "  fix       - Generar workflow corregido"
        echo "  help      - Mostrar esta ayuda"
        ;;
    *)
        log_error "Comando no reconocido: $1"
        echo "Usa '$0 help' para ver comandos disponibles"
        exit 1
        ;;
esac
