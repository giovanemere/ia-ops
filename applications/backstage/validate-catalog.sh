#!/bin/bash

echo "🧪 VALIDACIÓN DE CATALOG INTEGRATION"
echo "===================================="

echo ""
echo "📋 Verificando archivos críticos:"
echo "================================="

FILES=("catalog-info.yaml" "examples/entities.yaml" "examples/org.yaml" "examples/template/template.yaml" "CODEOWNERS")

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - FALTANTE"
    fi
done

echo ""
echo "📋 Verificando sintaxis YAML:"
echo "============================="

if command -v python3 &> /dev/null; then
    for file in "${FILES[@]}"; do
        if [ -f "$file" ] && [[ "$file" == *.yaml ]]; then
            if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                echo "✅ $file - Sintaxis válida"
            else
                echo "❌ $file - Error de sintaxis"
            fi
        fi
    done
else
    echo "⚠️  Python3 no disponible para validación de YAML"
fi

echo ""
echo "📋 Verificando configuración en app-config.yaml:"
echo "==============================================="

REQUIRED_SECTIONS=("catalog:" "locations:" "rules:")

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" app-config.yaml; then
        echo "✅ $section configurado"
    else
        echo "❌ $section - FALTANTE"
    fi
done

echo ""
echo "🎯 RESULTADO:"
echo "============"
echo "Si todos los elementos muestran ✅, la integración está completa"
echo "Si hay ❌, revisa los elementos faltantes"

echo ""
echo "🚀 Para probar:"
echo "==============="
echo "1. Inicia Backstage: ./start-with-env.sh"
echo "2. Ve a: http://localhost:3002/catalog"
echo "3. Deberías ver tu componente listado"
