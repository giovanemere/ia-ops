#!/bin/bash

# =============================================================================
# SOLUCIÓN ALTERNATIVA - BACKSTAGE RÁPIDO
# =============================================================================
# Descripción: Usar Backstage con desarrollo local en lugar de Docker
# Tiempo estimado: 10 minutos

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 SOLUCIÓN ALTERNATIVA - BACKSTAGE NATIVO${NC}"
echo -e "${YELLOW}⏰ Tiempo estimado: 10 minutos${NC}"
echo ""

# Paso 1: Verificar Node.js y Yarn
echo -e "${BLUE}📋 Paso 1: Verificando dependencias...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    exit 1
fi

if ! command -v yarn &> /dev/null; then
    echo -e "${RED}❌ Yarn no está instalado${NC}"
    exit 1
fi

NODE_VERSION=$(node --version)
YARN_VERSION=$(yarn --version)
echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
echo -e "${GREEN}✅ Yarn: $YARN_VERSION${NC}"

# Paso 2: Iniciar servicios básicos
echo -e "${BLUE}📋 Paso 2: Iniciando servicios básicos...${NC}"
docker-compose up -d postgres redis

# Esperar a que los servicios estén listos
echo -e "${YELLOW}⏳ Esperando servicios básicos (30 segundos)...${NC}"
sleep 30

# Verificar servicios
if ! docker-compose ps | grep -q "Up (healthy)"; then
    echo -e "${RED}❌ Servicios básicos no están funcionando${NC}"
    docker-compose logs postgres redis
    exit 1
fi

echo -e "${GREEN}✅ Servicios básicos funcionando${NC}"

# Paso 3: Configurar Backstage para desarrollo local
echo -e "${BLUE}📋 Paso 3: Configurando Backstage para desarrollo local...${NC}"

cd applications/backstage

# Instalar dependencias si no existen
if [ ! -d "node_modules" ] || [ ! "$(ls -A node_modules)" ]; then
    echo -e "${YELLOW}📦 Instalando dependencias...${NC}"
    yarn install
fi

# Paso 4: Crear configuración de desarrollo
echo -e "${BLUE}📋 Paso 4: Creando configuración de desarrollo...${NC}"

cat > app-config.local.yaml << 'EOF'
app:
  title: IA-Ops Platform (Local Dev)
  baseUrl: http://localhost:3000

organization:
  name: IA-Ops Organization

backend:
  auth:
    keys:
      - secret: development-secret-key
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  
  database:
    client: pg
    connection:
      host: localhost
      port: 5432
      user: postgres
      password: postgres123
      database: backstage
      ssl: false

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

auth:
  environment: development
  session:
    secret: development-secret-key
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
    - allow: [Component, System, API, Resource, Location, User, Group, Domain]
  locations:
    - type: file
      target: ../../examples/entities.yaml
    - type: file
      target: ../../examples/template/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../examples/org.yaml
      rules:
        - allow: [User, Group]

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
EOF

# Paso 5: Iniciar Backstage en modo desarrollo
echo -e "${BLUE}📋 Paso 5: Iniciando Backstage en modo desarrollo...${NC}"

# Crear script de inicio
cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando Backstage en modo desarrollo..."
echo "📊 Backend: http://localhost:7007"
echo "🌐 Frontend: http://localhost:3000"
echo ""
echo "⚠️  Presiona Ctrl+C para detener"
echo ""

# Cargar variables de entorno
export $(grep -v '^#' ../../.env | xargs)

# Iniciar Backstage
yarn dev --config app-config.yaml --config app-config.local.yaml
EOF

chmod +x start-dev.sh

# Paso 6: Verificación final
echo -e "${BLUE}📋 Paso 6: Verificación final...${NC}"
echo ""
echo -e "${GREEN}🎉 CONFIGURACIÓN COMPLETADA EXITOSAMENTE${NC}"
echo ""
echo -e "${BLUE}📊 Estado de los servicios:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}🚀 Para iniciar Backstage:${NC}"
echo -e "  cd applications/backstage"
echo -e "  ./start-dev.sh"

echo ""
echo -e "${BLUE}🌐 URLs una vez iniciado:${NC}"
echo -e "  • Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  • Backend:  ${GREEN}http://localhost:7007${NC}"

echo ""
echo -e "${YELLOW}💡 Ventajas de esta solución:${NC}"
echo -e "  • ✅ Desarrollo rápido y hot-reload"
echo -e "  • ✅ Debugging fácil"
echo -e "  • ✅ No problemas de Docker"
echo -e "  • ✅ Configuración flexible"

echo ""
echo -e "${GREEN}✅ Backstage listo para desarrollo${NC}"
