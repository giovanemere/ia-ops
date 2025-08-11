#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR DOCUMENTACIÓN AUTOMÁTICA EN BACKSTAGE
# =============================================================================
# Descripción: Configura TechDocs, GitHub Actions, CI/CD y View Source
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

echo "📚 Configurando documentación automática en Backstage..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar directorio
if [ ! -f "app-config.yaml" ]; then
    log_error "No se encontró app-config.yaml. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo ""
log_info "=== CONFIGURANDO TECHDOCS (DOCUMENTACIÓN AUTOMÁTICA) ==="

# Backup del app-config.yaml
cp app-config.yaml app-config.yaml.backup.$(date +%Y%m%d_%H%M%S)
log_info "Backup creado de app-config.yaml"

# Configurar TechDocs
log_info "Configurando TechDocs para documentación automática..."

# Verificar si TechDocs ya está configurado
if grep -q "techdocs:" app-config.yaml; then
    log_warning "TechDocs ya está configurado, actualizando..."
    
    # Actualizar configuración existente
    sed -i '/techdocs:/,/^[[:space:]]*[^[:space:]]/ {
        /builder:/c\  builder: local
        /generator:/c\  generator:
        /runIn:/c\    runIn: local
        /publisher:/c\  publisher:
        /type:/c\    type: local
    }' app-config.yaml
else
    # Agregar configuración de TechDocs
    cat >> app-config.yaml << 'EOF'

# =============================================================================
# TECHDOCS CONFIGURATION (DOCUMENTACIÓN AUTOMÁTICA)
# =============================================================================
techdocs:
  builder: 'local' # Alternatives - 'external'
  generator:
    runIn: 'local' # Alternatives - 'docker'
  publisher:
    type: 'local' # Alternatives - 'googleGcs' or 'awsS3'. Read documentation for using alternatives.
  
  # Configuración avanzada
  cache:
    ttl: 3600000 # 1 hour in milliseconds
    readTimeout: 5000
  
  # Configuración de generación
  defaultMkdocsPlugins:
    - techdocs-core
    - search
    - mkdocs-mermaid2-plugin
EOF
fi

log_success "TechDocs configurado"

echo ""
log_info "=== CONFIGURANDO GITHUB ACTIONS INTEGRATION ==="

# Configurar GitHub Actions
if ! grep -q "github-actions:" app-config.yaml; then
    cat >> app-config.yaml << 'EOF'

# =============================================================================
# GITHUB ACTIONS CONFIGURATION
# =============================================================================
github-actions:
  # Configuración para mostrar workflows automáticamente
  proxyPath: /github-actions
  
  # Configuración de cache
  cache:
    ttl: 300000 # 5 minutes
    
  # Configuración de polling
  scheduler:
    frequency: { minutes: 5 }
    timeout: { minutes: 2 }
EOF
    log_success "GitHub Actions configurado"
else
    log_warning "GitHub Actions ya está configurado"
fi

echo ""
log_info "=== CONFIGURANDO CATALOG DISCOVERY AUTOMÁTICO ==="

# Habilitar discovery automático
sed -i '/# providers:/c\  providers:' app-config.yaml
sed -i '/# github:/c\    github:' app-config.yaml

# Configurar discovery de organización
cat >> app-config.yaml << 'EOF'

# =============================================================================
# CATALOG DISCOVERY AUTOMÁTICO
# =============================================================================
catalog:
  providers:
    github:
      # Descubrimiento automático de la organización
      giovanemere:
        organization: 'giovanemere'
        catalogPath: '/catalog-info.yaml' # Buscar catalog-info.yaml en la raíz
        filters:
          branch: 'main' # También buscar en 'trunk' si es necesario
          repository: '.*' # Todos los repositorios
        schedule:
          frequency: { minutes: 10 } # Revisar cada 10 minutos
          timeout: { minutes: 3 }
          
      # Configuración específica para repositorios conocidos
      repositories:
        - organization: 'giovanemere'
          repository: 'ia-ops'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'templates_backstage'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'ia-ops-framework'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'poc-billpay-back'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'poc-billpay-front-a'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'poc-billpay-front-b'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'poc-billpay-front-feature-flags'
          catalogPath: '/catalog-info.yaml'
        - organization: 'giovanemere'
          repository: 'poc-icbs'
          catalogPath: '/catalog-info.yaml'
EOF

log_success "Catalog Discovery configurado"

echo ""
log_info "=== CONFIGURANDO ANOTACIONES AUTOMÁTICAS ==="

# Crear template de catalog-info.yaml para repositorios
cat > catalog-template.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: COMPONENT_NAME
  description: COMPONENT_DESCRIPTION
  annotations:
    # Documentación automática
    backstage.io/techdocs-ref: dir:.
    
    # GitHub integration
    github.com/project-slug: giovanemere/REPO_NAME
    backstage.io/source-location: url:https://github.com/giovanemere/REPO_NAME
    
    # CI/CD integration
    github.com/workflows: .github/workflows/
    
    # View Source
    backstage.io/view-url: https://github.com/giovanemere/REPO_NAME
    backstage.io/edit-url: https://github.com/giovanemere/REPO_NAME/edit/main/catalog-info.yaml
    
  tags:
    - component
    - service
  links:
    - url: https://github.com/giovanemere/REPO_NAME
      title: Repository
      icon: github
    - url: https://github.com/giovanemere/REPO_NAME/actions
      title: GitHub Actions
      icon: github
    - url: https://github.com/giovanemere/REPO_NAME/blob/main/README.md
      title: Documentation
      icon: docs
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: ia-ops-platform
EOF

log_success "Template de catalog-info.yaml creado"

echo ""
log_info "=== CONFIGURANDO MKDOCS AUTOMÁTICO ==="

# Crear configuración base de MkDocs
cat > mkdocs-template.yml << 'EOF'
site_name: 'COMPONENT_NAME Documentation'
site_description: 'Documentación automática generada por Backstage TechDocs'

nav:
  - Home: index.md
  - API: api.md
  - Architecture: architecture.md
  - Deployment: deployment.md

plugins:
  - techdocs-core
  - search
  - mermaid2

theme:
  name: material
  palette:
    primary: blue
    accent: blue

markdown_extensions:
  - admonition
  - codehilite
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:mermaid2.fence_mermaid

repo_url: https://github.com/giovanemere/REPO_NAME
edit_uri: edit/main/docs/
EOF

log_success "Template de MkDocs creado"

echo ""
log_info "=== INSTALANDO DEPENDENCIAS NECESARIAS ==="

# Instalar plugins necesarios para TechDocs
if ! yarn list @backstage/plugin-techdocs 2>/dev/null | grep -q "@backstage/plugin-techdocs"; then
    log_info "Instalando plugin TechDocs..."
    yarn workspace app add @backstage/plugin-techdocs
    yarn workspace app add @backstage/plugin-techdocs-react
fi

# Instalar plugin GitHub Actions si no está
if ! yarn list @backstage/plugin-github-actions 2>/dev/null | grep -q "@backstage/plugin-github-actions"; then
    log_info "Instalando plugin GitHub Actions..."
    yarn workspace app add @backstage/plugin-github-actions
fi

log_success "Dependencias instaladas"

echo ""
log_info "=== CREANDO SCRIPT DE GENERACIÓN AUTOMÁTICA ==="

# Crear script para generar catalog-info.yaml en repositorios
cat > generate-catalog-files.sh << 'EOF'
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
EOF

chmod +x generate-catalog-files.sh
log_success "Script de generación creado"

echo ""
log_info "=== RESUMEN DE CONFIGURACIÓN ==="

echo "📚 Documentación automática configurada:"
echo "   ✅ TechDocs habilitado (local)"
echo "   ✅ GitHub Actions integration"
echo "   ✅ Catalog Discovery automático"
echo "   ✅ Templates de configuración creados"
echo "   ✅ Scripts de generación listos"

echo ""
echo "🎯 Funcionalidades habilitadas:"
echo "   📖 Docs: Generación automática con MkDocs"
echo "   👁️  View Source: Enlaces directos a GitHub"
echo "   🔄 CI/CD: Integración con GitHub Actions"
echo "   🤖 GitHub Actions: Workflows visibles en Backstage"

echo ""
echo "🚀 Próximos pasos:"
echo "1. Ejecutar: ./generate-catalog-files.sh"
echo "2. Copiar catalog-info.yaml a repositorios"
echo "3. Crear documentación básica (docs/index.md)"
echo "4. Reiniciar Backstage: yarn start"
echo "5. Verificar en: http://localhost:3002"

echo ""
log_success "¡Configuración de documentación automática completada!"
EOF
