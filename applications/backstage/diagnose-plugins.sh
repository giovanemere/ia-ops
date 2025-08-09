#!/bin/bash

echo "🔍 DIAGNÓSTICO DE PLUGINS DE BACKSTAGE"
echo "======================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar estado
show_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

echo -e "${BLUE}1. VERIFICANDO ESTADO DE POSTGRESQL${NC}"
echo "-----------------------------------"

# Verificar PostgreSQL
docker exec ia-ops-postgres pg_isready -U postgres > /dev/null 2>&1
show_status $? "PostgreSQL está funcionando"

# Verificar conexión con backstage_user
docker exec ia-ops-postgres psql -U backstage_user -d backstage_db -c "SELECT 1;" > /dev/null 2>&1
show_status $? "Conexión con backstage_user funciona"

echo ""
echo -e "${BLUE}2. VERIFICANDO BASES DE DATOS DE PLUGINS${NC}"
echo "----------------------------------------"

# Lista de plugins esperados
plugins=("app" "auth" "catalog" "kubernetes" "permission" "proxy" "scaffolder" "search" "techdocs")

for plugin in "${plugins[@]}"; do
    db_name="backstage_plugin_$plugin"
    
    # Verificar si la base de datos existe
    exists=$(docker exec ia-ops-postgres psql -U postgres -lqt | cut -d \| -f 1 | grep -w "$db_name" | wc -l)
    
    if [ $exists -eq 1 ]; then
        # Contar tablas
        table_count=$(docker exec ia-ops-postgres psql -U postgres -d "$db_name" -c "\dt" 2>/dev/null | grep -c "table")
        
        if [ $table_count -gt 0 ]; then
            echo -e "${GREEN}✅ $plugin: $table_count tablas${NC}"
        else
            echo -e "${YELLOW}⚠️  $plugin: Base de datos existe pero sin tablas${NC}"
        fi
    else
        echo -e "${RED}❌ $plugin: Base de datos no existe${NC}"
    fi
done

echo ""
echo -e "${BLUE}3. VERIFICANDO CONFIGURACIÓN DE BACKSTAGE${NC}"
echo "-------------------------------------------"

# Verificar archivos de configuración
config_files=("app-config.yaml" "app-config.production.yaml")

for config in "${config_files[@]}"; do
    if [ -f "$config" ]; then
        echo -e "${GREEN}✅ $config existe${NC}"
        
        # Verificar configuración de base de datos
        if grep -q "client: pg" "$config"; then
            echo -e "${GREEN}  ✅ Configurado para PostgreSQL${NC}"
        else
            echo -e "${RED}  ❌ No configurado para PostgreSQL${NC}"
        fi
        
        # Verificar configuración de plugins específicos
        if grep -q "techRadar:" "$config"; then
            echo -e "${GREEN}  ✅ Tech Radar configurado${NC}"
        fi
        
        if grep -q "costInsights:" "$config"; then
            echo -e "${GREEN}  ✅ Cost Insights configurado${NC}"
        fi
        
        if grep -q "kubernetes:" "$config"; then
            echo -e "${GREEN}  ✅ Kubernetes configurado${NC}"
        fi
    else
        echo -e "${RED}❌ $config no existe${NC}"
    fi
done

echo ""
echo -e "${BLUE}4. VERIFICANDO PLUGINS EN CÓDIGO${NC}"
echo "--------------------------------"

# Verificar plugins en backend
backend_plugins=$(grep -c "backend.add" packages/backend/src/index.ts)
echo -e "${GREEN}✅ Backend: $backend_plugins plugins configurados${NC}"

# Verificar plugins en frontend
frontend_plugins=$(grep -c "plugin-" packages/app/src/App.tsx)
echo -e "${GREEN}✅ Frontend: $frontend_plugins imports de plugins${NC}"

echo ""
echo -e "${BLUE}5. VERIFICANDO VARIABLES DE ENTORNO${NC}"
echo "-----------------------------------"

# Variables críticas
env_vars=("POSTGRES_HOST" "POSTGRES_PORT" "POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB")

for var in "${env_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo -e "${GREEN}✅ $var está configurada${NC}"
    else
        echo -e "${RED}❌ $var no está configurada${NC}"
    fi
done

echo ""
echo -e "${BLUE}6. VERIFICANDO DATOS EN CATÁLOGO${NC}"
echo "-------------------------------"

# Verificar entidades en el catálogo
entity_count=$(docker exec ia-ops-postgres psql -U postgres -d backstage_plugin_catalog -c "SELECT COUNT(*) FROM final_entities;" 2>/dev/null | grep -E "^\s*[0-9]+\s*$" | tr -d ' ')

if [ -n "$entity_count" ] && [ "$entity_count" -gt 0 ]; then
    echo -e "${GREEN}✅ Catálogo: $entity_count entidades registradas${NC}"
else
    echo -e "${YELLOW}⚠️  Catálogo: Sin entidades o error de conexión${NC}"
fi

echo ""
echo -e "${BLUE}7. POSIBLES CAUSAS DE PÉRDIDA DE CONFIGURACIÓN${NC}"
echo "--------------------------------------------"

echo -e "${YELLOW}Posibles problemas identificados:${NC}"

# Verificar permisos de base de datos
db_owner_issues=$(docker exec ia-ops-postgres psql -U postgres -c "\l" | grep backstage_plugin | grep -v backstage_user | wc -l)

if [ $db_owner_issues -gt 0 ]; then
    echo -e "${RED}❌ Problema de permisos: Algunas bases de datos de plugins pertenecen a 'postgres' en lugar de 'backstage_user'${NC}"
    echo -e "${YELLOW}   Solución: Cambiar propietario de las bases de datos${NC}"
fi

# Verificar si app-config.local.yaml existe (ya lo eliminamos)
if [ -f "app-config.local.yaml" ]; then
    echo -e "${RED}❌ app-config.local.yaml existe y puede estar sobrescribiendo configuración${NC}"
else
    echo -e "${GREEN}✅ app-config.local.yaml no existe (correcto)${NC}"
fi

echo ""
echo -e "${BLUE}8. RECOMENDACIONES${NC}"
echo "----------------"

echo -e "${YELLOW}Para solucionar la pérdida de configuración:${NC}"
echo ""
echo "1. Cambiar propietario de bases de datos de plugins:"
echo "   docker exec ia-ops-postgres psql -U postgres -c \"ALTER DATABASE backstage_plugin_auth OWNER TO backstage_user;\""
echo "   docker exec ia-ops-postgres psql -U postgres -c \"ALTER DATABASE backstage_plugin_catalog OWNER TO backstage_user;\""
echo "   # ... para cada plugin"
echo ""
echo "2. Verificar que las variables de entorno estén en el archivo .env:"
echo "   cat ../../.env | grep POSTGRES"
echo ""
echo "3. Reiniciar Backstage con configuración limpia:"
echo "   ./start-clean.sh"
echo ""
echo "4. Verificar logs durante el inicio:"
echo "   yarn start 2>&1 | grep -E '(error|Error|ERROR|warn|Warn|WARN)'"

echo ""
echo -e "${GREEN}✅ DIAGNÓSTICO COMPLETADO${NC}"
echo "========================"
