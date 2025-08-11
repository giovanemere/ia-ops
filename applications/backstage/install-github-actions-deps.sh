#!/bin/bash

# Script para instalar dependencias de GitHub Actions en Backstage
# Fecha: $(date)

set -e

echo "🚀 Instalando dependencias de GitHub Actions para Backstage..."

# Navegar al directorio de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Instalar dependencias del backend
echo "📦 Instalando dependencias del backend..."
yarn add --cwd packages/backend @backstage/plugin-github-actions-backend

# Instalar dependencias del frontend
echo "📦 Instalando dependencias del frontend..."
yarn add --cwd packages/app @backstage/plugin-github-actions

# Instalar dependencias adicionales para TechDocs
echo "📚 Instalando dependencias adicionales para TechDocs..."
yarn add --cwd packages/backend @backstage/plugin-techdocs-backend-module-cache
yarn add --cwd packages/backend @backstage/plugin-search-backend-module-catalog
yarn add --cwd packages/backend @backstage/plugin-search-backend-module-techdocs
yarn add --cwd packages/backend @backstage/plugin-catalog-backend-module-github

# Instalar dependencias para el catálogo mejorado
echo "📋 Instalando dependencias para el catálogo..."
yarn add --cwd packages/app @backstage/plugin-catalog-graph

echo "✅ Dependencias instaladas correctamente!"
echo ""
echo "📝 Próximos pasos:"
echo "1. Reiniciar Backstage: yarn dev"
echo "2. Verificar que los plugins estén funcionando"
echo "3. Revisar la documentación automática en /docs"
echo "4. Verificar GitHub Actions en cada componente"
echo ""
echo "🔗 URLs importantes:"
echo "- Backstage: http://localhost:3002"
echo "- Catálogo: http://localhost:3002/catalog"
echo "- TechDocs: http://localhost:3002/docs"
echo "- GitHub Actions: Disponible en cada componente del catálogo"
