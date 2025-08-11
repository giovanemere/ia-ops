#!/bin/bash

# =============================================================================
# VALIDACIÓN DE CATÁLOGO FASE 2
# =============================================================================
# Script para validar que todos los archivos de catálogo estén correctamente ubicados

set -e

echo "🔍 VALIDACIÓN DE CATÁLOGO FASE 2"
echo "================================="
echo "📅 Fecha: $(date)"
echo ""

# Contadores
total_checks=0
passed_checks=0

# Función para ejecutar check
run_check() {
    local description=$1
    local file_path=$2
    
    total_checks=$((total_checks + 1))
    echo -n "🔍 $description... "
    
    if [ -f "$file_path" ]; then
        echo "✅ EXISTE"
        passed_checks=$((passed_checks + 1))
    else
        echo "❌ FALTANTE"
        echo "   📁 Ruta esperada: $file_path"
    fi
}

echo "📊 VALIDANDO ARCHIVOS DE CATÁLOGO"
echo "=================================="

# Validar archivos principales
run_check "Catálogo Fase 2 Completo" "/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/backend/catalog-phase2-complete.yaml"
run_check "Catálogo MVP Demo" "/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/backend/catalog-mvp-demo.yaml"
run_check "Configuración Backstage" "/home/giovanemere/ia-ops/ia-ops/applications/backstage/app-config.yaml"

echo ""
echo "📊 VALIDANDO ARCHIVOS INDIVIDUALES FASE 2"
echo "=========================================="

# Validar archivos individuales generados
run_check "Frontend A (Material-UI)" "/home/giovanemere/ia-ops/ia-ops/catalog-billpay-front-a-phase2.yaml"
run_check "Frontend B (Chakra UI)" "/home/giovanemere/ia-ops/ia-ops/catalog-billpay-front-b-phase2.yaml"

echo ""
echo "📊 VALIDANDO CONTENIDO DE CATÁLOGO"
echo "==================================="

# Validar contenido del catálogo consolidado
CATALOG_FILE="/home/giovanemere/ia-ops/ia-ops/applications/backstage/packages/backend/catalog-phase2-complete.yaml"

if [ -f "$CATALOG_FILE" ]; then
    echo "🔍 Analizando contenido del catálogo..."
    
    # Contar entidades
    COMPONENTS=$(grep -c "kind: Component" "$CATALOG_FILE" || echo "0")
    APIS=$(grep -c "kind: API" "$CATALOG_FILE" || echo "0")
    SYSTEMS=$(grep -c "kind: System" "$CATALOG_FILE" || echo "0")
    GROUPS=$(grep -c "kind: Group" "$CATALOG_FILE" || echo "0")
    DOMAINS=$(grep -c "kind: Domain" "$CATALOG_FILE" || echo "0")
    
    echo "📊 Entidades encontradas:"
    echo "   📦 Components: $COMPONENTS"
    echo "   🔌 APIs: $APIS"
    echo "   🏗️ Systems: $SYSTEMS"
    echo "   👥 Groups: $GROUPS"
    echo "   🌐 Domains: $DOMAINS"
    
    TOTAL_ENTITIES=$((COMPONENTS + APIS + SYSTEMS + GROUPS + DOMAINS))
    echo "   📊 Total: $TOTAL_ENTITIES entidades"
    
    # Validar aplicaciones específicas
    echo ""
    echo "🔍 Validando aplicaciones específicas:"
    
    if grep -q "billpay-backend-ai-demo" "$CATALOG_FILE"; then
        echo "   ✅ BillPay Backend (MVP)"
    else
        echo "   ❌ BillPay Backend (MVP) - FALTANTE"
    fi
    
    if grep -q "billpay-frontend-a-phase2" "$CATALOG_FILE"; then
        echo "   ✅ BillPay Frontend A (Material-UI)"
    else
        echo "   ❌ BillPay Frontend A (Material-UI) - FALTANTE"
    fi
    
    if grep -q "billpay-frontend-b-phase2" "$CATALOG_FILE"; then
        echo "   ✅ BillPay Frontend B (Chakra UI)"
    else
        echo "   ❌ BillPay Frontend B (Chakra UI) - FALTANTE"
    fi
    
    # Validar metadatos IA
    echo ""
    echo "🔍 Validando metadatos IA:"
    
    AI_ANALYZED=$(grep -c "ia-ops.ai-analyzed" "$CATALOG_FILE" || echo "0")
    PHASE_TAGS=$(grep -c "ia-ops.phase" "$CATALOG_FILE" || echo "0")
    TECH_TAGS=$(grep -c "ia-ops.technologies" "$CATALOG_FILE" || echo "0")
    
    echo "   🤖 Entidades analizadas por IA: $AI_ANALYZED"
    echo "   📋 Entidades con fase: $PHASE_TAGS"
    echo "   🛠️ Entidades con tecnologías: $TECH_TAGS"
    
else
    echo "❌ No se puede analizar el contenido - archivo faltante"
fi

echo ""
echo "📊 VALIDANDO SERVICIOS RELACIONADOS"
echo "===================================="

# Validar OpenAI Service
echo -n "🔍 OpenAI Service (Fase 2)... "
if curl -s http://localhost:8003/health > /dev/null; then
    SERVICE_VERSION=$(curl -s http://localhost:8003/health | jq -r '.version' 2>/dev/null || echo "unknown")
    echo "✅ OPERATIVO ($SERVICE_VERSION)"
    passed_checks=$((passed_checks + 1))
else
    echo "❌ NO DISPONIBLE"
fi
total_checks=$((total_checks + 1))

# Validar repositorios soportados
echo -n "🔍 Repositorios soportados... "
if curl -s http://localhost:8003/repositories/supported > /dev/null; then
    SUPPORTED_REPOS=$(curl -s http://localhost:8003/repositories/supported | jq -r '.total_repositories' 2>/dev/null || echo "0")
    echo "✅ $SUPPORTED_REPOS repositorios"
    passed_checks=$((passed_checks + 1))
else
    echo "❌ NO DISPONIBLE"
fi
total_checks=$((total_checks + 1))

echo ""
echo "🏆 RESUMEN DE VALIDACIÓN"
echo "========================"
echo "📊 Checks ejecutados: $total_checks"
echo "✅ Checks pasados: $passed_checks"
echo "❌ Checks fallidos: $((total_checks - passed_checks))"

SUCCESS_RATE=$((passed_checks * 100 / total_checks))
echo "📈 Tasa de éxito: $SUCCESS_RATE%"

echo ""
if [ $SUCCESS_RATE -ge 90 ]; then
    echo "🎉 VALIDACIÓN EXITOSA - Catálogo listo para uso"
    echo ""
    echo "🚀 PRÓXIMOS PASOS:"
    echo "   1. Reiniciar Backstage para cargar nuevo catálogo"
    echo "   2. Verificar entidades en UI de Backstage"
    echo "   3. Completar aplicaciones restantes (Feature Flags + ICBS)"
elif [ $SUCCESS_RATE -ge 70 ]; then
    echo "⚠️ VALIDACIÓN PARCIAL - Algunos problemas detectados"
    echo ""
    echo "🔧 ACCIONES REQUERIDAS:"
    echo "   1. Revisar archivos faltantes"
    echo "   2. Corregir configuración de Backstage"
    echo "   3. Validar servicios relacionados"
else
    echo "❌ VALIDACIÓN FALLIDA - Problemas críticos detectados"
    echo ""
    echo "🚨 ACCIONES CRÍTICAS:"
    echo "   1. Revisar configuración completa"
    echo "   2. Verificar ubicación de archivos"
    echo "   3. Validar servicios base"
fi

echo ""
echo "📁 ARCHIVOS CLAVE:"
echo "   📋 Catálogo principal: packages/backend/catalog-phase2-complete.yaml"
echo "   ⚙️ Configuración: app-config.yaml"
echo "   🔍 Este script: validate-catalog-phase2.sh"

echo ""
echo "🔗 COMANDOS ÚTILES:"
echo "   # Reiniciar Backstage"
echo "   docker-compose restart backstage"
echo ""
echo "   # Ver logs de Backstage"
echo "   docker-compose logs -f backstage"
echo ""
echo "   # Validar sintaxis YAML"
echo "   yamllint packages/backend/catalog-phase2-complete.yaml"
