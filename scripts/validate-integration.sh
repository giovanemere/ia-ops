#!/bin/bash

# =============================================================================
# SCRIPT DE VALIDACIÓN DE INTEGRACIÓN IA-OPS
# =============================================================================
# Descripción: Valida la integración de repositorios externos y configuración
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

echo "🚀 Validando integración de repositorios IA-Ops..."

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

# Contadores
TOTAL_CHECKS=0
PASSED_CHECKS=0

check_item() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        log_success "$2"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        log_error "$2"
    fi
}

echo ""
log_info "=== VALIDACIÓN DE SUBMÓDULOS ==="

# 1. Verificar submódulos
log_info "Verificando submódulos Git..."
if [ -f ".gitmodules" ]; then
    log_success "Archivo .gitmodules encontrado"
    cat .gitmodules
else
    log_error "Archivo .gitmodules no encontrado"
fi

# 2. Verificar directorio templates
log_info "Verificando directorio templates..."
if [ -d "templates" ]; then
    check_item 0 "Directorio templates existe"
    
    # Verificar contenido de templates
    if [ -f "templates/README.md" ]; then
        check_item 0 "README de templates encontrado"
    else
        check_item 1 "README de templates no encontrado"
    fi
    
    # Verificar templates específicos
    for template in "aws-infrastructure" "azure-messaging" "gcp-storage" "oci-networking" "kubernetes-deployment"; do
        if [ -d "templates/$template" ]; then
            check_item 0 "Template $template encontrado"
        else
            check_item 1 "Template $template no encontrado"
        fi
    done
else
    check_item 1 "Directorio templates no existe"
fi

# 3. Verificar directorio framework
log_info "Verificando directorio framework..."
if [ -d "framework" ]; then
    check_item 0 "Directorio framework existe"
    
    # Verificar inventario de aplicaciones
    if [ -f "framework/apps/Listado Aplicaciones DevOps.xlsx" ]; then
        check_item 0 "Inventario de aplicaciones DevOps encontrado"
    else
        check_item 1 "Inventario de aplicaciones DevOps no encontrado"
    fi
    
    # Verificar documentación de arquitecturas
    if [ -f "framework/arquitectura-diagramas.md" ]; then
        check_item 0 "Documentación de arquitecturas encontrada"
    else
        check_item 1 "Documentación de arquitecturas no encontrada"
    fi
else
    check_item 1 "Directorio framework no existe"
fi

echo ""
log_info "=== VALIDACIÓN DE CONFIGURACIÓN OPENAI ==="

# 4. Verificar configuración OpenAI
if [ -d "config/openai" ]; then
    check_item 0 "Directorio config/openai existe"
    
    # Verificar archivos de configuración
    if [ -f "config/openai/knowledge_base.json" ]; then
        check_item 0 "Base de conocimiento OpenAI generada"
        
        # Verificar contenido de la base de conocimiento
        apps_count=$(jq '.statistics.total_applications' config/openai/knowledge_base.json 2>/dev/null || echo "0")
        if [ "$apps_count" -gt 0 ]; then
            check_item 0 "Base de conocimiento contiene $apps_count aplicaciones"
        else
            check_item 1 "Base de conocimiento vacía o inválida"
        fi
    else
        check_item 1 "Base de conocimiento OpenAI no encontrada"
    fi
    
    if [ -f "config/openai/prompts.json" ]; then
        check_item 0 "Prompts especializados generados"
    else
        check_item 1 "Prompts especializados no encontrados"
    fi
    
    if [ -f "config/openai/service_config.json" ]; then
        check_item 0 "Configuración del servicio OpenAI actualizada"
    else
        check_item 1 "Configuración del servicio OpenAI no encontrada"
    fi
else
    check_item 1 "Directorio config/openai no existe"
fi

echo ""
log_info "=== VALIDACIÓN DE CATÁLOGOS BACKSTAGE ==="

# 5. Verificar catálogos de Backstage
if [ -f "catalog-templates.yaml" ]; then
    check_item 0 "Catálogo de templates creado"
else
    check_item 1 "Catálogo de templates no encontrado"
fi

if [ -f "catalog-framework.yaml" ]; then
    check_item 0 "Catálogo de framework creado"
else
    check_item 1 "Catálogo de framework no encontrado"
fi

# 6. Verificar configuración de Backstage
if [ -f "config/backstage/app-config.yaml" ]; then
    check_item 0 "Configuración de Backstage encontrada"
    
    # Verificar que incluye los nuevos catálogos
    if grep -q "catalog-templates.yaml" config/backstage/app-config.yaml; then
        check_item 0 "Catálogo de templates incluido en configuración"
    else
        check_item 1 "Catálogo de templates no incluido en configuración"
    fi
    
    if grep -q "catalog-framework.yaml" config/backstage/app-config.yaml; then
        check_item 0 "Catálogo de framework incluido en configuración"
    else
        check_item 1 "Catálogo de framework no incluido en configuración"
    fi
else
    check_item 1 "Configuración de Backstage no encontrada"
fi

echo ""
log_info "=== VALIDACIÓN DE VARIABLES DE ENTORNO ==="

# 7. Verificar variables de entorno
if [ -f ".env" ]; then
    check_item 0 "Archivo .env encontrado"
    
    # Verificar variables específicas
    if grep -q "TEMPLATES_REPO" .env; then
        check_item 0 "Variable TEMPLATES_REPO configurada"
    else
        check_item 1 "Variable TEMPLATES_REPO no configurada"
    fi
    
    if grep -q "FRAMEWORK_REPO" .env; then
        check_item 0 "Variable FRAMEWORK_REPO configurada"
    else
        check_item 1 "Variable FRAMEWORK_REPO no configurada"
    fi
else
    check_item 1 "Archivo .env no encontrado"
fi

echo ""
log_info "=== RESUMEN DE VALIDACIÓN ==="

# Calcular porcentaje de éxito
if [ $TOTAL_CHECKS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
else
    SUCCESS_RATE=0
fi

echo "📊 Resultados de validación:"
echo "   ✅ Verificaciones exitosas: $PASSED_CHECKS"
echo "   ❌ Verificaciones fallidas: $((TOTAL_CHECKS - PASSED_CHECKS))"
echo "   📈 Tasa de éxito: $SUCCESS_RATE%"

if [ $SUCCESS_RATE -ge 90 ]; then
    log_success "¡Integración validada exitosamente!"
    echo ""
    echo "🎯 Próximos pasos recomendados:"
    echo "1. Ejecutar 'docker-compose up -d' para iniciar los servicios"
    echo "2. Acceder a Backstage en http://localhost:8080"
    echo "3. Verificar que los templates aparecen en el catálogo"
    echo "4. Probar el servicio OpenAI con contexto DevOps"
    exit 0
elif [ $SUCCESS_RATE -ge 70 ]; then
    log_warning "Integración parcialmente validada. Revisar elementos fallidos."
    exit 1
else
    log_error "Integración con problemas significativos. Revisar configuración."
    exit 2
fi
