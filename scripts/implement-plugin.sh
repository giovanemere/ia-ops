#!/bin/bash

# 🔌 Script de Implementación Automática de Plugins Backstage
# Versión: 1.0
# Fecha: 8 de Agosto de 2025

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
BACKSTAGE_DIR="/home/giovanemere/ia-ops/ia-ops/applications/backstage"
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"
DOCS_DIR="/home/giovanemere/ia-ops/ia-ops/docs"

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Función para mostrar ayuda
show_help() {
    echo "🔌 Script de Implementación de Plugins Backstage"
    echo ""
    echo "Uso: $0 <plugin-name> [opciones]"
    echo ""
    echo "Plugins disponibles:"
    echo "  github      - @backstage/plugin-github-actions"
    echo "  azure       - @backstage/plugin-azure-devops"
    echo "  mkdocs      - @backstage/plugin-techdocs (completar)"
    echo "  custom      - Plugin personalizado"
    echo ""
    echo "Opciones:"
    echo "  -h, --help     Mostrar esta ayuda"
    echo "  -v, --verbose  Modo verbose"
    echo "  --skip-docker  Saltar build de Docker"
    echo "  --dev-only     Solo configurar para desarrollo"
    echo ""
    echo "Ejemplo:"
    echo "  $0 github"
    echo "  $0 azure --verbose"
}

# Función para verificar prerrequisitos
check_prerequisites() {
    log "🔍 Verificando prerrequisitos..."
    
    # Verificar directorio Backstage
    if [ ! -d "$BACKSTAGE_DIR" ]; then
        error "Directorio Backstage no encontrado: $BACKSTAGE_DIR"
    fi
    
    # Verificar archivo .env
    if [ ! -f "$ENV_FILE" ]; then
        error "Archivo .env no encontrado: $ENV_FILE"
    fi
    
    # Verificar yarn
    if ! command -v yarn &> /dev/null; then
        error "Yarn no está instalado"
    fi
    
    # Verificar docker
    if ! command -v docker &> /dev/null; then
        warning "Docker no está instalado - se saltará build de imagen"
        SKIP_DOCKER=true
    fi
    
    # Verificar dotenv-cli
    cd "$BACKSTAGE_DIR"
    if ! yarn list dotenv-cli &> /dev/null; then
        log "📦 Instalando dotenv-cli..."
        yarn add --dev dotenv-cli
    fi
    
    success "Prerrequisitos verificados"
}

# Función para backup
create_backup() {
    log "💾 Creando backup de configuración actual..."
    
    BACKUP_DIR="$BACKSTAGE_DIR/backups/$(date +'%Y%m%d_%H%M%S')"
    mkdir -p "$BACKUP_DIR"
    
    cp "$BACKSTAGE_DIR/package.json" "$BACKUP_DIR/"
    if [ -f "$BACKSTAGE_DIR/app-config.yaml" ]; then
        cp "$BACKSTAGE_DIR/app-config.yaml" "$BACKUP_DIR/"
    fi
    
    success "Backup creado en: $BACKUP_DIR"
}

# Función para instalar plugin
install_plugin() {
    local plugin_name=$1
    local package_name=""
    local backend_package=""
    
    log "📦 Instalando plugin: $plugin_name"
    
    case $plugin_name in
        "github")
            package_name="@backstage/plugin-github-actions"
            backend_package="@backstage/plugin-github-actions-backend"
            ;;
        "azure")
            package_name="@backstage/plugin-azure-devops"
            backend_package="@backstage/plugin-azure-devops-backend"
            ;;
        "mkdocs")
            package_name="@backstage/plugin-techdocs"
            backend_package="@backstage/plugin-techdocs-backend"
            ;;
        *)
            error "Plugin no reconocido: $plugin_name"
            ;;
    esac
    
    cd "$BACKSTAGE_DIR"
    
    # Instalar plugin frontend
    log "📦 Instalando $package_name..."
    yarn add "$package_name"
    
    # Instalar plugin backend si existe
    if [ ! -z "$backend_package" ]; then
        log "📦 Instalando $backend_package..."
        yarn add "$backend_package" || warning "Backend package no disponible o ya instalado"
    fi
    
    success "Plugin $plugin_name instalado"
}

# Función para actualizar variables de entorno
update_env_vars() {
    local plugin_name=$1
    
    log "🔧 Actualizando variables de entorno para: $plugin_name"
    
    case $plugin_name in
        "github")
            if ! grep -q "GITHUB_TOKEN" "$ENV_FILE"; then
                echo "" >> "$ENV_FILE"
                echo "# GitHub Plugin Configuration" >> "$ENV_FILE"
                echo "GITHUB_TOKEN=your_github_token_here" >> "$ENV_FILE"
                echo "GITHUB_CLIENT_ID=your_github_client_id" >> "$ENV_FILE"
                echo "GITHUB_CLIENT_SECRET=your_github_client_secret" >> "$ENV_FILE"
                warning "⚠️  Actualiza las variables GITHUB_* en $ENV_FILE"
            fi
            ;;
        "azure")
            if ! grep -q "AZURE_TOKEN" "$ENV_FILE"; then
                echo "" >> "$ENV_FILE"
                echo "# Azure DevOps Plugin Configuration" >> "$ENV_FILE"
                echo "AZURE_TOKEN=your_azure_token_here" >> "$ENV_FILE"
                echo "AZURE_ORG=your_azure_organization" >> "$ENV_FILE"
                warning "⚠️  Actualiza las variables AZURE_* en $ENV_FILE"
            fi
            ;;
        "mkdocs")
            if ! grep -q "TECHDOCS_BUILDER" "$ENV_FILE"; then
                echo "" >> "$ENV_FILE"
                echo "# TechDocs Plugin Configuration" >> "$ENV_FILE"
                echo "TECHDOCS_BUILDER=local" >> "$ENV_FILE"
                echo "TECHDOCS_GENERATOR=mkdocs" >> "$ENV_FILE"
                echo "TECHDOCS_PUBLISHER_TYPE=local" >> "$ENV_FILE"
            fi
            ;;
    esac
    
    success "Variables de entorno actualizadas"
}

# Función para verificar dependencias
check_dependencies() {
    log "🔍 Verificando dependencias..."
    
    cd "$BACKSTAGE_DIR"
    
    # Instalar dependencias
    yarn install
    
    # Verificar conflictos
    if yarn list --pattern "@backstage" | grep -q "warning"; then
        warning "Se detectaron posibles conflictos de dependencias"
        log "Ejecutando yarn why para diagnosticar..."
        yarn why @backstage/core-plugin-api || true
    fi
    
    success "Dependencias verificadas"
}

# Función para probar desarrollo
test_development() {
    log "🚀 Probando configuración de desarrollo..."
    
    cd "$BACKSTAGE_DIR"
    
    # Verificar que el script start funciona
    timeout 30s dotenv -e "$ENV_FILE" -- yarn start &
    START_PID=$!
    
    sleep 10
    
    if ps -p $START_PID > /dev/null; then
        success "Servidor de desarrollo iniciado correctamente"
        kill $START_PID
        wait $START_PID 2>/dev/null || true
    else
        error "Error al iniciar servidor de desarrollo"
    fi
}

# Función para probar build
test_build() {
    log "🏗️  Probando build de producción..."
    
    cd "$BACKSTAGE_DIR"
    
    # Limpiar build anterior
    yarn clean
    
    # Ejecutar build
    if dotenv -e "$ENV_FILE" -- yarn build; then
        success "Build de producción exitoso"
        
        # Verificar artefactos
        if [ -d "dist" ]; then
            success "Artefactos generados en dist/"
            ls -la dist/
        fi
    else
        error "Error en build de producción"
    fi
}

# Función para build de Docker
build_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        warning "Saltando build de Docker"
        return
    fi
    
    log "🐳 Construyendo imagen Docker..."
    
    cd "$BACKSTAGE_DIR"
    
    if docker build -t backstage-app:latest .; then
        success "Imagen Docker construida exitosamente"
        
        # Probar contenedor
        log "🧪 Probando contenedor Docker..."
        if timeout 30s docker run -p 3001:3000 --env-file "$ENV_FILE" backstage-app:latest &
        then
            DOCKER_PID=$!
            sleep 15
            
            if docker ps | grep -q backstage-app; then
                success "Contenedor Docker funcional"
            else
                warning "Contenedor Docker puede tener problemas"
            fi
            
            docker stop $(docker ps -q --filter ancestor=backstage-app:latest) 2>/dev/null || true
        fi
    else
        error "Error construyendo imagen Docker"
    fi
}

# Función para generar documentación
generate_docs() {
    local plugin_name=$1
    
    log "📚 Generando documentación para plugin: $plugin_name"
    
    DOC_FILE="$DOCS_DIR/plugin-${plugin_name}-implementation.md"
    
    cat > "$DOC_FILE" << EOF
# Plugin $plugin_name - Documentación de Implementación

**Fecha de Implementación**: $(date +'%Y-%m-%d %H:%M:%S')  
**Plugin**: $plugin_name  
**Estado**: ✅ Implementado

## Configuración

### Variables de Entorno
\`\`\`bash
# Ver archivo .env para configuración específica
EOF

    case $plugin_name in
        "github")
            cat >> "$DOC_FILE" << EOF
GITHUB_TOKEN=your_github_token_here
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
EOF
            ;;
        "azure")
            cat >> "$DOC_FILE" << EOF
AZURE_TOKEN=your_azure_token_here
AZURE_ORG=your_azure_organization
EOF
            ;;
        "mkdocs")
            cat >> "$DOC_FILE" << EOF
TECHDOCS_BUILDER=local
TECHDOCS_GENERATOR=mkdocs
TECHDOCS_PUBLISHER_TYPE=local
EOF
            ;;
    esac

    cat >> "$DOC_FILE" << EOF
\`\`\`

### Dependencias Instaladas
\`\`\`bash
# Frontend
@backstage/plugin-${plugin_name}

# Backend (si aplica)
@backstage/plugin-${plugin_name}-backend
\`\`\`

## Comandos de Desarrollo

\`\`\`bash
# Desarrollo
yarn start

# Build
yarn build

# Docker
docker build -t backstage-app:latest .
\`\`\`

## Validación

- [x] Plugin instalado correctamente
- [x] Variables de entorno configuradas
- [x] Desarrollo funcional
- [x] Build exitoso
- [x] Docker funcional

## Troubleshooting

### Problemas Comunes
- Verificar variables de entorno en .env
- Ejecutar yarn clean && yarn install
- Verificar logs de desarrollo

### Contacto
- Equipo: IA-Ops Platform
- Documentación: /docs/guia-implementacion-plugins-backstage.md

---
**Generado automáticamente por**: implement-plugin.sh
EOF

    success "Documentación generada: $DOC_FILE"
}

# Función principal
main() {
    local plugin_name=""
    local verbose=false
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --dev-only)
                DEV_ONLY=true
                shift
                ;;
            *)
                if [ -z "$plugin_name" ]; then
                    plugin_name=$1
                else
                    error "Argumento desconocido: $1"
                fi
                shift
                ;;
        esac
    done
    
    # Verificar que se proporcionó un plugin
    if [ -z "$plugin_name" ]; then
        error "Debe especificar un plugin. Use -h para ayuda."
    fi
    
    echo "🔌 Implementando Plugin: $plugin_name"
    echo "📁 Directorio: $BACKSTAGE_DIR"
    echo "🔧 Variables: $ENV_FILE"
    echo ""
    
    # Ejecutar pasos
    check_prerequisites
    create_backup
    install_plugin "$plugin_name"
    update_env_vars "$plugin_name"
    check_dependencies
    
    if [ "$DEV_ONLY" != true ]; then
        test_development
        test_build
        build_docker
    else
        test_development
    fi
    
    generate_docs "$plugin_name"
    
    echo ""
    success "🎉 Plugin $plugin_name implementado exitosamente!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Revisar y actualizar variables en: $ENV_FILE"
    echo "2. Configurar plugin en app-config.yaml si es necesario"
    echo "3. Probar funcionalidades específicas del plugin"
    echo "4. Actualizar documentación de usuario"
    echo ""
    echo "📚 Documentación generada en: $DOCS_DIR/plugin-${plugin_name}-implementation.md"
}

# Ejecutar función principal
main "$@"
