#!/bin/bash

# =============================================================================
# SETUP MKDOCS WITH BACKSTAGE TECHDOCS
# =============================================================================
# Script para configurar MkDocs con Backstage TechDocs
# Autor: DevOps Team
# Fecha: $(date +%Y-%m-%d)

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables
PROJECT_ROOT="/home/giovanemere/ia-ops/ia-ops"
DOCS_DIR="$PROJECT_ROOT/docs"
EXAMPLES_DIR="$PROJECT_ROOT/examples"

# Función principal
main() {
    log_info "Iniciando configuración de MkDocs con Backstage TechDocs..."
    
    # Verificar dependencias
    check_dependencies
    
    # Crear estructura de documentación
    create_docs_structure
    
    # Configurar MkDocs
    setup_mkdocs_config
    
    # Configurar Backstage TechDocs
    configure_backstage_techdocs
    
    # Instalar dependencias de Python
    install_python_dependencies
    
    # Validar configuración
    validate_setup
    
    log_success "¡Configuración de MkDocs con Backstage completada!"
    show_next_steps
}

# Verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 no está instalado"
        exit 1
    fi
    
    # Verificar pip
    if ! command -v pip3 &> /dev/null; then
        log_error "pip3 no está instalado"
        exit 1
    fi
    
    log_success "Dependencias verificadas"
}

# Crear estructura de documentación
create_docs_structure() {
    log_info "Creando estructura de documentación..."
    
    # Crear directorios
    mkdir -p "$DOCS_DIR"/{api,guides,assets/{images,diagrams}}
    
    # Crear archivos base si no existen
    touch "$DOCS_DIR"/{index.md,getting-started.md,architecture.md}
    touch "$DOCS_DIR"/api/{index.md,endpoints.md}
    touch "$DOCS_DIR"/guides/{deployment.md,troubleshooting.md}
    
    log_success "Estructura de documentación creada"
}

# Configurar MkDocs
setup_mkdocs_config() {
    log_info "Configurando MkDocs..."
    
    # Crear mkdocs.yml optimizado para TechDocs
    cat > "$PROJECT_ROOT/mkdocs.yml" << 'EOF'
site_name: 'IA-Ops Platform'
site_description: 'Plataforma integrada de IA y DevOps con Backstage'
site_author: 'DevOps Team'

# Navegación
nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Architecture: architecture.md
  - API Reference:
    - Overview: api/index.md
    - Endpoints: api/endpoints.md
  - Guides:
    - Deployment: guides/deployment.md
    - Troubleshooting: guides/troubleshooting.md

# Plugin requerido para TechDocs
plugins:
  - techdocs-core
  - search:
      lang: 
        - en
        - es

# Tema Material Design
theme:
  name: material
  palette:
    - scheme: default
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy
    - content.code.annotate

# Extensiones de Markdown
markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - attr_list
  - md_in_html
  - toc:
      permalink: true
      title: En esta página

# Configuración adicional
extra:
  version:
    provider: mike
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/giovanemere/ia-ops
EOF
    
    log_success "Configuración de MkDocs creada"
}

# Instalar dependencias de Python
install_python_dependencies() {
    log_info "Instalando dependencias de Python..."
    
    # Crear requirements.txt para documentación
    cat > "$PROJECT_ROOT/requirements-docs.txt" << 'EOF'
mkdocs>=1.5.0
mkdocs-material>=9.0.0
mkdocs-techdocs-core>=1.3.0
mkdocs-mermaid2-plugin>=1.1.0
pymdown-extensions>=10.0.0
mkdocs-git-revision-date-localized-plugin>=1.2.0
mkdocs-minify-plugin>=0.7.0
EOF
    
    # Instalar dependencias
    pip3 install -r "$PROJECT_ROOT/requirements-docs.txt"
    
    log_success "Dependencias de Python instaladas"
}

# Configurar Backstage TechDocs
configure_backstage_techdocs() {
    log_info "Configurando Backstage TechDocs..."
    
    # Actualizar app-config.yaml con configuración avanzada de TechDocs
    if [ -f "$PROJECT_ROOT/app-config.yaml" ]; then
        # Crear backup
        cp "$PROJECT_ROOT/app-config.yaml" "$PROJECT_ROOT/app-config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Actualizar configuración de TechDocs
        python3 << 'EOF'
import yaml
import sys

config_file = "/home/giovanemere/ia-ops/ia-ops/app-config.yaml"

try:
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)
    
    # Configuración avanzada de TechDocs
    config['techdocs'] = {
        'builder': 'local',
        'generator': {
            'runIn': 'local',
            'dockerImage': 'spotify/techdocs',
            'pullImage': True
        },
        'publisher': {
            'type': 'local',
            'local': {
                'publishDirectory': '/tmp/techdocs'
            }
        },
        'cache': {
            'ttl': 3600000,
            'readTimeout': 5000
        },
        'requestUrl': 'http://localhost:7007/api/techdocs',
        'storageUrl': 'http://localhost:7007/api/techdocs/static/docs'
    }
    
    with open(config_file, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, indent=2)
    
    print("Configuración de TechDocs actualizada")
    
except Exception as e:
    print(f"Error actualizando configuración: {e}")
    sys.exit(1)
EOF
    fi
    
    log_success "Configuración de Backstage TechDocs actualizada"
}

# Validar configuración
validate_setup() {
    log_info "Validando configuración..."
    
    # Verificar que mkdocs.yml es válido
    if mkdocs config > /dev/null 2>&1; then
        log_success "Configuración de MkDocs válida"
    else
        log_error "Configuración de MkDocs inválida"
        exit 1
    fi
    
    # Intentar construir documentación
    if mkdocs build --quiet; then
        log_success "Documentación construida exitosamente"
        rm -rf site/  # Limpiar archivos de construcción
    else
        log_error "Error construyendo documentación"
        exit 1
    fi
}

# Mostrar próximos pasos
show_next_steps() {
    echo ""
    log_info "=== PRÓXIMOS PASOS ==="
    echo ""
    echo "1. Servir documentación localmente:"
    echo "   cd $PROJECT_ROOT && mkdocs serve"
    echo ""
    echo "2. Ver documentación en: http://localhost:8000"
    echo ""
    echo "3. Editar documentación en: $DOCS_DIR/"
    echo ""
    echo "4. Construir documentación:"
    echo "   cd $PROJECT_ROOT && mkdocs build"
    echo ""
    echo "5. Ver documentación en Backstage:"
    echo "   http://localhost:3000 (después de iniciar Backstage)"
    echo ""
    echo "6. Archivos importantes:"
    echo "   - Configuración: $PROJECT_ROOT/mkdocs.yml"
    echo "   - Documentación: $DOCS_DIR/"
    echo "   - Dependencias: $PROJECT_ROOT/requirements-docs.txt"
    echo ""
}

# Ejecutar función principal
main "$@"
