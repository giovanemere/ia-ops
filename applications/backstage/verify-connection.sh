#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN DE CONEXIÓN BACKSTAGE
# =============================================================================

echo "🔍 Verificando conexión Frontend-Backend y Base de Datos..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar servicios
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Verificando $service_name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        return 1
    fi
}

# Función para verificar variables de entorno
check_env_var() {
    local var_name=$1
    local var_value=$(eval echo \$$var_name)
    
    echo -n "Verificando $var_name... "
    
    if [ -n "$var_value" ]; then
        echo -e "${GREEN}✅ Configurado${NC}"
        return 0
    else
        echo -e "${RED}❌ No configurado${NC}"
        return 1
    fi
}

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    source ../../.env
    echo -e "${GREEN}✅ Variables de entorno cargadas${NC}"
else
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
    exit 1
fi

echo ""
echo "📋 VERIFICACIÓN DE VARIABLES DE ENTORNO:"
echo "----------------------------------------"

# Verificar variables críticas
check_env_var "BACKEND_SECRET"
check_env_var "POSTGRES_USER"
check_env_var "POSTGRES_PASSWORD"
check_env_var "POSTGRES_DB"
check_env_var "DATABASE_CLIENT"

echo ""
echo "🗄️ VERIFICACIÓN DE BASE DE DATOS:"
echo "--------------------------------"

# Verificar conexión a PostgreSQL
echo -n "Verificando PostgreSQL... "
if docker exec backstage-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Conectado${NC}"
    
    # Verificar tablas
    echo -n "Verificando tablas... "
    table_count=$(docker exec backstage-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    
    if [ "$table_count" -gt 0 ]; then
        echo -e "${GREEN}✅ $table_count tablas encontradas${NC}"
    else
        echo -e "${YELLOW}⚠️ Sin tablas (normal en primera ejecución)${NC}"
    fi
else
    echo -e "${RED}❌ Error de conexión${NC}"
fi

echo ""
echo "🌐 VERIFICACIÓN DE SERVICIOS:"
echo "----------------------------"

# Verificar servicios si están corriendo
if docker ps | grep -q "backstage-postgres"; then
    echo -e "${GREEN}✅ PostgreSQL container running${NC}"
else
    echo -e "${RED}❌ PostgreSQL container not running${NC}"
fi

if docker ps | grep -q "ia-ops-redis"; then
    echo -e "${GREEN}✅ Redis container running${NC}"
else
    echo -e "${RED}❌ Redis container not running${NC}"
fi

# Verificar puertos
echo ""
echo "🔌 VERIFICACIÓN DE PUERTOS:"
echo "--------------------------"

ports=("5432:PostgreSQL" "6379:Redis" "7007:Backstage Backend" "3002:Backstage Frontend")

for port_info in "${ports[@]}"; do
    port=$(echo $port_info | cut -d: -f1)
    service=$(echo $port_info | cut -d: -f2)
    
    echo -n "Puerto $port ($service)... "
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${GREEN}✅ Abierto${NC}"
    else
        echo -e "${RED}❌ Cerrado${NC}"
    fi
done

echo ""
echo "📝 CONFIGURACIÓN ACTUAL:"
echo "----------------------"
echo "Database Client: $DATABASE_CLIENT"
echo "Database Host: $POSTGRES_HOST"
echo "Database Port: $POSTGRES_PORT"
echo "Database User: $POSTGRES_USER"
echo "Database Name: $POSTGRES_DB"
echo "Backend Secret: ${BACKEND_SECRET:0:10}..."

echo ""
echo "🚀 COMANDOS PARA INICIAR BACKSTAGE:"
echo "----------------------------------"
echo "cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "yarn install"
echo "yarn start:dev"

echo ""
echo "🔗 URLs DE ACCESO:"
echo "-----------------"
echo "Frontend: http://localhost:3002"
echo "Backend:  http://localhost:7007"
echo "Health:   http://localhost:7007/api/catalog/health"
