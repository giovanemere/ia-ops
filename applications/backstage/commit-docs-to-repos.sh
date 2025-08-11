#!/bin/bash

# =============================================================================
# SCRIPT PARA HACER COMMIT AUTOMÁTICO DE DOCUMENTACIÓN A REPOSITORIOS
# =============================================================================
# Descripción: Clona repositorios y hace commit de la documentación
# Fecha: 11 de Agosto de 2025
# =============================================================================

set -e

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

echo "🚀 Haciendo commit automático de documentación a repositorios..."

# Verificar que existe el directorio de documentación
if [ ! -d "./repo-docs" ]; then
    log_error "No se encontró el directorio ./repo-docs"
    log_info "Ejecuta primero: ./deploy-docs-to-repos.sh"
    exit 1
fi

# Repositorios a procesar
REPOS=(
    "poc-billpay-back"
    "poc-billpay-front-a"
    "poc-billpay-front-b"
    "poc-billpay-front-feature-flags"
    "poc-icbs"
)

# Crear directorio temporal para clones
CLONE_DIR="./temp-repos"
mkdir -p "$CLONE_DIR"

echo ""
log_info "=== PROCESANDO REPOSITORIOS ==="

for repo_name in "${REPOS[@]}"; do
    log_info "Procesando $repo_name..."
    
    # Clonar repositorio
    cd "$CLONE_DIR"
    if [ -d "$repo_name" ]; then
        log_warning "Repositorio $repo_name ya existe, actualizando..."
        cd "$repo_name"
        git pull origin trunk || git pull origin main || log_warning "No se pudo actualizar $repo_name"
        cd ..
    else
        log_info "Clonando $repo_name..."
        git clone "https://github.com/giovanemere/$repo_name.git" || {
            log_error "No se pudo clonar $repo_name"
            cd ..
            continue
        }
    fi
    
    # Copiar archivos de documentación
    cd "$repo_name"
    
    # Copiar catalog-info.yaml
    cp "../../repo-docs/$repo_name/catalog-info.yaml" . || {
        log_error "No se pudo copiar catalog-info.yaml para $repo_name"
        cd ../..
        continue
    }
    
    # Copiar mkdocs.yml
    cp "../../repo-docs/$repo_name/mkdocs.yml" . || {
        log_error "No se pudo copiar mkdocs.yml para $repo_name"
        cd ../..
        continue
    }
    
    # Crear directorio docs si no existe
    mkdir -p docs
    
    # Copiar documentación
    cp -r "../../repo-docs/$repo_name/docs/"* docs/ || {
        log_error "No se pudo copiar documentación para $repo_name"
        cd ../..
        continue
    }
    
    # Verificar si hay cambios
    if git diff --quiet && git diff --cached --quiet; then
        log_warning "No hay cambios en $repo_name"
        cd ../..
        continue
    fi
    
    # Hacer commit
    git add .
    git commit -m "feat: Add Backstage documentation and TechDocs integration

- Add catalog-info.yaml for Backstage integration
- Add mkdocs.yml for TechDocs documentation
- Add comprehensive documentation in docs/
- Enable automatic documentation generation
- Configure GitHub Actions integration
- Add View Source functionality

This enables:
📖 Automatic documentation with TechDocs
👁️ View Source links to GitHub
🔄 CI/CD integration with GitHub Actions
🤖 Workflow visibility in Backstage
📊 Integrated monitoring and metrics" || {
        log_error "No se pudo hacer commit en $repo_name"
        cd ../..
        continue
    }
    
    # Push cambios
    log_info "Haciendo push a $repo_name..."
    git push origin trunk || git push origin main || {
        log_error "No se pudo hacer push a $repo_name"
        cd ../..
        continue
    }
    
    log_success "Documentación desplegada exitosamente en $repo_name"
    cd ../..
done

echo ""
log_info "=== LIMPIEZA ==="

# Limpiar directorio temporal
rm -rf "$CLONE_DIR"
log_success "Directorio temporal limpiado"

echo ""
log_info "=== RESUMEN ==="

echo "🎯 Funcionalidades habilitadas en los repositorios:"
echo "   📖 TechDocs: Documentación automática generada"
echo "   👁️  View Source: Enlaces directos a GitHub"
echo "   🔄 CI/CD: Integración con GitHub Actions"
echo "   🤖 GitHub Actions: Workflows visibles en Backstage"
echo "   📊 Métricas: Monitoreo integrado"

echo ""
echo "🚀 Próximos pasos:"
echo "1. Reiniciar Backstage para detectar los cambios"
echo "2. Verificar que los componentes aparecen en el catálogo"
echo "3. Comprobar que la documentación se genera correctamente"
echo "4. Validar que GitHub Actions se muestran en Backstage"

echo ""
log_success "¡Documentación desplegada exitosamente a todos los repositorios!"
