#!/bin/bash

# =============================================================================
# SCRIPT PARA DESPLEGAR DOCUMENTACIÓN AUTOMÁTICA A REPOSITORIOS
# =============================================================================
# Descripción: Despliega catalog-info.yaml, mkdocs.yml y docs básicos
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

echo "🚀 Desplegando documentación automática a repositorios..."

# Verificar que tenemos los archivos necesarios
if [ ! -f "catalog-template.yaml" ]; then
    log_error "No se encontró catalog-template.yaml"
    exit 1
fi

if [ ! -f "mkdocs-template.yml" ]; then
    log_error "No se encontró mkdocs-template.yml"
    exit 1
fi

# Repositorios a configurar
declare -A REPOS=(
    ["poc-billpay-back"]="Backend service for billpay application"
    ["poc-billpay-front-a"]="Frontend A for billpay application"
    ["poc-billpay-front-b"]="Frontend B for billpay application"
    ["poc-billpay-front-feature-flags"]="Feature flags frontend for billpay"
    ["poc-icbs"]="ICBS integration service"
)

# Crear directorio temporal
TEMP_DIR="./repo-docs"
mkdir -p "$TEMP_DIR"

echo ""
log_info "=== GENERANDO ARCHIVOS DE DOCUMENTACIÓN ==="

for repo_name in "${!REPOS[@]}"; do
    repo_desc="${REPOS[$repo_name]}"
    
    log_info "Procesando $repo_name..."
    
    # Crear directorio para el repo
    repo_dir="$TEMP_DIR/$repo_name"
    mkdir -p "$repo_dir/docs"
    
    # Generar catalog-info.yaml
    sed "s/COMPONENT_NAME/$repo_name/g; s/COMPONENT_DESCRIPTION/$repo_desc/g; s/REPO_NAME/$repo_name/g" \
        catalog-template.yaml > "$repo_dir/catalog-info.yaml"
    
    # Generar mkdocs.yml
    sed "s/COMPONENT_NAME/$repo_name/g; s/REPO_NAME/$repo_name/g" \
        mkdocs-template.yml > "$repo_dir/mkdocs.yml"
    
    # Generar documentación básica
    cat > "$repo_dir/docs/index.md" << EOF
# $repo_name

$repo_desc

## Descripción

Este componente es parte de la plataforma IA-Ops y proporciona funcionalidades específicas para el ecosistema de aplicaciones.

## Arquitectura

\`\`\`mermaid
graph TD
    A[Usuario] --> B[$repo_name]
    B --> C[Base de Datos]
    B --> D[Servicios Externos]
\`\`\`

## API

Para más detalles sobre la API, consulta [api.md](api.md).

## Despliegue

Para información sobre despliegue, consulta [deployment.md](deployment.md).

## Enlaces

- [Repositorio](https://github.com/giovanemere/$repo_name)
- [GitHub Actions](https://github.com/giovanemere/$repo_name/actions)
- [Issues](https://github.com/giovanemere/$repo_name/issues)
EOF

    # Generar documentación de API
    cat > "$repo_dir/docs/api.md" << EOF
# API Documentation

## Endpoints

### Health Check

\`\`\`
GET /health
\`\`\`

Retorna el estado de salud del servicio.

**Respuesta:**
\`\`\`json
{
  "status": "ok",
  "timestamp": "2025-08-11T06:00:00Z"
}
\`\`\`

## Autenticación

Describe aquí los métodos de autenticación utilizados.

## Ejemplos

Incluye ejemplos de uso de la API.
EOF

    # Generar documentación de despliegue
    cat > "$repo_dir/docs/deployment.md" << EOF
# Deployment Guide

## Prerrequisitos

- Docker
- Kubernetes (opcional)
- Variables de entorno configuradas

## Despliegue Local

\`\`\`bash
# Clonar repositorio
git clone https://github.com/giovanemere/$repo_name.git
cd $repo_name

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev
\`\`\`

## Despliegue en Kubernetes

\`\`\`bash
# Aplicar manifiestos
kubectl apply -f k8s/
\`\`\`

## Variables de Entorno

| Variable | Descripción | Requerida |
|----------|-------------|-----------|
| PORT | Puerto del servicio | No |
| NODE_ENV | Entorno de ejecución | Sí |

## Monitoreo

El servicio expone métricas en \`/metrics\` para Prometheus.
EOF

    # Generar documentación de arquitectura
    cat > "$repo_dir/docs/architecture.md" << EOF
# Architecture

## Visión General

$repo_desc forma parte del ecosistema IA-Ops y sigue los patrones arquitectónicos establecidos.

## Componentes

### Core Components

- **Controller Layer**: Maneja las peticiones HTTP
- **Service Layer**: Lógica de negocio
- **Data Layer**: Acceso a datos

### Dependencies

- Base de datos
- Servicios externos
- Cache (Redis)

## Patrones de Diseño

- Repository Pattern
- Dependency Injection
- Event-Driven Architecture

## Diagramas

\`\`\`mermaid
graph TB
    subgraph "Frontend"
        UI[User Interface]
    end
    
    subgraph "Backend"
        API[API Gateway]
        SVC[Service Layer]
        DB[(Database)]
    end
    
    UI --> API
    API --> SVC
    SVC --> DB
\`\`\`
EOF

    log_success "Archivos generados para $repo_name"
done

echo ""
log_info "=== RESUMEN DE ARCHIVOS GENERADOS ==="

for repo_name in "${!REPOS[@]}"; do
    echo "📁 $repo_name:"
    echo "   ├── catalog-info.yaml"
    echo "   ├── mkdocs.yml"
    echo "   └── docs/"
    echo "       ├── index.md"
    echo "       ├── api.md"
    echo "       ├── deployment.md"
    echo "       └── architecture.md"
done

echo ""
log_info "=== INSTRUCCIONES DE DESPLIEGUE ==="

echo "🔧 Para desplegar a cada repositorio:"
echo ""
for repo_name in "${!REPOS[@]}"; do
    echo "📦 $repo_name:"
    echo "   1. cd $TEMP_DIR/$repo_name"
    echo "   2. Copiar archivos al repositorio correspondiente"
    echo "   3. git add . && git commit -m 'Add Backstage documentation'"
    echo "   4. git push origin trunk"
    echo ""
done

echo "🎯 Funcionalidades habilitadas después del despliegue:"
echo "   📖 TechDocs: Documentación automática"
echo "   👁️  View Source: Enlaces directos a GitHub"
echo "   🔄 CI/CD: Integración con GitHub Actions"
echo "   🤖 GitHub Actions: Workflows visibles"
echo "   📊 Métricas: Monitoreo integrado"

echo ""
log_success "¡Documentación generada exitosamente!"
log_info "Archivos disponibles en: $TEMP_DIR/"
