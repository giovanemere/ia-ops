#!/bin/bash

echo "🔐 DIAGNÓSTICO DE AUTENTICACIÓN DE BACKSTAGE"
echo "============================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cargar variables de entorno
ENV_FILE="../../.env"
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
fi

echo -e "${BLUE}1. VERIFICANDO BACKEND_SECRET${NC}"
echo "-----------------------------"

if [ -n "$BACKEND_SECRET" ]; then
    echo -e "${GREEN}✅ BACKEND_SECRET está configurado${NC}"
    echo -e "${GREEN}   Longitud: ${#BACKEND_SECRET} caracteres${NC}"
    echo -e "${GREEN}   Valor: ${BACKEND_SECRET:0:20}...${NC}"
    
    # Verificar que sea suficientemente seguro
    if [ ${#BACKEND_SECRET} -ge 32 ]; then
        echo -e "${GREEN}✅ Longitud adecuada (≥32 caracteres)${NC}"
    else
        echo -e "${RED}❌ Longitud insuficiente (<32 caracteres)${NC}"
    fi
else
    echo -e "${RED}❌ BACKEND_SECRET no está configurado${NC}"
fi

echo ""
echo -e "${BLUE}2. VERIFICANDO CONFIGURACIÓN EN APP-CONFIG.YAML${NC}"
echo "-----------------------------------------------"

if grep -q "BACKEND_SECRET" "app-config.yaml"; then
    echo -e "${GREEN}✅ app-config.yaml referencia BACKEND_SECRET${NC}"
    
    # Mostrar la configuración
    echo -e "${YELLOW}Configuración encontrada:${NC}"
    grep -A 3 -B 1 "BACKEND_SECRET" "app-config.yaml"
else
    echo -e "${RED}❌ app-config.yaml no referencia BACKEND_SECRET${NC}"
fi

echo ""
echo -e "${BLUE}3. VERIFICANDO CONFIGURACIÓN DE AUTENTICACIÓN${NC}"
echo "---------------------------------------------"

# Verificar configuración de auth en app-config.yaml
if grep -q "auth:" "app-config.yaml"; then
    echo -e "${GREEN}✅ Sección 'auth' encontrada en app-config.yaml${NC}"
    
    # Verificar providers
    if grep -q "providers:" "app-config.yaml"; then
        echo -e "${GREEN}✅ Sección 'providers' configurada${NC}"
        
        # Verificar guest provider
        if grep -q "guest:" "app-config.yaml"; then
            echo -e "${GREEN}✅ Guest provider configurado${NC}"
        else
            echo -e "${YELLOW}⚠️  Guest provider no encontrado${NC}"
        fi
    else
        echo -e "${RED}❌ Sección 'providers' no encontrada${NC}"
    fi
else
    echo -e "${RED}❌ Sección 'auth' no encontrada en app-config.yaml${NC}"
fi

echo ""
echo -e "${BLUE}4. VERIFICANDO BACKEND AUTH CONFIGURATION${NC}"
echo "----------------------------------------"

# Verificar configuración de backend auth
if grep -q "backend:" "app-config.yaml"; then
    echo -e "${GREEN}✅ Sección 'backend' encontrada${NC}"
    
    if grep -A 5 "backend:" "app-config.yaml" | grep -q "auth:"; then
        echo -e "${GREEN}✅ Configuración 'backend.auth' encontrada${NC}"
        
        if grep -A 10 "backend:" "app-config.yaml" | grep -q "keys:"; then
            echo -e "${GREEN}✅ Configuración 'backend.auth.keys' encontrada${NC}"
        else
            echo -e "${RED}❌ Configuración 'backend.auth.keys' no encontrada${NC}"
        fi
    else
        echo -e "${RED}❌ Configuración 'backend.auth' no encontrada${NC}"
    fi
else
    echo -e "${RED}❌ Sección 'backend' no encontrada${NC}"
fi

echo ""
echo -e "${BLUE}5. VERIFICANDO PLUGINS DE AUTENTICACIÓN${NC}"
echo "-------------------------------------------"

# Verificar plugins de auth en backend
if [ -f "packages/backend/src/index.ts" ]; then
    echo -e "${GREEN}✅ Archivo backend/src/index.ts encontrado${NC}"
    
    if grep -q "plugin-auth-backend" "packages/backend/src/index.ts"; then
        echo -e "${GREEN}✅ Plugin auth-backend configurado${NC}"
    else
        echo -e "${RED}❌ Plugin auth-backend no encontrado${NC}"
    fi
    
    if grep -q "auth-backend-module-guest-provider" "packages/backend/src/index.ts"; then
        echo -e "${GREEN}✅ Guest provider module configurado${NC}"
    else
        echo -e "${RED}❌ Guest provider module no encontrado${NC}"
    fi
else
    echo -e "${RED}❌ Archivo backend/src/index.ts no encontrado${NC}"
fi

echo ""
echo -e "${BLUE}6. VERIFICANDO BASE DE DATOS DE AUTENTICACIÓN${NC}"
echo "--------------------------------------------"

# Verificar base de datos de auth
auth_tables=$(docker exec ia-ops-postgres psql -U postgres -d backstage_plugin_auth -c "\dt" 2>/dev/null | grep -c "table")

if [ $auth_tables -gt 0 ]; then
    echo -e "${GREEN}✅ Base de datos de auth: $auth_tables tablas${NC}"
    
    # Verificar datos en tablas de auth
    key_count=$(docker exec ia-ops-postgres psql -U postgres -d backstage_plugin_auth -c "SELECT COUNT(*) FROM backstage_backend_public_keys__keys;" 2>/dev/null | grep -E "^\s*[0-9]+\s*$" | tr -d ' ')
    
    if [ -n "$key_count" ]; then
        echo -e "${GREEN}✅ Claves públicas en BD: $key_count${NC}"
    else
        echo -e "${YELLOW}⚠️  No se pudieron verificar las claves públicas${NC}"
    fi
else
    echo -e "${RED}❌ Base de datos de auth sin tablas${NC}"
fi

echo ""
echo -e "${BLUE}7. PRUEBA DE CONECTIVIDAD${NC}"
echo "------------------------"

# Verificar que Backstage no esté ejecutándose
if pgrep -f "yarn start" > /dev/null; then
    echo -e "${YELLOW}⚠️  Backstage está ejecutándose${NC}"
    echo -e "${YELLOW}   Para aplicar cambios, reinicia con: ./start-with-env.sh${NC}"
else
    echo -e "${GREEN}✅ Backstage no está ejecutándose${NC}"
    echo -e "${GREEN}   Listo para iniciar con: ./start-with-env.sh${NC}"
fi

echo ""
echo -e "${BLUE}8. RECOMENDACIONES${NC}"
echo "----------------"

echo -e "${YELLOW}Para solucionar el error 'Missing credentials':${NC}"
echo ""
echo "1. Asegúrate de que BACKEND_SECRET esté configurado:"
echo "   export \$(grep -v '^#' ../../.env | xargs)"
echo "   echo \$BACKEND_SECRET"
echo ""
echo "2. Inicia Backstage con el script mejorado:"
echo "   ./start-with-env.sh"
echo ""
echo "3. Si el problema persiste, verifica los logs:"
echo "   yarn start 2>&1 | grep -E '(auth|Auth|AUTH|error|Error)'"
echo ""
echo "4. Verifica que el endpoint de auth responda:"
echo "   curl -I http://localhost:7007/api/auth/guest/start"

echo ""
echo -e "${GREEN}✅ DIAGNÓSTICO DE AUTENTICACIÓN COMPLETADO${NC}"
echo "=========================================="
