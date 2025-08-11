#!/bin/bash

# =============================================================================
# SCRIPT PARA APLICAR DOCUMENTACIÓN A REPOSITORIOS LOCALES
# =============================================================================

set -e

echo "🚀 Aplicando documentación automática a repositorios locales..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Definir rutas de repositorios locales
BILLPAY_BASE="/home/giovanemere/periferia/billpay/Repositorios-Github"
ICBS_BASE="/home/giovanemere/periferia/icbs"

# Mapeo de repositorios: nombre_en_backstage:ruta_local:nombre_real
REPOS=(
    "poc-billpay-back:$BILLPAY_BASE/poc-billpay-back:poc-billpay-back"
    "poc-billpay-front-a:$BILLPAY_BASE/poc-billpay-front-a:poc-billpay-front-a"
    "poc-billpay-front-b:$BILLPAY_BASE/poc-billpay-front-b:poc-billpay-front-b"
    "poc-billpay-front-feature-flags:$BILLPAY_BASE/poc-billpay-front-feature-flags:poc-billpay-front-feature-flags"
    "poc-icbs:$ICBS_BASE/docker-for-oracle-weblogic:poc-icbs"
)

# Verificar que tenemos la documentación generada
if [ ! -d "repo-docs" ]; then
    log_error "No se encontró el directorio repo-docs. Ejecuta primero ./setup-repo-docs.sh"
    exit 1
fi

echo ""
log_info "=== APLICANDO DOCUMENTACIÓN A REPOSITORIOS LOCALES ==="

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r backstage_name local_path real_name <<< "$repo_info"
    
    echo ""
    log_info "Procesando $backstage_name -> $local_path"
    
    # Verificar que el repositorio local existe
    if [ ! -d "$local_path" ]; then
        log_error "Repositorio no encontrado: $local_path"
        continue
    fi
    
    # Verificar que tenemos la documentación generada
    if [ ! -d "repo-docs/$backstage_name" ]; then
        log_error "Documentación no encontrada para: $backstage_name"
        continue
    fi
    
    log_success "Repositorio encontrado: $local_path"
    
    # Crear backup si ya existe documentación
    if [ -d "$local_path/docs" ]; then
        log_warning "Documentación existente encontrada, creando backup..."
        mv "$local_path/docs" "$local_path/docs.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    if [ -f "$local_path/mkdocs.yml" ]; then
        mv "$local_path/mkdocs.yml" "$local_path/mkdocs.yml.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    if [ -f "$local_path/catalog-info.yaml" ]; then
        mv "$local_path/catalog-info.yaml" "$local_path/catalog-info.yaml.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copiar documentación
    log_info "Copiando documentación..."
    cp -r "repo-docs/$backstage_name/docs" "$local_path/"
    cp "repo-docs/$backstage_name/mkdocs.yml" "$local_path/"
    cp "repo-docs/$backstage_name/catalog-info.yaml" "$local_path/"
    
    # Verificar que los archivos se copiaron correctamente
    if [ -d "$local_path/docs" ] && [ -f "$local_path/mkdocs.yml" ] && [ -f "$local_path/catalog-info.yaml" ]; then
        log_success "Documentación aplicada exitosamente a $real_name"
        
        # Mostrar estructura creada
        echo "   📂 $local_path/"
        echo "   ├── 📂 docs/"
        echo "   │   ├── 📄 index.md"
        echo "   │   ├── 📄 api.md"
        echo "   │   ├── 📄 architecture.md"
        echo "   │   └── 📄 deployment.md"
        echo "   ├── 📄 mkdocs.yml"
        echo "   └── 📄 catalog-info.yaml"
    else
        log_error "Error al copiar archivos a $real_name"
    fi
done

echo ""
log_info "=== CREANDO SCRIPT DE COMMIT AUTOMÁTICO ==="

# Crear script para hacer commit en todos los repositorios
cat > commit-docs-to-repos.sh << 'EOF'
#!/bin/bash

echo "📝 Haciendo commit de documentación en repositorios locales..."

# Definir rutas de repositorios locales
BILLPAY_BASE="/home/giovanemere/periferia/billpay/Repositorios-Github"
ICBS_BASE="/home/giovanemere/periferia/icbs"

REPOS=(
    "poc-billpay-back:$BILLPAY_BASE/poc-billpay-back"
    "poc-billpay-front-a:$BILLPAY_BASE/poc-billpay-front-a"
    "poc-billpay-front-b:$BILLPAY_BASE/poc-billpay-front-b"
    "poc-billpay-front-feature-flags:$BILLPAY_BASE/poc-billpay-front-feature-flags"
    "poc-icbs:$ICBS_BASE/docker-for-oracle-weblogic"
)

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_path <<< "$repo_info"
    
    echo ""
    echo "📁 Procesando $repo_name..."
    
    if [ -d "$repo_path" ]; then
        cd "$repo_path"
        
        # Verificar si es un repositorio git
        if [ -d ".git" ]; then
            echo "✅ Repositorio Git encontrado"
            
            # Agregar archivos
            git add docs/ mkdocs.yml catalog-info.yaml 2>/dev/null || echo "⚠️  Algunos archivos no se pudieron agregar"
            
            # Verificar si hay cambios para commit
            if git diff --staged --quiet; then
                echo "ℹ️  No hay cambios para commit en $repo_name"
            else
                # Hacer commit
                git commit -m "feat: Add Backstage documentation and catalog

- Add comprehensive documentation with MkDocs
- Add catalog-info.yaml for Backstage integration
- Enable automatic documentation generation
- Add API, architecture, and deployment docs

Generated by IA-Ops Platform automation"
                
                echo "✅ Commit realizado en $repo_name"
                
                # Mostrar status
                echo "📊 Status del repositorio:"
                git status --porcelain
            fi
        else
            echo "⚠️  No es un repositorio Git: $repo_path"
        fi
    else
        echo "❌ Repositorio no encontrado: $repo_path"
    fi
done

echo ""
echo "🎯 Commits completados!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Revisar los commits en cada repositorio"
echo "2. Hacer push si todo está correcto:"
echo "   git push origin main"
echo "3. Reiniciar Backstage para ver los cambios"
EOF

chmod +x commit-docs-to-repos.sh

log_success "Script de commit creado: commit-docs-to-repos.sh"

echo ""
log_info "=== VERIFICANDO APLICACIÓN ==="

# Verificar que todo se aplicó correctamente
success_count=0
total_count=0

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r backstage_name local_path real_name <<< "$repo_info"
    total_count=$((total_count + 1))
    
    if [ -d "$local_path/docs" ] && [ -f "$local_path/mkdocs.yml" ] && [ -f "$local_path/catalog-info.yaml" ]; then
        success_count=$((success_count + 1))
    fi
done

echo ""
log_info "=== RESUMEN DE APLICACIÓN ==="

echo "📊 Resultados:"
echo "   ✅ Repositorios procesados exitosamente: $success_count/$total_count"
echo "   📁 Ubicaciones aplicadas:"

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r backstage_name local_path real_name <<< "$repo_info"
    
    if [ -d "$local_path/docs" ]; then
        echo "      ✅ $real_name: $local_path"
    else
        echo "      ❌ $real_name: $local_path"
    fi
done

echo ""
echo "🎯 Funcionalidades habilitadas:"
echo "   📚 Docs: Documentación automática con MkDocs"
echo "   👁️  View Source: Enlaces directos a GitHub"
echo "   🔄 CI/CD: Integración con GitHub Actions"
echo "   🤖 GitHub Actions: Workflows visibles en Backstage"

echo ""
echo "🚀 Próximos pasos:"
echo "1. Ejecutar: ./commit-docs-to-repos.sh"
echo "2. Revisar commits en cada repositorio"
echo "3. Hacer push: git push origin main (en cada repo)"
echo "4. Reiniciar Backstage: cd .. && ./kill-ports.sh && yarn start"
echo "5. Verificar en: http://localhost:3002"

if [ $success_count -eq $total_count ]; then
    echo ""
    log_success "¡Documentación aplicada exitosamente a todos los repositorios!"
else
    echo ""
    log_warning "Algunos repositorios tuvieron problemas. Revisar logs anteriores."
fi
EOF
