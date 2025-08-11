#!/bin/bash

# Script para generar catalog-info.yaml en repositorios automáticamente

REPOS=(
    "poc-billpay-back:Backend service for billpay application"
    "poc-billpay-front-a:Frontend A for billpay application"
    "poc-billpay-front-b:Frontend B for billpay application"
    "poc-billpay-front-feature-flags:Feature flags frontend for billpay"
    "poc-icbs:ICBS integration service"
)

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_desc <<< "$repo_info"
    
    echo "📝 Generando catalog-info.yaml para $repo_name..."
    
    # Crear catalog-info.yaml específico
    sed "s/COMPONENT_NAME/$repo_name/g; s/COMPONENT_DESCRIPTION/$repo_desc/g; s/REPO_NAME/$repo_name/g" catalog-template.yaml > "catalog-$repo_name.yaml"
    
    echo "✅ Generado: catalog-$repo_name.yaml"
done

echo ""
echo "📋 Archivos generados:"
ls -la catalog-*.yaml

echo ""
echo "🚀 Próximos pasos:"
echo "1. Revisar los archivos generados"
echo "2. Copiar catalog-info.yaml a cada repositorio"
echo "3. Crear docs/index.md en cada repositorio"
echo "4. Crear mkdocs.yml en cada repositorio"
echo "5. Reiniciar Backstage para ver los cambios"
