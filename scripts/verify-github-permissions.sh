#!/bin/bash

# =============================================================================
# Verificación de Permisos de GitHub Post-Configuración
# =============================================================================
# Descripción: Script para verificar que los permisos del token y workflows
# están funcionando correctamente después de los cambios
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
    echo "║         GitHub Permissions Verification Tool               ║"
    echo "║                  IA-Ops Platform                            ║"
    echo "║              Post-Configuration Check                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Verificar variables de entorno de GitHub
check_github_env_vars() {
    log "🔍 Verificando variables de entorno de GitHub..."
    
    if [ -f "/home/giovanemere/ia-ops/ia-ops/.env" ]; then
        source "/home/giovanemere/ia-ops/ia-ops/.env"
        
        if [ -n "$GITHUB_TOKEN" ]; then
            log "✅ GITHUB_TOKEN encontrado: ${GITHUB_TOKEN:0:15}..."
            
            # Verificar longitud del token (debe ser ~40 caracteres para classic, ~93 para fine-grained)
            token_length=${#GITHUB_TOKEN}
            if [ $token_length -ge 40 ]; then
                log "✅ Token tiene longitud válida: $token_length caracteres"
            else
                log_warning "⚠️ Token parece ser muy corto: $token_length caracteres"
            fi
        else
            log_error "❌ GITHUB_TOKEN no encontrado en .env"
            return 1
        fi
        
        if [ -n "$GITHUB_ORG" ]; then
            log "✅ GITHUB_ORG configurado: $GITHUB_ORG"
        else
            log_warning "⚠️ GITHUB_ORG no configurado"
        fi
    else
        log_error "❌ Archivo .env no encontrado"
        return 1
    fi
}

# Verificar conectividad con GitHub API
test_github_api_connectivity() {
    log "🌐 Probando conectividad con GitHub API..."
    
    if command -v curl >/dev/null 2>&1; then
        # Test básico de conectividad
        if curl -s --max-time 10 https://api.github.com/rate_limit > /dev/null; then
            log "✅ Conectividad con GitHub API exitosa"
            
            # Mostrar rate limit info
            rate_limit_info=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit 2>/dev/null || echo "Error getting rate limit")
            if echo "$rate_limit_info" | grep -q "rate"; then
                remaining=$(echo "$rate_limit_info" | grep -o '"remaining":[0-9]*' | cut -d':' -f2)
                limit=$(echo "$rate_limit_info" | grep -o '"limit":[0-9]*' | cut -d':' -f2)
                log_info "📊 Rate limit: $remaining/$limit requests restantes"
            fi
        else
            log_error "❌ No se puede conectar con GitHub API"
            return 1
        fi
    else
        log_warning "⚠️ curl no disponible, saltando test de conectividad"
    fi
}

# Verificar permisos específicos del token
test_token_permissions() {
    log "🔐 Verificando permisos específicos del token..."
    
    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "❌ GITHUB_TOKEN no está disponible"
        return 1
    fi
    
    # Test de permisos básicos
    log_info "🔍 Probando permisos básicos..."
    
    # Test repo access
    if curl -s -H "Authorization: token $GITHUB_TOKEN" \
       "https://api.github.com/user/repos?per_page=1" | grep -q "full_name"; then
        log "✅ Permiso de lectura de repositorios: OK"
    else
        log_warning "⚠️ Permiso de lectura de repositorios: Limitado o no disponible"
    fi
    
    # Test user info
    if curl -s -H "Authorization: token $GITHUB_TOKEN" \
       "https://api.github.com/user" | grep -q "login"; then
        log "✅ Permiso de información de usuario: OK"
    else
        log_warning "⚠️ Permiso de información de usuario: No disponible"
    fi
}

# Verificar configuración de workflows
verify_workflow_configuration() {
    log "📋 Verificando configuración de workflows..."
    
    local workflows_with_sarif=0
    local workflows_with_correct_permissions=0
    
    for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
        if [ -f "$workflow" ]; then
            local workflow_name=$(basename "$workflow")
            
            if grep -q "upload-sarif" "$workflow"; then
                workflows_with_sarif=$((workflows_with_sarif + 1))
                log_info "🔍 $workflow_name usa upload-sarif"
                
                if grep -q "security-events: write" "$workflow"; then
                    workflows_with_correct_permissions=$((workflows_with_correct_permissions + 1))
                    log "✅ $workflow_name tiene permisos correctos para SARIF"
                else
                    log_error "❌ $workflow_name falta permiso security-events: write"
                fi
            fi
        fi
    done
    
    log_info "📊 Resumen de workflows:"
    echo "   • Workflows con upload-sarif: $workflows_with_sarif"
    echo "   • Workflows con permisos correctos: $workflows_with_correct_permissions"
    
    if [ $workflows_with_sarif -eq $workflows_with_correct_permissions ] && [ $workflows_with_sarif -gt 0 ]; then
        log "✅ Todos los workflows que usan SARIF tienen permisos correctos"
    elif [ $workflows_with_sarif -eq 0 ]; then
        log_info "ℹ️ No se encontraron workflows que usen upload-sarif"
    else
        log_warning "⚠️ Algunos workflows necesitan corrección de permisos"
    fi
}

# Simular un test de SARIF upload (sin ejecutar realmente)
simulate_sarif_upload_test() {
    log "🧪 Simulando test de SARIF upload..."
    
    # Crear un archivo SARIF de prueba mínimo
    local test_sarif="test-sarif-sample.json"
    cat > "$test_sarif" << 'EOF'
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "test-tool",
          "version": "1.0.0"
        }
      },
      "results": []
    }
  ]
}
EOF
    
    if [ -f "$test_sarif" ]; then
        log "✅ Archivo SARIF de prueba creado: $test_sarif"
        
        # Verificar que es JSON válido
        if command -v jq >/dev/null 2>&1; then
            if jq . "$test_sarif" > /dev/null 2>&1; then
                log "✅ Archivo SARIF es JSON válido"
            else
                log_error "❌ Archivo SARIF no es JSON válido"
            fi
        else
            log_info "ℹ️ jq no disponible, saltando validación JSON"
        fi
        
        # Limpiar archivo de prueba
        rm -f "$test_sarif"
        log_info "🧹 Archivo de prueba limpiado"
    else
        log_error "❌ No se pudo crear archivo SARIF de prueba"
    fi
}

# Mostrar recomendaciones finales
show_final_recommendations() {
    log "💡 Recomendaciones finales:"
    
    echo ""
    echo -e "${BLUE}🔧 Para probar completamente la configuración:${NC}"
    echo "   1. Haz push de los cambios a GitHub:"
    echo "      git add ."
    echo "      git commit -m '🔒 Update GitHub Actions permissions'"
    echo "      git push origin trunk"
    echo ""
    echo "   2. Ve a GitHub Actions y ejecuta manualmente un workflow:"
    echo "      • Ve a Actions tab en tu repositorio"
    echo "      • Selecciona 'Security Scan' o 'IA-Ops Platform CI/CD'"
    echo "      • Haz clic en 'Run workflow'"
    echo ""
    echo "   3. Verifica los resultados:"
    echo "      • Revisa que no aparezcan errores de permisos"
    echo "      • Verifica que los resultados SARIF se suban al Security tab"
    echo "      • Confirma que no hay warnings sobre 'Resource not accessible'"
    echo ""
    echo -e "${BLUE}🔍 URLs importantes para verificar:${NC}"
    echo "   • Actions: https://github.com/tu-usuario/ia-ops/actions"
    echo "   • Security: https://github.com/tu-usuario/ia-ops/security"
    echo "   • Settings: https://github.com/tu-usuario/ia-ops/settings"
    echo ""
    echo -e "${BLUE}📚 Si aún tienes problemas:${NC}"
    echo "   • Verifica Settings → Actions → General → Workflow permissions"
    echo "   • Asegúrate de que Code scanning esté habilitado en Security settings"
    echo "   • Revisa que el token tenga los scopes necesarios"
}

# Función principal
main() {
    show_banner
    
    log "🚀 Iniciando verificación post-configuración..."
    
    # Verificar que estamos en el directorio correcto
    if [ ! -d ".github/workflows" ]; then
        log_error "No estás en el directorio raíz del proyecto (no se encontró .github/workflows)"
        exit 1
    fi
    
    local exit_code=0
    
    # Ejecutar verificaciones
    echo ""
    check_github_env_vars || exit_code=1
    
    echo ""
    test_github_api_connectivity || exit_code=1
    
    echo ""
    test_token_permissions || exit_code=1
    
    echo ""
    verify_workflow_configuration
    
    echo ""
    simulate_sarif_upload_test
    
    echo ""
    show_final_recommendations
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        log "🎉 ¡Verificación completada exitosamente!"
        log "✅ La configuración parece estar correcta para SARIF uploads"
        log "🚀 Puedes proceder a probar los workflows en GitHub"
    else
        log_warning "⚠️ Se encontraron algunos problemas que pueden necesitar atención"
        log "🔧 Revisa las recomendaciones anteriores"
    fi
    
    return $exit_code
}

# Ejecutar función principal
main "$@"
