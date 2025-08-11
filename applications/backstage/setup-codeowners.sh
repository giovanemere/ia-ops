#!/bin/bash

echo "👥 CONFIGURACIÓN DE CODEOWNERS PARA BACKSTAGE"
echo "============================================="

echo ""
echo "📋 ESTADO ACTUAL:"
echo "================"

# Verificar si existe CODEOWNERS
if [ -f "CODEOWNERS" ]; then
    echo "✅ Archivo CODEOWNERS existe"
    echo "📄 Contenido actual:"
    cat CODEOWNERS
else
    echo "❌ Archivo CODEOWNERS no existe"
fi

echo ""
echo "📋 VERIFICANDO catalog-info.yaml:"
echo "================================="

if [ -f "catalog-info.yaml" ]; then
    echo "✅ catalog-info.yaml existe"
    
    # Verificar si ya tiene la anotación de codeowners
    if grep -q "backstage.io/codeowners-location" catalog-info.yaml; then
        echo "✅ Ya tiene anotación backstage.io/codeowners-location"
        echo "📄 Configuración actual:"
        grep -A2 -B2 "backstage.io/codeowners-location" catalog-info.yaml
    else
        echo "⚠️  No tiene anotación backstage.io/codeowners-location"
    fi
else
    echo "❌ catalog-info.yaml no existe"
fi

echo ""
echo "🔧 CREANDO CONFIGURACIÓN COMPLETA:"
echo "=================================="

# Crear archivo CODEOWNERS si no existe
if [ ! -f "CODEOWNERS" ]; then
    echo "📝 Creando archivo CODEOWNERS..."
    
    cat > CODEOWNERS << 'EOF'
# CODEOWNERS file for IA-OPS Backstage
# This file defines who owns different parts of the codebase

# Global owners (default for everything)
* @ia-ops-team

# Backstage configuration
/app-config*.yaml @ia-ops-team @backstage-admins
/catalog-info.yaml @ia-ops-team

# Backend code
/packages/backend/ @ia-ops-team @backend-team

# Frontend code  
/packages/app/ @ia-ops-team @frontend-team

# Documentation
/docs/ @ia-ops-team @documentation-team
*.md @ia-ops-team @documentation-team

# Templates and examples
/examples/ @ia-ops-team
/templates/ @ia-ops-team

# Infrastructure and deployment
/kubernetes/ @ia-ops-team @devops-team
/docker/ @ia-ops-team @devops-team
Dockerfile* @ia-ops-team @devops-team

# CI/CD
/.github/ @ia-ops-team @devops-team
/scripts/ @ia-ops-team @devops-team
EOF

    echo "✅ Archivo CODEOWNERS creado"
else
    echo "✅ Archivo CODEOWNERS ya existe"
fi

# Crear backup del catalog-info.yaml
cp catalog-info.yaml catalog-info.yaml.backup.$(date +%Y%m%d_%H%M%S)
echo "💾 Backup creado: catalog-info.yaml.backup.*"

# Actualizar catalog-info.yaml con configuración completa
echo "📝 Actualizando catalog-info.yaml..."

cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ia-ops-backstage
  title: IA-OPS Developer Portal
  description: Backstage Developer Portal for IA-OPS team - Central hub for developer tools, documentation, and services
  tags:
    - backstage
    - developer-portal
    - ia-ops
    - platform
  annotations:
    # GitHub integration
    github.com/project-slug: ia-ops/backstage
    
    # CODEOWNERS configuration
    backstage.io/codeowners-location: /CODEOWNERS
    
    # TechDocs configuration
    backstage.io/techdocs-ref: dir:.
    
    # Source location
    backstage.io/source-location: url:https://github.com/ia-ops/backstage
    
    # Additional metadata
    backstage.io/managed-by-location: url:https://github.com/ia-ops/backstage/blob/main/catalog-info.yaml
    
spec:
  type: website
  owner: group:ia-ops-team
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

echo "✅ catalog-info.yaml actualizado"

echo ""
echo "📋 CONFIGURACIÓN FINAL:"
echo "======================"

echo ""
echo "📄 CODEOWNERS:"
echo "--------------"
head -10 CODEOWNERS

echo ""
echo "📄 catalog-info.yaml (anotaciones):"
echo "-----------------------------------"
grep -A10 "annotations:" catalog-info.yaml

echo ""
echo "✅ CONFIGURACIÓN COMPLETADA:"
echo "============================"
echo "• ✅ Archivo CODEOWNERS creado/verificado"
echo "• ✅ catalog-info.yaml actualizado con anotación backstage.io/codeowners-location"
echo "• ✅ Configuración completa de metadatos"
echo "• ✅ Backup de seguridad creado"

echo ""
echo "🎯 BENEFICIOS DE ESTA CONFIGURACIÓN:"
echo "==================================="
echo "• 👥 Ownership claro de diferentes partes del código"
echo "• 🔍 Integración con GitHub para reviews automáticos"
echo "• 📊 Visibilidad en Backstage de quién es responsable"
echo "• 🛡️  Mejor governance del código"

echo ""
echo "💡 PRÓXIMOS PASOS:"
echo "=================="
echo "1. 📝 Personalizar CODEOWNERS con tus equipos reales:"
echo "   nano CODEOWNERS"
echo ""
echo "2. 🔧 Actualizar GitHub project-slug en catalog-info.yaml:"
echo "   nano catalog-info.yaml"
echo ""
echo "3. 🚀 Commit y push los cambios:"
echo "   git add CODEOWNERS catalog-info.yaml"
echo "   git commit -m 'Add CODEOWNERS and update catalog-info.yaml'"
echo "   git push"
echo ""
echo "4. 🔄 Reiniciar Backstage para ver los cambios:"
echo "   ./start-with-env.sh"

echo ""
echo "🔍 VERIFICAR EN BACKSTAGE:"
echo "========================="
echo "• Ve a tu componente en el catálogo"
echo "• Busca la sección 'About' o 'Overview'"
echo "• Deberías ver información de ownership"
echo "• Los links a GitHub deberían funcionar"
