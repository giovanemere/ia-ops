#!/bin/bash

# =============================================================================
# BACKSTAGE PREREQUISITES VALIDATOR
# =============================================================================
# Fecha: 8 de Agosto de 2025
# Versión: 1.0.0
# Descripción: Validador completo de prerequisitos para Backstage
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
ERRORS=0
WARNINGS=0

echo -e "${BLUE}🔍 BACKSTAGE PREREQUISITES VALIDATOR${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

# Función para verificar versión
check_version() {
    local tool=$1
    local current=$2
    local required=$3
    local comparison=$4
    
    if command -v $tool >/dev/null 2>&1; then
        if [[ "$comparison" == "min" ]]; then
            if [[ $(echo -e "$current\n$required" | sort -V | head -n1) == "$required" ]]; then
                log_success "$tool version $current (>= $required required)"
                return 0
            else
                log_error "$tool version $current is below required $required"
                return 1
            fi
        elif [[ "$comparison" == "exact" ]]; then
            if [[ "$current" == "$required" ]]; then
                log_success "$tool version $current (exact match)"
                return 0
            else
                log_warning "$tool version $current (recommended: $required)"
                return 0
            fi
        fi
    else
        log_error "$tool is not installed"
        return 1
    fi
}

# 1. Verificar Node.js
log_info "Checking Node.js..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version | sed 's/v//')
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
    
    if [[ $NODE_MAJOR -ge 18 && $NODE_MAJOR -le 22 ]]; then
        log_success "Node.js version $NODE_VERSION (supported: 18, 20, 22)"
    else
        log_error "Node.js version $NODE_VERSION not supported. Required: 18, 20, or 22"
    fi
else
    log_error "Node.js is not installed"
fi

# 2. Verificar Yarn
log_info "Checking Yarn..."
if command -v yarn >/dev/null 2>&1; then
    YARN_VERSION=$(yarn --version)
    YARN_MAJOR=$(echo $YARN_VERSION | cut -d. -f1)
    
    if [[ $YARN_MAJOR -ge 3 ]]; then
        log_success "Yarn version $YARN_VERSION (>= 3.0 required)"
    else
        log_error "Yarn version $YARN_VERSION is too old. Required: >= 3.0"
    fi
else
    log_error "Yarn is not installed"
fi

# 3. Verificar Docker
log_info "Checking Docker..."
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    check_version "docker" "$DOCKER_VERSION" "20.10.0" "min"
    
    # Verificar que Docker esté corriendo
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon is running"
    else
        log_error "Docker daemon is not running"
    fi
else
    log_error "Docker is not installed"
fi

# 4. Verificar Docker Compose
log_info "Checking Docker Compose..."
if docker compose version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    check_version "docker compose" "$COMPOSE_VERSION" "2.0.0" "min"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    check_version "docker-compose" "$COMPOSE_VERSION" "2.0.0" "min"
else
    log_error "Docker Compose is not installed"
fi

# 5. Verificar Git
log_info "Checking Git..."
if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    check_version "git" "$GIT_VERSION" "2.20.0" "min"
else
    log_error "Git is not installed"
fi

# 6. Verificar Python (necesario para compilar dependencias nativas)
log_info "Checking Python..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    check_version "python3" "$PYTHON_VERSION" "3.8.0" "min"
else
    log_warning "Python3 is not installed (may be needed for native dependencies)"
fi

# 7. Verificar herramientas de compilación
log_info "Checking build tools..."
if command -v make >/dev/null 2>&1; then
    log_success "make is available"
else
    log_warning "make is not installed (may be needed for native dependencies)"
fi

if command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1; then
    log_success "C compiler is available"
else
    log_warning "C compiler not found (may be needed for native dependencies)"
fi

# 8. Verificar memoria disponible
log_info "Checking system resources..."
if command -v free >/dev/null 2>&1; then
    MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $MEMORY_GB -ge 4 ]]; then
        log_success "Available memory: ${MEMORY_GB}GB (>= 4GB recommended)"
    else
        log_warning "Available memory: ${MEMORY_GB}GB (4GB+ recommended for Backstage build)"
    fi
fi

# 9. Verificar espacio en disco
DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [[ $DISK_SPACE -ge 10 ]]; then
    log_success "Available disk space: ${DISK_SPACE}GB (>= 10GB recommended)"
else
    log_warning "Available disk space: ${DISK_SPACE}GB (10GB+ recommended)"
fi

# 10. Verificar estructura de archivos de Backstage
log_info "Checking Backstage project structure..."
BACKSTAGE_DIR="/home/giovanemere/ia-ops/ia-ops/applications/backstage"

if [[ -f "$BACKSTAGE_DIR/package.json" ]]; then
    log_success "package.json found"
else
    log_error "package.json not found in $BACKSTAGE_DIR"
fi

if [[ -f "$BACKSTAGE_DIR/yarn.lock" ]]; then
    log_success "yarn.lock found"
else
    log_error "yarn.lock not found in $BACKSTAGE_DIR"
fi

if [[ -f "$BACKSTAGE_DIR/app-config.yaml" ]]; then
    log_success "app-config.yaml found"
else
    log_error "app-config.yaml not found in $BACKSTAGE_DIR"
fi

if [[ -d "$BACKSTAGE_DIR/packages" ]]; then
    log_success "packages directory found"
    
    if [[ -d "$BACKSTAGE_DIR/packages/app" ]]; then
        log_success "packages/app directory found"
    else
        log_error "packages/app directory not found"
    fi
    
    if [[ -d "$BACKSTAGE_DIR/packages/backend" ]]; then
        log_success "packages/backend directory found"
    else
        log_error "packages/backend directory not found"
    fi
else
    log_error "packages directory not found in $BACKSTAGE_DIR"
fi

# 11. Verificar variables de entorno
log_info "Checking environment variables..."
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

if [[ -f "$ENV_FILE" ]]; then
    log_success ".env file found"
    
    # Verificar variables críticas
    if grep -q "BACKEND_SECRET" "$ENV_FILE"; then
        log_success "BACKEND_SECRET is configured"
    else
        log_error "BACKEND_SECRET not found in .env"
    fi
    
    if grep -q "POSTGRES_" "$ENV_FILE"; then
        log_success "PostgreSQL configuration found"
    else
        log_warning "PostgreSQL configuration may be missing"
    fi
else
    log_error ".env file not found"
fi

# 12. Verificar conectividad de red (para descargar dependencias)
log_info "Checking network connectivity..."
if ping -c 1 registry.npmjs.org >/dev/null 2>&1; then
    log_success "NPM registry is accessible"
else
    log_warning "Cannot reach NPM registry (may affect dependency installation)"
fi

if ping -c 1 registry.yarnpkg.com >/dev/null 2>&1; then
    log_success "Yarn registry is accessible"
else
    log_warning "Cannot reach Yarn registry (may affect dependency installation)"
fi

# Resumen final
echo ""
echo -e "${BLUE}📊 VALIDATION SUMMARY${NC}"
echo -e "${BLUE}===================${NC}"

if [[ $ERRORS -eq 0 ]]; then
    log_success "All critical requirements are met!"
    if [[ $WARNINGS -gt 0 ]]; then
        log_warning "$WARNINGS warning(s) found - build may still succeed"
    fi
    echo ""
    echo -e "${GREEN}🚀 Ready to proceed with Backstage build!${NC}"
    exit 0
else
    log_error "$ERRORS critical error(s) found"
    if [[ $WARNINGS -gt 0 ]]; then
        log_warning "$WARNINGS warning(s) found"
    fi
    echo ""
    echo -e "${RED}🛑 Please fix the errors before proceeding with build${NC}"
    exit 1
fi
