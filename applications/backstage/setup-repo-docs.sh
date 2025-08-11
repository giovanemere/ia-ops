#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR DOCUMENTACIÓN EN REPOSITORIOS
# =============================================================================

set -e

echo "📚 Configurando documentación básica para repositorios..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Crear estructura de documentación para cada repositorio
REPOS=(
    "poc-billpay-back:Backend service for billpay application:Backend API service that handles payment processing and business logic"
    "poc-billpay-front-a:Frontend A for billpay application:React frontend application for bill payment interface (Version A)"
    "poc-billpay-front-b:Frontend B for billpay application:React frontend application for bill payment interface (Version B)"
    "poc-billpay-front-feature-flags:Feature flags frontend for billpay:Frontend with feature flags implementation for A/B testing"
    "poc-icbs:ICBS integration service:Integration service for ICBS (Integrated Core Banking System)"
)

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_desc repo_long_desc <<< "$repo_info"
    
    echo ""
    log_info "=== Configurando documentación para $repo_name ==="
    
    # Crear directorio para el repositorio
    mkdir -p "repo-docs/$repo_name/docs"
    
    # Crear index.md
    cat > "repo-docs/$repo_name/docs/index.md" << EOF
# $repo_name

$repo_long_desc

## 📋 Descripción

$repo_desc

## 🏗️ Arquitectura

\`\`\`mermaid
graph TD
    A[Cliente] --> B[Frontend]
    B --> C[API Gateway]
    C --> D[Backend Service]
    D --> E[Base de Datos]
\`\`\`

## 🚀 Inicio Rápido

### Prerrequisitos
- Node.js 18+
- npm o yarn
- Git

### Instalación
\`\`\`bash
git clone https://github.com/giovanemere/$repo_name.git
cd $repo_name
npm install
\`\`\`

### Desarrollo
\`\`\`bash
npm run dev
\`\`\`

## 📚 API Documentation

### Endpoints Principales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET    | /health  | Health check |
| GET    | /api/v1  | API version |

## 🔧 Configuración

### Variables de Entorno
\`\`\`bash
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://localhost:5432/db
\`\`\`

## 🧪 Testing

\`\`\`bash
npm test
npm run test:coverage
\`\`\`

## 🚀 Despliegue

### Docker
\`\`\`bash
docker build -t $repo_name .
docker run -p 3000:3000 $repo_name
\`\`\`

### Kubernetes
\`\`\`bash
kubectl apply -f k8s/
\`\`\`

## 📊 Monitoreo

- **Métricas**: Prometheus
- **Logs**: ELK Stack
- **Alertas**: Grafana

## 🤝 Contribución

1. Fork del repositorio
2. Crear rama feature (\`git checkout -b feature/nueva-funcionalidad\`)
3. Commit cambios (\`git commit -am 'Añadir nueva funcionalidad'\`)
4. Push a la rama (\`git push origin feature/nueva-funcionalidad\`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
EOF

    # Crear api.md
    cat > "repo-docs/$repo_name/docs/api.md" << EOF
# API Documentation - $repo_name

## 📋 Descripción de la API

API RESTful para $repo_desc

## 🔗 Base URL

\`\`\`
https://api.example.com/v1
\`\`\`

## 🔐 Autenticación

\`\`\`bash
Authorization: Bearer <token>
\`\`\`

## 📚 Endpoints

### Health Check

\`\`\`http
GET /health
\`\`\`

**Respuesta:**
\`\`\`json
{
  "status": "ok",
  "timestamp": "2025-08-11T05:00:00Z",
  "version": "1.0.0"
}
\`\`\`

### API Info

\`\`\`http
GET /api/v1
\`\`\`

**Respuesta:**
\`\`\`json
{
  "name": "$repo_name",
  "version": "1.0.0",
  "description": "$repo_desc"
}
\`\`\`

## 📊 Códigos de Estado

| Código | Descripción |
|--------|-------------|
| 200    | OK |
| 201    | Created |
| 400    | Bad Request |
| 401    | Unauthorized |
| 404    | Not Found |
| 500    | Internal Server Error |

## 🧪 Ejemplos

### cURL
\`\`\`bash
curl -X GET https://api.example.com/v1/health
\`\`\`

### JavaScript
\`\`\`javascript
fetch('https://api.example.com/v1/health')
  .then(response => response.json())
  .then(data => console.log(data));
\`\`\`
EOF

    # Crear architecture.md
    cat > "repo-docs/$repo_name/docs/architecture.md" << EOF
# Arquitectura - $repo_name

## 🏗️ Visión General

$repo_long_desc

## 📊 Diagrama de Arquitectura

\`\`\`mermaid
graph TB
    subgraph "Frontend Layer"
        UI[User Interface]
        STATE[State Management]
    end
    
    subgraph "API Layer"
        API[REST API]
        AUTH[Authentication]
        VALID[Validation]
    end
    
    subgraph "Business Layer"
        BL[Business Logic]
        SERV[Services]
    end
    
    subgraph "Data Layer"
        DB[(Database)]
        CACHE[(Cache)]
    end
    
    UI --> STATE
    STATE --> API
    API --> AUTH
    API --> VALID
    VALID --> BL
    BL --> SERV
    SERV --> DB
    SERV --> CACHE
\`\`\`

## 🔧 Componentes

### Frontend
- **Framework**: React/Vue/Angular
- **State Management**: Redux/Vuex/NgRx
- **Routing**: React Router/Vue Router/Angular Router

### Backend
- **Framework**: Express.js/Fastify/NestJS
- **Authentication**: JWT/OAuth2
- **Validation**: Joi/Yup/class-validator

### Base de Datos
- **Tipo**: PostgreSQL/MySQL/MongoDB
- **ORM**: Prisma/TypeORM/Mongoose
- **Migraciones**: Automáticas

### Cache
- **Redis**: Para sesiones y cache
- **Memoria**: Para datos frecuentes

## 🔄 Flujo de Datos

1. **Request**: Cliente envía petición
2. **Authentication**: Verificación de credenciales
3. **Validation**: Validación de datos
4. **Business Logic**: Procesamiento de negocio
5. **Data Access**: Acceso a base de datos
6. **Response**: Respuesta al cliente

## 🛡️ Seguridad

- **HTTPS**: Comunicación encriptada
- **JWT**: Tokens de autenticación
- **CORS**: Control de acceso
- **Rate Limiting**: Limitación de requests
- **Input Validation**: Validación de entrada

## 📈 Escalabilidad

- **Horizontal**: Múltiples instancias
- **Load Balancer**: Distribución de carga
- **Database Sharding**: Particionado de datos
- **Caching**: Optimización de performance

## 🔍 Monitoreo

- **Logs**: Structured logging
- **Metrics**: Prometheus/Grafana
- **Tracing**: Jaeger/Zipkin
- **Health Checks**: Endpoints de salud
EOF

    # Crear deployment.md
    cat > "repo-docs/$repo_name/docs/deployment.md" << EOF
# Despliegue - $repo_name

## 🚀 Estrategias de Despliegue

### Desarrollo Local

\`\`\`bash
# Clonar repositorio
git clone https://github.com/giovanemere/$repo_name.git
cd $repo_name

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env

# Iniciar en modo desarrollo
npm run dev
\`\`\`

### Docker

#### Dockerfile
\`\`\`dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
\`\`\`

#### Docker Compose
\`\`\`yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: $repo_name
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
\`\`\`

### Kubernetes

#### Deployment
\`\`\`yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $repo_name
spec:
  replicas: 3
  selector:
    matchLabels:
      app: $repo_name
  template:
    metadata:
      labels:
        app: $repo_name
    spec:
      containers:
      - name: $repo_name
        image: $repo_name:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
\`\`\`

#### Service
\`\`\`yaml
apiVersion: v1
kind: Service
metadata:
  name: $repo_name-service
spec:
  selector:
    app: $repo_name
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
\`\`\`

## 🔄 CI/CD Pipeline

### GitHub Actions
\`\`\`yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '18'
    - run: npm ci
    - run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build Docker image
      run: docker build -t $repo_name .
    - name: Push to registry
      run: docker push $repo_name
\`\`\`

## 🌍 Ambientes

### Desarrollo
- **URL**: http://localhost:3000
- **Base de Datos**: Local PostgreSQL
- **Logs**: Console

### Staging
- **URL**: https://staging-$repo_name.example.com
- **Base de Datos**: Staging PostgreSQL
- **Logs**: ELK Stack

### Producción
- **URL**: https://$repo_name.example.com
- **Base de Datos**: Production PostgreSQL (HA)
- **Logs**: ELK Stack + Alerting

## 📊 Monitoreo Post-Despliegue

### Health Checks
\`\`\`bash
curl https://$repo_name.example.com/health
\`\`\`

### Métricas
- **CPU**: < 70%
- **Memoria**: < 80%
- **Response Time**: < 200ms
- **Error Rate**: < 1%

### Alertas
- **Downtime**: > 1 minuto
- **High CPU**: > 80%
- **High Memory**: > 90%
- **Error Rate**: > 5%
EOF

    # Crear mkdocs.yml
    cat > "repo-docs/$repo_name/mkdocs.yml" << EOF
site_name: '$repo_name Documentation'
site_description: 'Documentación automática generada por Backstage TechDocs'
site_url: 'https://github.com/giovanemere/$repo_name'

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
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate

markdown_extensions:
  - admonition
  - codehilite
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:mermaid2.fence_mermaid
  - pymdownx.tabbed
  - pymdownx.details
  - toc:
      permalink: true

repo_url: https://github.com/giovanemere/$repo_name
repo_name: giovanemere/$repo_name
edit_uri: edit/main/docs/

extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/giovanemere/$repo_name
EOF

    # Copiar catalog-info.yaml
    cp "catalog-$repo_name.yaml" "repo-docs/$repo_name/catalog-info.yaml"
    
    log_success "Documentación configurada para $repo_name"
done

echo ""
log_info "=== CREANDO SCRIPT DE DESPLIEGUE ==="

# Crear script para copiar archivos a repositorios
cat > deploy-docs-to-repos.sh << 'EOF'
#!/bin/bash

echo "🚀 Desplegando documentación a repositorios..."

REPOS=(
    "poc-billpay-back"
    "poc-billpay-front-a"
    "poc-billpay-front-b"
    "poc-billpay-front-feature-flags"
    "poc-icbs"
)

for repo in "${REPOS[@]}"; do
    echo ""
    echo "📁 Procesando $repo..."
    
    if [ -d "../../../$repo" ]; then
        echo "✅ Repositorio local encontrado: $repo"
        
        # Copiar archivos
        cp -r "repo-docs/$repo/docs" "../../../$repo/"
        cp "repo-docs/$repo/mkdocs.yml" "../../../$repo/"
        cp "repo-docs/$repo/catalog-info.yaml" "../../../$repo/"
        
        echo "✅ Archivos copiados a $repo"
    else
        echo "⚠️  Repositorio local no encontrado: $repo"
        echo "   Archivos disponibles en: repo-docs/$repo/"
    fi
done

echo ""
echo "🎯 Documentación lista para commit y push a GitHub"
echo ""
echo "📋 Próximos pasos por repositorio:"
echo "1. cd ../$repo"
echo "2. git add docs/ mkdocs.yml catalog-info.yaml"
echo "3. git commit -m 'Add Backstage documentation and catalog'"
echo "4. git push origin main"
EOF

chmod +x deploy-docs-to-repos.sh

log_success "Script de despliegue creado"

echo ""
log_info "=== RESUMEN DE CONFIGURACIÓN ==="

echo "📚 Documentación creada para repositorios:"
for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name repo_desc repo_long_desc <<< "$repo_info"
    echo "   ✅ $repo_name"
done

echo ""
echo "📁 Estructura creada:"
echo "   📂 repo-docs/"
echo "   ├── 📂 [repo-name]/"
echo "   │   ├── 📂 docs/"
echo "   │   │   ├── 📄 index.md"
echo "   │   │   ├── 📄 api.md"
echo "   │   │   ├── 📄 architecture.md"
echo "   │   │   └── 📄 deployment.md"
echo "   │   ├── 📄 mkdocs.yml"
echo "   │   └── 📄 catalog-info.yaml"

echo ""
echo "🚀 Próximos pasos:"
echo "1. Revisar documentación generada: ls -la repo-docs/"
echo "2. Ejecutar: ./deploy-docs-to-repos.sh"
echo "3. Hacer commit y push en cada repositorio"
echo "4. Reiniciar Backstage para ver cambios"

echo ""
log_success "¡Configuración de documentación completada!"
EOF
