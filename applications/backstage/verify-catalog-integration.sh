#!/bin/bash

echo "📊 VERIFICACIÓN COMPLETA DE SOFTWARE CATALOG INTEGRATION"
echo "========================================================"

echo ""
echo "🔍 1. VERIFICANDO CONFIGURACIÓN DEL CATÁLOGO:"
echo "============================================="

# Verificar app-config.yaml - sección catalog
echo "📋 Configuración en app-config.yaml:"
if grep -A20 "^catalog:" app-config.yaml > /dev/null; then
    echo "✅ Sección 'catalog:' encontrada"
    
    # Mostrar configuración del catálogo
    echo ""
    echo "📄 Configuración actual:"
    echo "------------------------"
    grep -A20 "^catalog:" app-config.yaml | head -25
    
else
    echo "❌ Sección 'catalog:' no encontrada en app-config.yaml"
fi

echo ""
echo "🔍 2. VERIFICANDO LOCATIONS DEL CATÁLOGO:"
echo "========================================"

# Verificar locations configuradas
if grep -A10 "locations:" app-config.yaml > /dev/null; then
    echo "✅ Locations configuradas"
    echo ""
    echo "📄 Locations actuales:"
    echo "---------------------"
    grep -A15 "locations:" app-config.yaml | grep -E "(- type:|target:|rules:)" | head -10
else
    echo "❌ No se encontraron locations configuradas"
fi

echo ""
echo "🔍 3. VERIFICANDO ARCHIVOS DEL CATÁLOGO:"
echo "======================================="

# Verificar catalog-info.yaml principal
if [ -f "catalog-info.yaml" ]; then
    echo "✅ catalog-info.yaml principal existe"
    
    # Verificar estructura básica
    if grep -q "apiVersion: backstage.io/v1alpha1" catalog-info.yaml; then
        echo "✅ API Version correcta"
    else
        echo "❌ API Version incorrecta o faltante"
    fi
    
    if grep -q "kind: Component" catalog-info.yaml; then
        echo "✅ Kind: Component configurado"
    else
        echo "❌ Kind no configurado correctamente"
    fi
    
    if grep -q "metadata:" catalog-info.yaml; then
        echo "✅ Metadata section presente"
    else
        echo "❌ Metadata section faltante"
    fi
    
    if grep -q "spec:" catalog-info.yaml; then
        echo "✅ Spec section presente"
    else
        echo "❌ Spec section faltante"
    fi
    
else
    echo "❌ catalog-info.yaml principal no existe"
fi

# Verificar archivos de ejemplo
echo ""
echo "📋 Archivos de ejemplo:"
if [ -f "examples/entities.yaml" ]; then
    echo "✅ examples/entities.yaml existe"
else
    echo "❌ examples/entities.yaml no existe"
fi

if [ -f "examples/org.yaml" ]; then
    echo "✅ examples/org.yaml existe"
else
    echo "❌ examples/org.yaml no existe"
fi

if [ -f "examples/template/template.yaml" ]; then
    echo "✅ examples/template/template.yaml existe"
else
    echo "❌ examples/template/template.yaml no existe"
fi

echo ""
echo "🔍 4. VERIFICANDO BACKEND PLUGINS:"
echo "================================="

# Verificar plugins del catálogo en backend
if grep -q "plugin-catalog-backend" packages/backend/src/index.ts; then
    echo "✅ plugin-catalog-backend configurado"
else
    echo "❌ plugin-catalog-backend no configurado"
fi

if grep -q "plugin-catalog-backend-module-scaffolder-entity-model" packages/backend/src/index.ts; then
    echo "✅ scaffolder-entity-model configurado"
else
    echo "❌ scaffolder-entity-model no configurado"
fi

if grep -q "plugin-catalog-backend-module-logs" packages/backend/src/index.ts; then
    echo "✅ catalog-backend-module-logs configurado"
else
    echo "❌ catalog-backend-module-logs no configurado"
fi

echo ""
echo "🔍 5. VERIFICANDO FRONTEND PLUGINS:"
echo "==================================="

# Verificar si el catálogo está configurado en el frontend
if [ -f "packages/app/src/App.tsx" ]; then
    if grep -q "CatalogIndexPage" packages/app/src/App.tsx; then
        echo "✅ CatalogIndexPage configurado en frontend"
    else
        echo "❌ CatalogIndexPage no configurado en frontend"
    fi
    
    if grep -q "CatalogEntityPage" packages/app/src/App.tsx; then
        echo "✅ CatalogEntityPage configurado en frontend"
    else
        echo "❌ CatalogEntityPage no configurado en frontend"
    fi
else
    echo "❌ packages/app/src/App.tsx no encontrado"
fi

echo ""
echo "🔍 6. VERIFICANDO INTEGRACIÓN CON GITHUB:"
echo "========================================"

# Cargar variables de entorno
source ../../.env

echo "📋 Variables de GitHub:"
echo "GITHUB_TOKEN: $([ -n "$GITHUB_TOKEN" ] && [ "$GITHUB_TOKEN" != "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ] && echo "✅ Configurado" || echo "❌ No configurado")"
echo "AUTH_GITHUB_CLIENT_ID: $([ -n "$AUTH_GITHUB_CLIENT_ID" ] && echo "✅ Configurado" || echo "❌ No configurado")"
echo "AUTH_GITHUB_CLIENT_SECRET: $([ -n "$AUTH_GITHUB_CLIENT_SECRET" ] && echo "✅ Configurado" || echo "❌ No configurado")"

# Verificar anotaciones de GitHub en catalog-info.yaml
if grep -q "github.com/project-slug" catalog-info.yaml; then
    echo "✅ GitHub project-slug configurado"
    echo "   $(grep "github.com/project-slug" catalog-info.yaml)"
else
    echo "❌ GitHub project-slug no configurado"
fi

echo ""
echo "🔍 7. VERIFICANDO PROCESSORS Y PROVIDERS:"
echo "========================================"

# Verificar si hay configuración de processors
if grep -A10 "processors:" app-config.yaml > /dev/null; then
    echo "✅ Processors configurados"
else
    echo "⚠️  No se encontraron processors específicos (usando defaults)"
fi

echo ""
echo "🔍 8. VERIFICANDO REGLAS DE CATALOG:"
echo "==================================="

# Verificar reglas en locations
if grep -A5 "rules:" app-config.yaml > /dev/null; then
    echo "✅ Reglas de catálogo configuradas"
    echo ""
    echo "📄 Reglas encontradas:"
    grep -A5 "rules:" app-config.yaml | head -10
else
    echo "⚠️  No se encontraron reglas específicas (permitiendo todo)"
fi

echo ""
echo "📊 RESUMEN DE VERIFICACIÓN:"
echo "=========================="

# Contar elementos configurados
CONFIGURED=0
TOTAL=10

# Verificaciones básicas
[ -f "catalog-info.yaml" ] && ((CONFIGURED++))
grep -q "^catalog:" app-config.yaml && ((CONFIGURED++))
grep -q "locations:" app-config.yaml && ((CONFIGURED++))
grep -q "plugin-catalog-backend" packages/backend/src/index.ts && ((CONFIGURED++))
[ -f "examples/entities.yaml" ] && ((CONFIGURED++))
[ -f "examples/org.yaml" ] && ((CONFIGURED++))
[ -f "examples/template/template.yaml" ] && ((CONFIGURED++))
grep -q "CatalogIndexPage" packages/app/src/App.tsx 2>/dev/null && ((CONFIGURED++))
grep -q "github.com/project-slug" catalog-info.yaml && ((CONFIGURED++))
[ -f "CODEOWNERS" ] && ((CONFIGURED++))

echo "✅ Elementos configurados: $CONFIGURED/$TOTAL"

if [ $CONFIGURED -ge 8 ]; then
    echo "🎉 ESTADO: EXCELENTE - Catalog integration casi completa"
elif [ $CONFIGURED -ge 6 ]; then
    echo "✅ ESTADO: BUENO - Catalog integration funcional"
elif [ $CONFIGURED -ge 4 ]; then
    echo "⚠️  ESTADO: BÁSICO - Catalog integration parcial"
else
    echo "❌ ESTADO: INCOMPLETO - Necesita configuración"
fi

echo ""
echo "🔧 ELEMENTOS FALTANTES O A MEJORAR:"
echo "==================================="

# Lista de verificaciones específicas
echo "Verificando elementos críticos..."

# Verificar si falta algo crítico
MISSING_CRITICAL=()

if ! grep -q "^catalog:" app-config.yaml; then
    MISSING_CRITICAL+=("Configuración de catalog en app-config.yaml")
fi

if ! [ -f "catalog-info.yaml" ]; then
    MISSING_CRITICAL+=("Archivo catalog-info.yaml principal")
fi

if ! grep -q "plugin-catalog-backend" packages/backend/src/index.ts; then
    MISSING_CRITICAL+=("Plugin catalog-backend en backend")
fi

if [ ${#MISSING_CRITICAL[@]} -eq 0 ]; then
    echo "✅ Todos los elementos críticos están configurados"
else
    echo "❌ Elementos críticos faltantes:"
    for item in "${MISSING_CRITICAL[@]}"; do
        echo "   • $item"
    done
fi

echo ""
echo "💡 RECOMENDACIONES:"
echo "=================="

if [ -n "$GITHUB_TOKEN" ] && [ "$GITHUB_TOKEN" != "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "✅ GitHub integration lista"
else
    echo "🔑 Configurar GITHUB_TOKEN para integración completa con GitHub"
fi

if [ -n "$AUTH_GITHUB_CLIENT_ID" ] && [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "✅ GitHub OAuth configurado"
else
    echo "🔐 Configurar GitHub OAuth para autenticación completa"
fi

echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="
echo "1. 🔧 Corregir elementos faltantes (si los hay)"
echo "2. 🔑 Configurar credenciales de GitHub"
echo "3. 🚀 Iniciar Backstage: ./start-with-env.sh"
echo "4. 🌐 Verificar en: http://localhost:3002/catalog"
echo "5. 📊 Revisar que tu componente aparezca en el catálogo"
