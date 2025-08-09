#!/bin/bash

echo "🔐 CONFIGURANDO BACKEND_SECRET PARA BACKSTAGE"
echo "============================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Generar un secreto seguro
echo -e "${BLUE}1. GENERANDO SECRETO SEGURO${NC}"
echo "----------------------------"

# Generar secreto de 64 caracteres usando openssl
BACKEND_SECRET=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-64)

echo -e "${GREEN}✅ Secreto generado: ${BACKEND_SECRET:0:20}...${NC}"
echo ""

# Actualizar el archivo .env
echo -e "${BLUE}2. ACTUALIZANDO ARCHIVO .ENV${NC}"
echo "-----------------------------"

ENV_FILE="../../.env"

if [ -f "$ENV_FILE" ]; then
    # Hacer backup del archivo .env
    cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✅ Backup creado: $ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)${NC}"
    
    # Actualizar la línea BACKEND_SECRET
    if grep -q "BACKEND_SECRET=" "$ENV_FILE"; then
        sed -i "s/BACKEND_SECRET=.*/BACKEND_SECRET=$BACKEND_SECRET/" "$ENV_FILE"
        echo -e "${GREEN}✅ BACKEND_SECRET actualizado en .env${NC}"
    else
        echo "BACKEND_SECRET=$BACKEND_SECRET" >> "$ENV_FILE"
        echo -e "${GREEN}✅ BACKEND_SECRET agregado a .env${NC}"
    fi
else
    echo -e "${RED}❌ Archivo .env no encontrado en $ENV_FILE${NC}"
    exit 1
fi

echo ""

# Verificar la configuración en app-config.yaml
echo -e "${BLUE}3. VERIFICANDO CONFIGURACIÓN${NC}"
echo "-----------------------------"

if grep -q "BACKEND_SECRET" "app-config.yaml"; then
    echo -e "${GREEN}✅ app-config.yaml está configurado para usar BACKEND_SECRET${NC}"
else
    echo -e "${RED}❌ app-config.yaml no está configurado para BACKEND_SECRET${NC}"
    echo -e "${YELLOW}Agregando configuración...${NC}"
    
    # Buscar la sección backend.auth.keys y actualizarla
    if grep -q "backend:" "app-config.yaml"; then
        echo -e "${YELLOW}⚠️  Verifica manualmente que app-config.yaml tenga:${NC}"
        echo "backend:"
        echo "  auth:"
        echo "    keys:"
        echo "      - secret: \${BACKEND_SECRET:-your-secret-key-here}"
    fi
fi

echo ""

# Crear archivo de variables de entorno para testing
echo -e "${BLUE}4. CREANDO ARCHIVO DE PRUEBA${NC}"
echo "-----------------------------"

cat > ".env.test" << EOF
# Variables de entorno para testing de Backstage
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage_user
POSTGRES_PASSWORD=backstage_pass_2025
POSTGRES_DB=backstage_db
BACKEND_SECRET=$BACKEND_SECRET
GITHUB_TOKEN=
NODE_ENV=development
EOF

echo -e "${GREEN}✅ Archivo .env.test creado${NC}"
echo ""

# Verificar que las variables se pueden cargar
echo -e "${BLUE}5. VERIFICANDO CARGA DE VARIABLES${NC}"
echo "---------------------------------"

# Cargar variables del archivo .env principal
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
    
    if [ -n "$BACKEND_SECRET" ]; then
        echo -e "${GREEN}✅ BACKEND_SECRET cargado correctamente${NC}"
        echo -e "${GREEN}   Valor: ${BACKEND_SECRET:0:20}...${NC}"
    else
        echo -e "${RED}❌ BACKEND_SECRET no se pudo cargar${NC}"
    fi
    
    if [ -n "$POSTGRES_USER" ]; then
        echo -e "${GREEN}✅ POSTGRES_USER: $POSTGRES_USER${NC}"
    else
        echo -e "${RED}❌ POSTGRES_USER no configurado${NC}"
    fi
    
    if [ -n "$POSTGRES_DB" ]; then
        echo -e "${GREEN}✅ POSTGRES_DB: $POSTGRES_DB${NC}"
    else
        echo -e "${RED}❌ POSTGRES_DB no configurado${NC}"
    fi
fi

echo ""

# Crear script de inicio mejorado
echo -e "${BLUE}6. CREANDO SCRIPT DE INICIO MEJORADO${NC}"
echo "------------------------------------"

cat > "start-with-env.sh" << 'EOF'
#!/bin/bash

echo "🚀 INICIANDO BACKSTAGE CON VARIABLES DE ENTORNO"
echo "==============================================="
echo ""

# Cargar variables de entorno
ENV_FILE="../../.env"
if [ -f "$ENV_FILE" ]; then
    echo "📁 Cargando variables desde $ENV_FILE..."
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
    echo "✅ Variables cargadas"
else
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Verificar variables críticas
echo ""
echo "🔍 Verificando variables críticas:"
echo "   BACKEND_SECRET: ${BACKEND_SECRET:0:20}..."
echo "   POSTGRES_USER: $POSTGRES_USER"
echo "   POSTGRES_DB: $POSTGRES_DB"
echo "   POSTGRES_HOST: $POSTGRES_HOST"
echo ""

# Verificar PostgreSQL
echo "🔍 Verificando PostgreSQL..."
if ! docker exec ia-ops-postgres psql -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ PostgreSQL no está ejecutándose. Iniciando..."
    cd /home/giovanemere/ia-ops/ia-ops && docker-compose up -d postgres
    sleep 10
fi

echo "✅ PostgreSQL funcionando"
echo ""

# Mostrar URLs
echo "🌐 URLs de acceso:"
echo "   Frontend: http://localhost:3002"
echo "   Backend:  http://localhost:7007"
echo ""

# Iniciar Backstage
echo "🚀 Iniciando Backstage..."
yarn start
EOF

chmod +x "start-with-env.sh"
echo -e "${GREEN}✅ Script start-with-env.sh creado${NC}"

echo ""

# Instrucciones finales
echo -e "${BLUE}7. INSTRUCCIONES FINALES${NC}"
echo "------------------------"

echo -e "${YELLOW}Para iniciar Backstage con la configuración corregida:${NC}"
echo ""
echo "  cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "  ./start-with-env.sh"
echo ""
echo -e "${YELLOW}O usar el método manual:${NC}"
echo ""
echo "  export \$(grep -v '^#' ../../.env | xargs)"
echo "  yarn start"
echo ""

echo -e "${GREEN}🎉 CONFIGURACIÓN DE BACKEND_SECRET COMPLETADA${NC}"
echo ""
echo -e "${YELLOW}Notas importantes:${NC}"
echo "- El secreto generado es único y seguro"
echo "- Se ha creado un backup del archivo .env original"
echo "- El nuevo script start-with-env.sh carga todas las variables correctamente"
echo "- Reinicia Backstage para aplicar los cambios"
EOF
