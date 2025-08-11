#!/bin/bash

echo "🎯 PERSONALIZAR CONFIGURACIÓN DE CODEOWNERS"
echo "==========================================="

echo ""
echo "📋 CONFIGURACIÓN ACTUAL:"
echo "======================="
echo "• CODEOWNERS: Configurado con equipos de ejemplo"
echo "• catalog-info.yaml: Configurado con proyecto de ejemplo"
echo "• backstage.io/codeowners-location: /CODEOWNERS ✅"

echo ""
echo "🔧 PERSONALIZACIÓN INTERACTIVA:"
echo "==============================="

# Obtener información del usuario
read -p "¿Cuál es tu organización/usuario de GitHub? (ej: mi-org): " github_org
read -p "¿Cuál es el nombre del repositorio? (ej: backstage): " repo_name
read -p "¿Cuál es tu equipo principal? (ej: @mi-equipo): " main_team

# Valores por defecto si están vacíos
github_org=${github_org:-"ia-ops"}
repo_name=${repo_name:-"backstage"}
main_team=${main_team:-"@ia-ops-team"}

echo ""
echo "📝 ACTUALIZANDO CONFIGURACIÓN:"
echo "============================="

# Crear backup
cp catalog-info.yaml catalog-info.yaml.backup.$(date +%Y%m%d_%H%M%S)
cp CODEOWNERS CODEOWNERS.backup.$(date +%Y%m%d_%H%M%S)

# Actualizar catalog-info.yaml con información real
cat > catalog-info.yaml << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${repo_name}
  title: ${github_org^} Developer Portal
  description: Backstage Developer Portal for ${github_org} team - Central hub for developer tools, documentation, and services
  tags:
    - backstage
    - developer-portal
    - ${github_org}
    - platform
  annotations:
    # GitHub integration
    github.com/project-slug: ${github_org}/${repo_name}
    
    # CODEOWNERS configuration
    backstage.io/codeowners-location: /CODEOWNERS
    
    # TechDocs configuration
    backstage.io/techdocs-ref: dir:.
    
    # Source location
    backstage.io/source-location: url:https://github.com/${github_org}/${repo_name}
    
    # Additional metadata
    backstage.io/managed-by-location: url:https://github.com/${github_org}/${repo_name}/blob/main/catalog-info.yaml
    
spec:
  type: website
  owner: group:${main_team#@}
  lifecycle: production
  system: developer-platform
  providesApis:
    - backstage-api
  consumesApis:
    - github-api
    - postgresql-api
  dependsOn:
    - component:postgresql
    - component:github-integration
EOF

# Actualizar CODEOWNERS con información real
cat > CODEOWNERS << EOF
# CODEOWNERS file for ${github_org^} Backstage
# This file defines who owns different parts of the codebase

# Global owners (default for everything)
* ${main_team}

# Backstage configuration
/app-config*.yaml ${main_team} @backstage-admins
/catalog-info.yaml ${main_team}

# Backend code
/packages/backend/ ${main_team} @backend-team

# Frontend code  
/packages/app/ ${main_team} @frontend-team

# Documentation
/docs/ ${main_team} @documentation-team
*.md ${main_team} @documentation-team

# Templates and examples
/examples/ ${main_team}
/templates/ ${main_team}

# Infrastructure and deployment
/kubernetes/ ${main_team} @devops-team
/docker/ ${main_team} @devops-team
Dockerfile* ${main_team} @devops-team

# CI/CD
/.github/ ${main_team} @devops-team
/scripts/ ${main_team} @devops-team

# Environment configuration
/.env* ${main_team} @devops-team
/app-config.production.yaml ${main_team} @devops-team @security-team
EOF

echo "✅ Archivos actualizados con tu información"

echo ""
echo "📊 CONFIGURACIÓN PERSONALIZADA:"
echo "==============================="
echo "• GitHub Org: ${github_org}"
echo "• Repositorio: ${repo_name}"
echo "• Equipo Principal: ${main_team}"
echo "• Project Slug: ${github_org}/${repo_name}"

echo ""
echo "📄 VERIFICAR CONFIGURACIÓN:"
echo "=========================="
echo ""
echo "catalog-info.yaml (GitHub integration):"
grep "github.com/project-slug" catalog-info.yaml

echo ""
echo "catalog-info.yaml (CODEOWNERS):"
grep "backstage.io/codeowners-location" catalog-info.yaml

echo ""
echo "CODEOWNERS (equipo principal):"
grep "^\*" CODEOWNERS

echo ""
echo "✅ PERSONALIZACIÓN COMPLETADA:"
echo "============================="
echo "• ✅ catalog-info.yaml personalizado"
echo "• ✅ CODEOWNERS personalizado"
echo "• ✅ GitHub integration configurada"
echo "• ✅ Backups creados"

echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="
echo "1. 📝 Revisar y ajustar equipos en CODEOWNERS:"
echo "   nano CODEOWNERS"
echo ""
echo "2. 🔍 Verificar que los equipos existan en GitHub:"
echo "   - ${main_team}"
echo "   - @backstage-admins"
echo "   - @backend-team"
echo "   - @frontend-team"
echo ""
echo "3. 🚀 Commit los cambios:"
echo "   git add CODEOWNERS catalog-info.yaml"
echo "   git commit -m 'Personalize CODEOWNERS and catalog-info.yaml'"
echo ""
echo "4. 🔄 Reiniciar Backstage:"
echo "   ./start-with-env.sh"

echo ""
echo "💡 NOTA IMPORTANTE:"
echo "=================="
echo "Los equipos en CODEOWNERS deben existir en tu organización de GitHub"
echo "Si no existen, puedes usar usuarios individuales: @username"
