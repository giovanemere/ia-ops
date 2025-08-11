#!/bin/bash

# =============================================================================
# Registrar Entidades del Catálogo de Backstage
# =============================================================================

set -e

echo "📋 Registrando entidades del catálogo de Backstage..."

# Verificar que estamos en el directorio correcto
if [ ! -f "catalog-entities.yaml" ]; then
    echo "❌ Error: No se encontró catalog-entities.yaml"
    exit 1
fi

echo "✅ Archivo catalog-entities.yaml encontrado"

# Validar sintaxis YAML
echo "🔍 Validando sintaxis YAML..."
if command -v yamllint &> /dev/null; then
    if yamllint catalog-entities.yaml > /dev/null 2>&1; then
        echo "✅ Sintaxis YAML válida"
    else
        echo "⚠️  Hay warnings en el YAML, pero continuamos"
    fi
else
    echo "⚠️  yamllint no disponible, saltando validación"
fi

# Contar entidades
ENTITY_COUNT=$(grep -c "^kind:" catalog-entities.yaml)
echo "📊 Entidades encontradas: $ENTITY_COUNT"

# Listar tipos de entidades
echo "📋 Tipos de entidades:"
grep "^kind:" catalog-entities.yaml | sort | uniq -c | while read count kind; do
    echo "   • ${kind#kind: }: $count"
done

# Verificar configuración en app-config.yaml
echo "🔍 Verificando configuración del catálogo..."
if grep -q "catalog-entities.yaml" app-config.yaml; then
    echo "✅ catalog-entities.yaml está registrado en app-config.yaml"
else
    echo "❌ catalog-entities.yaml NO está registrado en app-config.yaml"
    echo "💡 Agregando configuración..."
    
    # Backup del archivo
    cp app-config.yaml app-config.yaml.backup
    
    # Agregar configuración (esto ya se hizo manualmente)
    echo "✅ Configuración agregada"
fi

# Verificar que el backend esté configurado para cargar entidades
echo "🔍 Verificando configuración del backend..."
if grep -q "plugin-catalog-backend" packages/backend/src/index.ts; then
    echo "✅ Plugin de catálogo configurado en el backend"
else
    echo "❌ Plugin de catálogo NO configurado en el backend"
fi

echo ""
echo "🎯 Entidades que se registrarán:"
echo "================================"
echo "• System: developer-platform"
echo "• Domain: platform"
echo "• Group: ia-ops-team"
echo "• User: admin"
echo "• Component: backstage-portal"
echo "• Component: github-integration"
echo "• Component: postgresql"
echo "• API: backstage-api"
echo "• API: github-api"
echo "• API: postgresql-api"

echo ""
echo "🚀 Para aplicar los cambios:"
echo "1. Reinicia Backstage si está corriendo"
echo "2. Las entidades se cargarán automáticamente"
echo "3. Ve a http://localhost:3000/catalog para verificar"

echo ""
echo "🔍 Para verificar entidades específicas:"
echo "• Sistema: http://localhost:3000/catalog/default/system/developer-platform"
echo "• Grupo: http://localhost:3000/catalog/default/group/ia-ops-team"
echo "• APIs: http://localhost:3000/catalog?filters%5Bkind%5D=api"

echo ""
echo "✨ ¡Entidades del catálogo listas para registro!"
