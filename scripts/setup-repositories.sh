#!/bin/bash

# =============================================================================
# Script para configurar repositorios con Backstage
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Verificar que git esté instalado
if ! command -v git &> /dev/null; then
    error "Git no está instalado"
    exit 1
fi

# Verificar que gh CLI esté instalado (opcional)
if ! command -v gh &> /dev/null; then
    warn "GitHub CLI (gh) no está instalado. Se usará git directamente."
    USE_GH=false
else
    USE_GH=true
fi

# Repositorios a configurar
REPOS=(
    "templates_backstage"
    "poc-icbs"
    "poc-billpay-front-feature-flags"
    "poc-billpay-front-b"
    "poc-billpay-front-a"
    "poc-billpay-back"
)

# Usuario de GitHub
GITHUB_USER="giovanemere"

# Directorio temporal
TEMP_DIR="/tmp/backstage-setup"
mkdir -p "$TEMP_DIR"

log "Iniciando configuración de repositorios para Backstage..."

# Función para crear catalog-info.yaml para templates
create_templates_catalog() {
    local repo_path="$1"
    
    cat > "$repo_path/catalog-info.yaml" << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: templates-backstage
  title: Backstage Templates
  description: Templates de Backstage para IA-Ops Platform
  annotations:
    github.com/project-slug: giovanemere/templates_backstage
spec:
  targets:
    - ./templates/*/template.yaml
    - ./scaffolder-templates/*/template.yaml
EOF
    
    log "Creado catalog-info.yaml para templates"
}

# Función para crear catalog-info.yaml para aplicaciones
create_app_catalog() {
    local repo_name="$1"
    local repo_path="$2"
    local component_type="service"
    local title=""
    local description=""
    
    # Configurar según el repositorio
    case "$repo_name" in
        "poc-icbs")
            title="POC ICBS"
            description="Proof of Concept para sistema ICBS"
            component_type="service"
            ;;
        "poc-billpay-front-feature-flags")
            title="BillPay Frontend - Feature Flags"
            description="Frontend de BillPay con implementación de feature flags"
            component_type="website"
            ;;
        "poc-billpay-front-b")
            title="BillPay Frontend B"
            description="Versión B del frontend de BillPay"
            component_type="website"
            ;;
        "poc-billpay-front-a")
            title="BillPay Frontend A"
            description="Versión A del frontend de BillPay"
            component_type="website"
            ;;
        "poc-billpay-back")
            title="BillPay Backend"
            description="Backend API para el sistema BillPay"
            component_type="service"
            ;;
    esac
    
    cat > "$repo_path/catalog-info.yaml" << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $repo_name
  title: $title
  description: $description
  annotations:
    github.com/project-slug: $GITHUB_USER/$repo_name
    backstage.io/techdocs-ref: dir:.
  tags:
    - poc
    - billpay
    - ia-ops
  links:
    - url: https://github.com/$GITHUB_USER/$repo_name
      title: Repository
      icon: github
spec:
  type: $component_type
  lifecycle: experimental
  owner: platform-team
  system: billpay-system
EOF

    # Agregar dependencias para frontends
    if [[ "$repo_name" == *"front"* ]]; then
        cat >> "$repo_path/catalog-info.yaml" << EOF
  dependsOn:
    - component:poc-billpay-back
EOF
    fi

    # Agregar APIs para backend
    if [[ "$repo_name" == *"back"* ]]; then
        cat >> "$repo_path/catalog-info.yaml" << EOF
  providesApis:
    - billpay-api
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: billpay-api
  title: BillPay API
  description: API REST para el sistema de pagos BillPay
  annotations:
    github.com/project-slug: $GITHUB_USER/$repo_name
spec:
  type: openapi
  lifecycle: experimental
  owner: backend-team
  system: billpay-system
  definition: |
    openapi: 3.0.0
    info:
      title: BillPay API
      version: 1.0.0
      description: API para gestión de pagos
    paths:
      /health:
        get:
          summary: Health check
          responses:
            '200':
              description: Service is healthy
EOF
    fi
    
    log "Creado catalog-info.yaml para $repo_name"
}

# Función para crear mkdocs.yml
create_mkdocs_config() {
    local repo_name="$1"
    local repo_path="$2"
    local title=""
    
    case "$repo_name" in
        "poc-icbs")
            title="POC ICBS Documentation"
            ;;
        "poc-billpay-front-feature-flags")
            title="BillPay Frontend Feature Flags Documentation"
            ;;
        "poc-billpay-front-b")
            title="BillPay Frontend B Documentation"
            ;;
        "poc-billpay-front-a")
            title="BillPay Frontend A Documentation"
            ;;
        "poc-billpay-back")
            title="BillPay Backend Documentation"
            ;;
        *)
            title="$repo_name Documentation"
            ;;
    esac
    
    cat > "$repo_path/mkdocs.yml" << EOF
site_name: '$title'
site_description: 'Documentación del proyecto $repo_name'
site_url: 'https://github.com/$GITHUB_USER/$repo_name'

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Architecture: architecture.md
  - API Reference: api.md
  - Deployment: deployment.md
  - Contributing: contributing.md

plugins:
  - techdocs-core

theme:
  name: material
  palette:
    primary: blue
    accent: blue
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.highlight
    - search.share

markdown_extensions:
  - admonition
  - codehilite
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.details
  - pymdownx.highlight
  - pymdownx.inlinehilite
  - toc:
      permalink: true
  - attr_list
  - md_in_html

extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/$GITHUB_USER/$repo_name
EOF
    
    log "Creado mkdocs.yml para $repo_name"
}

# Función para crear documentación básica
create_basic_docs() {
    local repo_name="$1"
    local repo_path="$2"
    
    # Crear directorio docs
    mkdir -p "$repo_path/docs"
    
    # Crear index.md
    cat > "$repo_path/docs/index.md" << EOF
# $repo_name

Bienvenido a la documentación de $repo_name.

## Descripción

Este proyecto es parte del ecosistema IA-Ops Platform y está integrado con Backstage.

## Características

- Integración con Backstage
- Documentación automática con TechDocs
- CI/CD automatizado
- Monitoreo y observabilidad

## Enlaces útiles

- [Repositorio en GitHub](https://github.com/$GITHUB_USER/$repo_name)
- [Backstage](http://localhost:8080)
- [Documentación del proyecto](http://localhost:8080/docs/$repo_name)

## Soporte

Para soporte y preguntas, por favor crea un issue en el repositorio de GitHub.
EOF

    # Crear getting-started.md
    cat > "$repo_path/docs/getting-started.md" << EOF
# Getting Started

## Prerrequisitos

- Node.js 18+
- Docker
- Git

## Instalación

1. Clonar el repositorio:
   \`\`\`bash
   git clone https://github.com/$GITHUB_USER/$repo_name.git
   cd $repo_name
   \`\`\`

2. Instalar dependencias:
   \`\`\`bash
   npm install
   \`\`\`

3. Configurar variables de entorno:
   \`\`\`bash
   cp .env.example .env
   \`\`\`

4. Ejecutar en modo desarrollo:
   \`\`\`bash
   npm run dev
   \`\`\`

## Configuración

Edita el archivo \`.env\` con tus configuraciones específicas.

## Comandos útiles

- \`npm run dev\` - Ejecutar en modo desarrollo
- \`npm run build\` - Construir para producción
- \`npm run test\` - Ejecutar tests
- \`npm run lint\` - Ejecutar linter
EOF

    # Crear otros archivos de documentación
    touch "$repo_path/docs/architecture.md"
    touch "$repo_path/docs/api.md"
    touch "$repo_path/docs/deployment.md"
    touch "$repo_path/docs/contributing.md"
    
    log "Creada documentación básica para $repo_name"
}

# Función para procesar cada repositorio
process_repository() {
    local repo_name="$1"
    local repo_url="https://github.com/$GITHUB_USER/$repo_name.git"
    local repo_path="$TEMP_DIR/$repo_name"
    
    log "Procesando repositorio: $repo_name"
    
    # Clonar o actualizar repositorio
    if [ -d "$repo_path" ]; then
        log "Actualizando repositorio existente..."
        cd "$repo_path"
        git pull origin main || git pull origin master
    else
        log "Clonando repositorio..."
        git clone "$repo_url" "$repo_path"
        cd "$repo_path"
    fi
    
    # Crear archivos según el tipo de repositorio
    if [ "$repo_name" = "templates_backstage" ]; then
        create_templates_catalog "$repo_path"
    else
        create_app_catalog "$repo_name" "$repo_path"
        create_mkdocs_config "$repo_name" "$repo_path"
        create_basic_docs "$repo_name" "$repo_path"
    fi
    
    # Commit y push cambios
    git add .
    if git diff --staged --quiet; then
        log "No hay cambios para commitear en $repo_name"
    else
        git commit -m "feat: add Backstage integration with catalog-info.yaml and TechDocs

- Add catalog-info.yaml for Backstage catalog integration
- Add mkdocs.yml for TechDocs documentation
- Add basic documentation structure
- Configure component metadata and annotations"
        
        if [ "$USE_GH" = true ]; then
            gh repo set-default "$GITHUB_USER/$repo_name"
            git push origin HEAD
        else
            git push origin HEAD
        fi
        
        log "Cambios pusheados para $repo_name"
    fi
}

# Procesar todos los repositorios
for repo in "${REPOS[@]}"; do
    process_repository "$repo"
    echo ""
done

log "✅ Configuración completada!"
log ""
log "Próximos pasos:"
log "1. Reinicia Backstage para que detecte los nuevos componentes:"
log "   docker-compose restart backstage-backend"
log ""
log "2. Ve a http://localhost:8080 y verifica que los componentes aparezcan en el catálogo"
log ""
log "3. Verifica que TechDocs funcione visitando:"
log "   http://localhost:8080/docs/poc-icbs"
log "   http://localhost:8080/docs/poc-billpay-back"
log "   etc."
log ""
log "4. Si tienes templates en templates_backstage, estarán disponibles en:"
log "   http://localhost:8080/create"
