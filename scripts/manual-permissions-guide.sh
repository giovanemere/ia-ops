#!/bin/bash

# =============================================================================
# Guía Manual para Configurar Permisos de GitHub
# =============================================================================
# Descripción: Proporciona instrucciones paso a paso para configurar
# manualmente los permisos cuando la API no está disponible
# =============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         GitHub Permissions Manual Configuration            ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "║              Step-by-Step Guide                             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para logging
log() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log_info() {
    echo -e "${BLUE}[STEP] $1${NC}"
}

# Mostrar configuración de Actions
show_actions_configuration() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    GITHUB ACTIONS CONFIGURATION                ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "1. Ve a tu repositorio en GitHub"
    echo "   URL: https://github.com/giovanemere/ia-ops"
    echo ""
    
    log_info "2. Haz clic en 'Settings' (en la barra superior del repositorio)"
    echo ""
    
    log_info "3. En el menú lateral izquierdo, haz clic en 'Actions'"
    echo "   Luego selecciona 'General'"
    echo ""
    
    log_info "4. En la sección 'Actions permissions':"
    echo "   ✅ Selecciona: 'Allow all actions and reusable workflows'"
    echo "   ✅ O selecciona: 'Allow [organization] actions and reusable workflows'"
    echo ""
    
    log_info "5. En la sección 'Workflow permissions':"
    echo -e "   ${GREEN}✅ Selecciona: 'Read and write permissions'${NC}"
    echo -e "   ${GREEN}✅ Marca: 'Allow GitHub Actions to create and approve pull requests'${NC}"
    echo ""
    
    log_info "6. Haz clic en 'Save' para aplicar los cambios"
    echo ""
    
    echo -e "${YELLOW}💡 IMPORTANTE: Esta configuración resuelve el error:${NC}"
    echo -e "${RED}   'Resource not accessible by integration'${NC}"
}

# Mostrar configuración de Security
show_security_configuration() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    SECURITY FEATURES CONFIGURATION            ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "1. Ve a 'Settings' → 'Security & analysis'"
    echo "   URL: https://github.com/giovanemere/ia-ops/settings/security_analysis"
    echo ""
    
    log_info "2. Habilita las siguientes opciones:"
    echo ""
    
    echo -e "${BLUE}   🔒 Dependency alerts:${NC}"
    echo "   ✅ Haz clic en 'Enable' si no está habilitado"
    echo ""
    
    echo -e "${BLUE}   🔒 Dependabot security updates:${NC}"
    echo "   ✅ Haz clic en 'Enable' si no está habilitado"
    echo ""
    
    echo -e "${BLUE}   🔒 Code scanning alerts:${NC}"
    echo "   ✅ Haz clic en 'Set up' → 'Set up CodeQL analysis'"
    echo "   ✅ O haz clic en 'Enable' si ya está configurado"
    echo ""
    
    echo -e "${BLUE}   🔒 Secret scanning alerts:${NC}"
    echo "   ✅ Haz clic en 'Enable' (disponible para repositorios públicos)"
    echo ""
    
    log_info "3. Estas configuraciones permiten:"
    echo "   • Subida de resultados SARIF"
    echo "   • Alertas automáticas de vulnerabilidades"
    echo "   • Análisis de código automático"
}

# Mostrar configuración de Branch Protection
show_branch_protection_configuration() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    BRANCH PROTECTION CONFIGURATION            ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "1. Ve a 'Settings' → 'Branches'"
    echo "   URL: https://github.com/giovanemere/ia-ops/settings/branches"
    echo ""
    
    log_info "2. Haz clic en 'Add rule' para la rama 'trunk'"
    echo ""
    
    log_info "3. Configura las siguientes opciones:"
    echo ""
    
    echo -e "${BLUE}   📝 Branch name pattern:${NC}"
    echo "   ✅ Escribe: trunk"
    echo ""
    
    echo -e "${BLUE}   🔒 Protect matching branches:${NC}"
    echo "   ✅ Require a pull request before merging"
    echo "   ✅ Require status checks to pass before merging"
    echo "   ✅ Require branches to be up to date before merging"
    echo "   ✅ Restrict pushes that create files larger than 100MB"
    echo ""
    
    log_info "4. Haz clic en 'Create' para aplicar la protección"
}

# Mostrar verificación de configuración
show_verification_steps() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    VERIFICATION STEPS                         ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "1. Ejecuta un workflow para probar la configuración:"
    echo "   • Ve a 'Actions' tab"
    echo "   • Selecciona 'Security Scan' o 'IA-Ops Platform CI/CD'"
    echo "   • Haz clic en 'Run workflow'"
    echo ""
    
    log_info "2. Verifica que no aparezcan estos errores:"
    echo -e "   ${RED}❌ Resource not accessible by integration${NC}"
    echo -e "   ${RED}❌ Workflow permissions denied${NC}"
    echo -e "   ${RED}❌ Token permissions insufficient${NC}"
    echo ""
    
    log_info "3. Verifica que aparezcan estos mensajes de éxito:"
    echo -e "   ${GREEN}✅ Successfully uploaded results${NC}"
    echo -e "   ${GREEN}✅ Processing sarif files${NC}"
    echo -e "   ${GREEN}✅ Validating [archivo].sarif${NC}"
    echo ""
    
    log_info "4. Verifica que los resultados aparezcan en:"
    echo "   • Security tab: https://github.com/giovanemere/ia-ops/security"
    echo "   • Code scanning: https://github.com/giovanemere/ia-ops/security/code-scanning"
}

# Mostrar troubleshooting
show_troubleshooting() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    TROUBLESHOOTING                            ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}🔧 Si aún tienes problemas:${NC}"
    echo ""
    
    echo -e "${BLUE}Problema: 'Resource not accessible by integration'${NC}"
    echo "Solución:"
    echo "   1. Verifica Settings → Actions → General → Workflow permissions"
    echo "   2. Debe estar en 'Read and write permissions'"
    echo "   3. Reinicia el workflow"
    echo ""
    
    echo -e "${BLUE}Problema: 'SARIF upload fails'${NC}"
    echo "Solución:"
    echo "   1. Verifica que Code scanning esté habilitado"
    echo "   2. Verifica que el repositorio sea público o tenga GitHub Advanced Security"
    echo "   3. Revisa que el archivo SARIF sea válido"
    echo ""
    
    echo -e "${BLUE}Problema: 'Token permissions insufficient'${NC}"
    echo "Solución:"
    echo "   1. Crea un nuevo Personal Access Token con estos scopes:"
    echo "      • repo (Full control of private repositories)"
    echo "      • workflow (Update GitHub Action workflows)"
    echo "      • security_events (Read and write security events)"
    echo "   2. Actualiza el token en tu archivo .env"
    echo ""
    
    echo -e "${BLUE}Problema: 'Workflow permissions denied'${NC}"
    echo "Solución:"
    echo "   1. Ve a Settings → Actions → General"
    echo "   2. En 'Workflow permissions' selecciona 'Read and write permissions'"
    echo "   3. Marca 'Allow GitHub Actions to create and approve pull requests'"
}

# Crear checklist interactivo
create_interactive_checklist() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    INTERACTIVE CHECKLIST                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local checklist_file="github-permissions-checklist.md"
    
    cat > "$checklist_file" << 'EOF'
# 🔒 GitHub Permissions Configuration Checklist

## ✅ Actions Configuration
- [ ] Ve a Settings → Actions → General
- [ ] Actions permissions: "Allow all actions and reusable workflows"
- [ ] Workflow permissions: "Read and write permissions"
- [ ] Allow GitHub Actions to create and approve pull requests: ✅

## ✅ Security & Analysis
- [ ] Ve a Settings → Security & analysis
- [ ] Dependency alerts: Enabled
- [ ] Dependabot security updates: Enabled
- [ ] Code scanning alerts: Enabled
- [ ] Secret scanning alerts: Enabled (si está disponible)

## ✅ Branch Protection
- [ ] Ve a Settings → Branches
- [ ] Add rule para rama "trunk"
- [ ] Require a pull request before merging: ✅
- [ ] Require status checks to pass before merging: ✅
- [ ] Require branches to be up to date before merging: ✅

## ✅ Verification
- [ ] Ejecutar workflow manualmente
- [ ] Verificar que no hay errores de permisos
- [ ] Verificar que SARIF se sube correctamente
- [ ] Verificar resultados en Security tab

## 🔧 URLs Importantes
- Repository Settings: https://github.com/giovanemere/ia-ops/settings
- Actions Settings: https://github.com/giovanemere/ia-ops/settings/actions
- Security Settings: https://github.com/giovanemere/ia-ops/settings/security_analysis
- Branch Settings: https://github.com/giovanemere/ia-ops/settings/branches
- Security Tab: https://github.com/giovanemere/ia-ops/security
- Actions Tab: https://github.com/giovanemere/ia-ops/actions

## 📝 Notes
- Fecha de configuración: $(date)
- Configurado por: Manual setup script
- Repositorio: giovanemere/ia-ops
EOF
    
    log "✅ Checklist creado: $checklist_file"
    echo "   Puedes usar este archivo para hacer seguimiento de tu progreso"
}

# Función principal
main() {
    show_banner
    
    echo ""
    log "🚀 Guía manual para configurar permisos de GitHub"
    log "📋 Esta guía te ayudará a configurar manualmente todos los permisos necesarios"
    echo ""
    
    # Mostrar todas las secciones
    show_actions_configuration
    show_security_configuration
    show_branch_protection_configuration
    show_verification_steps
    show_troubleshooting
    
    # Crear checklist
    create_interactive_checklist
    
    echo ""
    echo -e "${GREEN}🎉 ¡Guía completa mostrada!${NC}"
    echo ""
    echo -e "${BLUE}📋 Resumen de pasos:${NC}"
    echo "   1. Configurar Actions permissions (Settings → Actions → General)"
    echo "   2. Habilitar Security features (Settings → Security & analysis)"
    echo "   3. Configurar Branch protection (Settings → Branches)"
    echo "   4. Verificar configuración ejecutando un workflow"
    echo "   5. Revisar resultados en Security tab"
    echo ""
    echo -e "${YELLOW}💡 Tip: Usa el archivo 'github-permissions-checklist.md' para hacer seguimiento${NC}"
}

# Mostrar ayuda si se solicita
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_banner
    echo -e "${YELLOW}Uso: $0${NC}"
    echo ""
    echo -e "${BLUE}Este script proporciona:${NC}"
    echo "  • Instrucciones paso a paso para configurar permisos"
    echo "  • Guía de configuración de seguridad"
    echo "  • Checklist interactivo"
    echo "  • Troubleshooting común"
    echo ""
    echo -e "${BLUE}No requiere parámetros, solo ejecuta:${NC}"
    echo "  $0"
    exit 0
fi

# Ejecutar función principal
main "$@"
