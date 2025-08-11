#!/bin/bash

# =============================================================================
# SCRIPT PARA CORREGIR ERRORES DE TECHDOCS
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    CORRIGIENDO ERRORES DE TECHDOCS                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Lista de archivos de catálogo problemáticos
catalog_files=(
    "catalog-poc-billpay-back.yaml"
    "catalog-poc-billpay-front-a.yaml"
    "catalog-poc-billpay-front-b.yaml"
    "catalog-poc-billpay-front-feature-flags.yaml"
    "catalog-poc-icbs.yaml"
)

echo -e "${BLUE}=== 1. RESPALDANDO ARCHIVOS ORIGINALES ===${NC}"
for file in "${catalog_files[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$file.backup-$(date +%Y%m%d-%H%M%S)"
        echo "✅ Respaldado: $file"
    fi
done

echo ""
echo -e "${BLUE}=== 2. CORRIGIENDO CONFIGURACIONES DE TECHDOCS ===${NC}"

# Función para corregir archivo de catálogo
fix_catalog_file() {
    local file="$1"
    local component_name="$2"
    
    if [ ! -f "$file" ]; then
        echo "❌ Archivo no encontrado: $file"
        return 1
    fi
    
    echo "🔧 Corrigiendo $file..."
    
    # Crear versión corregida sin techdocs problemático
    cat > "$file" << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $component_name
  description: Component for $component_name
  annotations:
    # GitHub integration
    github.com/project-slug: giovanemere/$component_name
    backstage.io/source-location: url:https://github.com/giovanemere/$component_name
    
    # View Source
    backstage.io/view-url: https://github.com/giovanemere/$component_name
    backstage.io/edit-url: https://github.com/giovanemere/$component_name/edit/main/catalog-info.yaml
    
    # TechDocs deshabilitado temporalmente para evitar errores
    # backstage.io/techdocs-ref: dir:.
    
  tags:
    - component
    - service
  links:
    - url: https://github.com/giovanemere/$component_name
      title: Repository
      icon: github
    - url: https://github.com/giovanemere/$component_name/actions
      title: GitHub Actions
      icon: github
    - url: https://github.com/giovanemere/$component_name/blob/main/README.md
      title: Documentation
      icon: docs
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: ia-ops-platform
EOF
    
    echo "✅ Corregido: $file"
}

# Corregir cada archivo
fix_catalog_file "catalog-poc-billpay-back.yaml" "poc-billpay-back"
fix_catalog_file "catalog-poc-billpay-front-a.yaml" "poc-billpay-front-a"
fix_catalog_file "catalog-poc-billpay-front-b.yaml" "poc-billpay-front-b"
fix_catalog_file "catalog-poc-billpay-front-feature-flags.yaml" "poc-billpay-front-feature-flags"
fix_catalog_file "catalog-poc-icbs.yaml" "poc-icbs"

echo ""
echo -e "${BLUE}=== 3. CONFIGURANDO TECHDOCS PARA MODO SEGURO ===${NC}"

# Verificar si hay configuración de TechDocs en app-config.yaml
if grep -q "techdocs:" app-config.yaml; then
    echo "🔧 Actualizando configuración de TechDocs..."
    
    # Crear backup de app-config.yaml
    cp app-config.yaml app-config.yaml.backup-$(date +%Y%m%d-%H%M%S)
    
    # Actualizar configuración de TechDocs para ser más tolerante a errores
    sed -i '/techdocs:/,/^[[:space:]]*[^[:space:]]/ {
        /builder:/c\  builder: '\''local'\''
        /runIn:/c\    runIn: '\''local'\''
        /type:/c\    type: '\''local'\''
    }' app-config.yaml
    
    echo "✅ Configuración de TechDocs actualizada"
fi

echo ""
echo -e "${BLUE}=== 4. VERIFICANDO ARCHIVOS CORREGIDOS ===${NC}"
for file in "${catalog_files[@]}"; do
    if [ -f "$file" ]; then
        echo "📄 $file:"
        if grep -q "backstage.io/techdocs-ref" "$file"; then
            echo "   ⚠️  TechDocs aún habilitado"
        else
            echo "   ✅ TechDocs deshabilitado"
        fi
    fi
done

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            CORRECCIÓN COMPLETADA                            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Archivos de catálogo corregidos${NC}"
echo -e "${GREEN}✅ TechDocs deshabilitado para componentes problemáticos${NC}"
echo -e "${GREEN}✅ Respaldos creados con timestamp${NC}"
echo ""
echo -e "${YELLOW}📝 PRÓXIMOS PASOS:${NC}"
echo "1. Reiniciar Backstage para aplicar cambios"
echo "2. Los errores de TechDocs deberían desaparecer"
echo "3. Para habilitar TechDocs más tarde, añadir docs/ y mkdocs.yml a cada repo"
echo ""
echo -e "${CYAN}🔧 COMANDOS ÚTILES:${NC}"
echo "   Reiniciar Backstage: ./start-backstage-only.sh"
echo "   Ver logs: tail -f backstage-*.log"
echo "   Restaurar backup: cp [archivo].backup-* [archivo]"
