#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR TECHDOCS EN MODO DESARROLLO SEGURO
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
echo "║                    CONFIGURANDO TECHDOCS MODO SEGURO                        ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# =============================================================================
# 1. ACTUALIZAR CONFIGURACIÓN DE TECHDOCS EN APP-CONFIG.YAML
# =============================================================================

echo -e "${BLUE}=== 1. CONFIGURANDO TECHDOCS PARA MODO DESARROLLO ===${NC}"

# Crear backup
cp app-config.yaml app-config.yaml.backup-techdocs-$(date +%Y%m%d-%H%M%S)

# Actualizar configuración de TechDocs
cat > temp_techdocs_config.yaml << 'EOF'
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
    # Configuración más tolerante a errores
    mkdocs:
      defaultPlugins:
        - search
        - techdocs-core
  publisher:
    type: 'local'
    # Configuración local sin AWS
    local:
      publishDirectory: './techdocs-storage'
  # Configuración de búsqueda más permisiva
  search:
    enabled: true
    # No fallar si no hay documentos
    allowEmptyIndex: true
EOF

# Reemplazar la sección de techdocs en app-config.yaml
echo "🔧 Actualizando configuración de TechDocs..."

# Usar sed para reemplazar la sección de techdocs
sed -i '/^techdocs:/,/^[[:alpha:]]/ {
  /^techdocs:/r temp_techdocs_config.yaml
  /^techdocs:/,/^[[:alpha:]]/ {
    /^[[:alpha:]]/!d
  }
}' app-config.yaml

# Limpiar archivo temporal
rm temp_techdocs_config.yaml

echo "✅ Configuración de TechDocs actualizada"

# =============================================================================
# 2. CREAR DOCUMENTACIÓN BÁSICA PARA EVITAR WARNINGS
# =============================================================================

echo ""
echo -e "${BLUE}=== 2. CREANDO DOCUMENTACIÓN BÁSICA ===${NC}"

# Crear directorio de documentación local
mkdir -p ./docs-local/ia-ops-platform

# Crear documentación básica para IA-OPS
cat > ./docs-local/ia-ops-platform/index.md << 'EOF'
# IA-OPS Platform Documentation

## Overview

IA-OPS Platform es una solución completa que integra:

- **🏛️ Backstage**: Portal de desarrolladores
- **🤖 OpenAI Service**: Servicio nativo de IA con conocimiento DevOps
- **📚 Documentación Inteligente**: MkDocs + TechDocs
- **🎯 Templates Multi-Cloud**: Catálogo de despliegues para Azure, AWS, OCI y GCP

## Quick Start

1. Accede a [Backstage](http://localhost:3002)
2. Explora el catálogo de componentes
3. Utiliza los templates para crear nuevos proyectos
4. Consulta la documentación integrada

## Architecture

La plataforma está construida con una arquitectura modular que permite:

- Escalabilidad horizontal
- Integración con múltiples proveedores cloud
- Automatización de procesos DevOps
- Monitoreo y observabilidad integrados

## Support

Para soporte técnico, consulta:
- [GitHub Issues](https://github.com/giovanemere/ia-ops/issues)
- [Documentation](http://localhost:8005)
- [Framework](http://localhost:1100)
EOF

# Crear mkdocs.yml para la documentación local
cat > ./docs-local/mkdocs.yml << 'EOF'
site_name: IA-OPS Platform
site_description: Plataforma integrada de IA y DevOps

nav:
  - Home: ia-ops-platform/index.md

theme:
  name: material
  palette:
    primary: blue
    accent: light-blue

plugins:
  - search
  - techdocs-core

markdown_extensions:
  - admonition
  - codehilite
  - pymdownx.superfences
EOF

echo "✅ Documentación básica creada"

# =============================================================================
# 3. CREAR ENTIDAD DE DOCUMENTACIÓN EN EL CATÁLOGO
# =============================================================================

echo ""
echo -e "${BLUE}=== 3. CREANDO ENTIDAD DE DOCUMENTACIÓN ===${NC}"

cat > catalog-docs-ia-ops.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ia-ops-documentation
  description: Documentación principal de la plataforma IA-OPS
  annotations:
    # TechDocs habilitado para documentación local
    backstage.io/techdocs-ref: dir:./docs-local
    
    # GitHub integration
    github.com/project-slug: giovanemere/ia-ops
    backstage.io/source-location: url:https://github.com/giovanemere/ia-ops
    
  tags:
    - documentation
    - platform
  links:
    - url: http://localhost:8005
      title: MkDocs Documentation
      icon: docs
    - url: http://localhost:1100
      title: Framework Documentation
      icon: docs
spec:
  type: documentation
  lifecycle: production
  owner: platform-team
  system: ia-ops-platform
EOF

echo "✅ Entidad de documentación creada"

# =============================================================================
# 4. ACTUALIZAR CATÁLOGO PRINCIPAL
# =============================================================================

echo ""
echo -e "${BLUE}=== 4. ACTUALIZANDO CATÁLOGO PRINCIPAL ===${NC}"

# Verificar si ya existe la referencia en catalog-info.yaml
if ! grep -q "catalog-docs-ia-ops.yaml" catalog-info.yaml 2>/dev/null; then
    # Añadir referencia al catálogo principal
    cat >> catalog-info.yaml << 'EOF'

---
# Documentación de la plataforma
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: ia-ops-docs
  description: Documentación de IA-OPS Platform
spec:
  targets:
    - ./catalog-docs-ia-ops.yaml
EOF
    echo "✅ Referencia añadida al catálogo principal"
else
    echo "✅ Referencia ya existe en el catálogo principal"
fi

# =============================================================================
# 5. VERIFICAR CONFIGURACIÓN
# =============================================================================

echo ""
echo -e "${BLUE}=== 5. VERIFICANDO CONFIGURACIÓN ===${NC}"

# Verificar que los archivos existen
files_to_check=(
    "docs-local/ia-ops-platform/index.md"
    "docs-local/mkdocs.yml"
    "catalog-docs-ia-ops.yaml"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file"
    fi
done

# Verificar configuración de TechDocs
if grep -q "allowEmptyIndex" app-config.yaml; then
    echo "✅ Configuración de TechDocs actualizada"
else
    echo "⚠️ Configuración de TechDocs puede necesitar ajustes manuales"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            CONFIGURACIÓN COMPLETADA                         ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ TechDocs configurado en modo desarrollo seguro${NC}"
echo -e "${GREEN}✅ Documentación básica creada${NC}"
echo -e "${GREEN}✅ Entidad de documentación añadida al catálogo${NC}"
echo ""
echo -e "${YELLOW}📝 PRÓXIMOS PASOS:${NC}"
echo "1. Reiniciar Backstage para aplicar cambios"
echo "2. El warning de 'indexer received 0 documents' debería desaparecer"
echo "3. Verificar que la documentación aparece en el catálogo"
echo ""
echo -e "${CYAN}🔧 COMANDOS ÚTILES:${NC}"
echo "   Reiniciar Backstage: ./start-backstage-only.sh"
echo "   Ver documentación: http://localhost:3002/docs/default/component/ia-ops-documentation"
echo "   Verificar logs: tail -f backstage-*.log | grep -i techdocs"
