#!/bin/bash

# =============================================================================
# SCRIPT PARA HACER PUSH DE DOCUMENTACIÓN A GITHUB
# =============================================================================

set -e

echo "🚀 Haciendo push de documentación a GitHub..."

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

REPOS=(
    "poc-billpay-back:$BILLPAY_BASE/poc-billpay-back"
    "poc-billpay-front-a:$BILLPAY_BASE/poc-billpay-front-a"
    "poc-billpay-front-b:$BILLPAY_BASE/poc-billpay-front-b"
    "poc-billpay-front-feature-flags:$BILLPAY_BASE/poc-billpay-front-feature-flags"
    "poc-icbs:$ICBS_BASE/docker-for-oracle-weblogic"
)

echo ""
log_info "=== HACIENDO PUSH A REPOSITORIOS GITHUB ==="

success_count=0
total_count=0

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_path <<< "$repo_info"
    total_count=$((total_count + 1))
    
    echo ""
    log_info "Procesando $repo_name..."
    
    if [ -d "$repo_path" ]; then
        cd "$repo_path"
        
        # Verificar si es un repositorio git
        if [ -d ".git" ]; then
            log_success "Repositorio Git encontrado: $repo_path"
            
            # Verificar branch actual
            current_branch=$(git branch --show-current)
            log_info "Branch actual: $current_branch"
            
            # Verificar si hay cambios para push
            if git diff --quiet HEAD origin/$current_branch 2>/dev/null; then
                log_warning "No hay cambios para push en $repo_name"
            else
                log_info "Haciendo push de cambios..."
                
                # Hacer push
                if git push origin $current_branch; then
                    log_success "Push exitoso para $repo_name"
                    success_count=$((success_count + 1))
                    
                    # Verificar que catalog-info.yaml llegó a GitHub
                    sleep 2
                    log_info "Verificando catalog-info.yaml en GitHub..."
                    
                    if curl -s -f "https://api.github.com/repos/giovanemere/$repo_name/contents/catalog-info.yaml?ref=$current_branch" > /dev/null 2>&1; then
                        log_success "catalog-info.yaml confirmado en GitHub"
                    else
                        log_warning "catalog-info.yaml aún no visible en GitHub (puede tomar unos segundos)"
                    fi
                else
                    log_error "Error al hacer push en $repo_name"
                fi
            fi
            
            # Mostrar status final
            echo "📊 Status final del repositorio:"
            git status --porcelain | head -5
            
        else
            log_error "No es un repositorio Git: $repo_path"
        fi
    else
        log_error "Repositorio no encontrado: $repo_path"
    fi
done

echo ""
log_info "=== VERIFICANDO DISPONIBILIDAD EN GITHUB ==="

# Esperar un poco para que GitHub procese los cambios
log_info "Esperando 10 segundos para que GitHub procese los cambios..."
sleep 10

# Verificar cada repositorio en GitHub
for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_path <<< "$repo_info"
    
    log_info "Verificando $repo_name en GitHub..."
    
    # Obtener branch del repositorio local
    if [ -d "$repo_path/.git" ]; then
        cd "$repo_path"
        current_branch=$(git branch --show-current)
        
        # Verificar catalog-info.yaml
        if curl -s -f "https://api.github.com/repos/giovanemere/$repo_name/contents/catalog-info.yaml?ref=$current_branch" > /dev/null 2>&1; then
            log_success "$repo_name: catalog-info.yaml disponible en GitHub"
        else
            log_warning "$repo_name: catalog-info.yaml no encontrado en GitHub"
        fi
        
        # Verificar docs/
        if curl -s -f "https://api.github.com/repos/giovanemere/$repo_name/contents/docs?ref=$current_branch" > /dev/null 2>&1; then
            log_success "$repo_name: directorio docs/ disponible en GitHub"
        else
            log_warning "$repo_name: directorio docs/ no encontrado en GitHub"
        fi
        
        # Verificar mkdocs.yml
        if curl -s -f "https://api.github.com/repos/giovanemere/$repo_name/contents/mkdocs.yml?ref=$current_branch" > /dev/null 2>&1; then
            log_success "$repo_name: mkdocs.yml disponible en GitHub"
        else
            log_warning "$repo_name: mkdocs.yml no encontrado en GitHub"
        fi
    fi
done

echo ""
log_info "=== ACTUALIZANDO CONFIGURACIÓN DE BACKSTAGE ==="

# Actualizar app-config.yaml con los branches correctos
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Crear configuración actualizada con branches correctos
cat > app-config-updated.yaml << 'EOF'
app:
  title: IA-OPS Developer Portal
  baseUrl: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}

organization:
  name: IA-OPS

backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET:-your-secret-key-here}
  baseUrl: http://localhost:${BACKSTAGE_BACKEND_PORT:-7007}
  listen:
    port: ${BACKSTAGE_BACKEND_PORT:-7007}
  csp:
    connect-src: ["'self'", 'http:', 'https:']
  cors:
    origin: http://localhost:${BACKSTAGE_FRONTEND_PORT:-3002}
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
      ssl: false

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
  cache:
    ttl: 3600000

auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location, Template, Domain, Group, User]
  
  locations:
    # Catálogo principal del proyecto
    - type: file
      target: ../../catalog-info.yaml
    
    # Templates y framework (submódulos locales)
    - type: file
      target: ../../catalog-templates.yaml
    - type: file
      target: ../../catalog-framework.yaml
    
    # Catálogo unificado
    - type: file
      target: ./catalog-unified.yaml
    
    # Repositorios externos (branch trunk)
    - type: url
      target: https://github.com/giovanemere/templates_backstage/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Template, Component, System]
    
    - type: url
      target: https://github.com/giovanemere/ia-ops-framework/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component, System, API, Resource]
    
    # Repositorios de aplicaciones (branch trunk)
    - type: url
      target: https://github.com/giovanemere/poc-billpay-back/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component, API]
    
    - type: url
      target: https://github.com/giovanemere/poc-billpay-front-a/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: url
      target: https://github.com/giovanemere/poc-billpay-front-b/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: url
      target: https://github.com/giovanemere/poc-billpay-front-feature-flags/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: url
      target: https://github.com/giovanemere/poc-icbs/blob/trunk/catalog-info.yaml
      rules:
        - allow: [Component, API]

proxy:
  '/openai':
    target: ${OPENAI_SERVICE_URL}
    changeOrigin: true
    headers:
      Authorization: Bearer ${OPENAI_API_KEY}
      
  '/proxy-health':
    target: http://proxy-service:8080/health
    changeOrigin: true

github-actions:
  proxyPath: /github-actions
  cache:
    ttl: 300000
  scheduler:
    frequency: { minutes: 5 }
    timeout: { minutes: 2 }

costInsights:
  engineerCost: 200000
  products:
    aws:
      name: AWS Services
      icon: cloud
    azure:
      name: Azure Services  
      icon: cloud
    gcp:
      name: GCP Services
      icon: cloud
    kubernetes:
      name: Kubernetes
      icon: compute
  metrics:
    - name: 'Daily Cost'
      default: true
    - name: 'Weekly Cost'
    - name: 'Monthly Cost'
  currencies:
    - label: 'USD ($)'
      unit: 'USD'
EOF

# Reemplazar configuración
mv app-config-updated.yaml app-config.yaml
log_success "Configuración de Backstage actualizada"

echo ""
log_info "=== RESUMEN DE PUSH ==="

echo "📊 Resultados del push:"
echo "   ✅ Repositorios con push exitoso: $success_count/$total_count"
echo "   📁 Archivos enviados a GitHub:"
echo "      • catalog-info.yaml"
echo "      • docs/ (directorio completo)"
echo "      • mkdocs.yml"

echo ""
echo "🎯 Estado de GitHub:"
for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_path <<< "$repo_info"
    echo "   📂 $repo_name: Verificar en https://github.com/giovanemere/$repo_name"
done

echo ""
echo "🚀 Próximos pasos:"
echo "1. Reiniciar Backstage: yarn start"
echo "2. Verificar que no hay warnings en logs"
echo "3. Confirmar que componentes aparecen en catálogo"
echo "4. Probar documentación automática"
echo "5. Verificar GitHub Actions integration"

if [ $success_count -eq $total_count ]; then
    echo ""
    log_success "¡Push completado exitosamente en todos los repositorios!"
else
    echo ""
    log_warning "Algunos repositorios tuvieron problemas con el push"
fi
EOF
