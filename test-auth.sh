#!/bin/bash

# =============================================================================
# SCRIPT PARA VERIFICAR LA CONFIGURACIÓN DE AUTENTICACIÓN
# =============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICANDO CONFIGURACIÓN DE AUTENTICACIÓN               ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar que Backstage esté corriendo
echo -e "${BLUE}=== 1. VERIFICANDO SERVICIOS ===${NC}"
if curl -s --max-time 5 "http://localhost:3002" >/dev/null; then
    echo -e "${GREEN}✅ Backstage Frontend: http://localhost:3002${NC}"
else
    echo -e "${RED}❌ Backstage Frontend no responde${NC}"
    exit 1
fi

if curl -s --max-time 5 "http://localhost:7007" >/dev/null; then
    echo -e "${GREEN}✅ Backstage Backend: http://localhost:7007${NC}"
else
    echo -e "${RED}❌ Backstage Backend no responde${NC}"
    exit 1
fi

# Verificar configuración de auth
echo ""
echo -e "${BLUE}=== 2. VERIFICANDO CONFIGURACIÓN DE AUTH ===${NC}"

# Verificar variables de entorno
cd /home/giovanemere/ia-ops/ia-ops
source .env

if [ -n "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo -e "${GREEN}✅ GitHub Client ID configurado${NC}"
else
    echo -e "${RED}❌ GitHub Client ID no configurado${NC}"
fi

if [ -n "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo -e "${GREEN}✅ GitHub Client Secret configurado${NC}"
else
    echo -e "${RED}❌ GitHub Client Secret no configurado${NC}"
fi

if [ -n "$BACKEND_SECRET" ]; then
    echo -e "${GREEN}✅ Backend Secret configurado${NC}"
else
    echo -e "${RED}❌ Backend Secret no configurado${NC}"
fi

# Verificar configuración en app-config.yaml
echo ""
echo -e "${BLUE}=== 3. VERIFICANDO CONFIGURACIÓN EN APP-CONFIG ===${NC}"

config_file="/home/giovanemere/ia-ops/ia-ops/applications/backstage/app-config.yaml"

if grep -q "guest:" "$config_file"; then
    echo -e "${GREEN}✅ Configuración de guest encontrada${NC}"
else
    echo -e "${RED}❌ Configuración de guest no encontrada${NC}"
fi

if grep -q "github:" "$config_file"; then
    echo -e "${GREEN}✅ Configuración de GitHub encontrada${NC}"
else
    echo -e "${RED}❌ Configuración de GitHub no encontrada${NC}"
fi

# Verificar endpoint de auth
echo ""
echo -e "${BLUE}=== 4. VERIFICANDO ENDPOINTS DE AUTH ===${NC}"

# Verificar endpoint de auth del backend
auth_response=$(curl -s --max-time 5 "http://localhost:7007/api/auth/providers" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Endpoint de auth responde${NC}"
    if echo "$auth_response" | grep -q "guest"; then
        echo -e "${GREEN}✅ Proveedor guest disponible${NC}"
    else
        echo -e "${YELLOW}⚠️ Proveedor guest no detectado en respuesta${NC}"
    fi
    if echo "$auth_response" | grep -q "github"; then
        echo -e "${GREEN}✅ Proveedor GitHub disponible${NC}"
    else
        echo -e "${YELLOW}⚠️ Proveedor GitHub no detectado en respuesta${NC}"
    fi
else
    echo -e "${RED}❌ Endpoint de auth no responde${NC}"
fi

# Verificar frontend
echo ""
echo -e "${BLUE}=== 5. VERIFICANDO FRONTEND ===${NC}"

frontend_response=$(curl -s --max-time 5 "http://localhost:3002" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend carga correctamente${NC}"
    if echo "$frontend_response" | grep -q -i "sign.*in\|login\|auth"; then
        echo -e "${GREEN}✅ Página de login detectada${NC}"
    else
        echo -e "${YELLOW}⚠️ No se detecta página de login específica${NC}"
    fi
else
    echo -e "${RED}❌ Frontend no responde${NC}"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                RESUMEN                                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}🌐 ACCESOS:${NC}"
echo "   🏛️  Backstage: http://localhost:3002"
echo "   🔧 Backend:   http://localhost:7007"
echo ""
echo -e "${YELLOW}🔐 OPCIONES DE LOGIN:${NC}"
echo "   👤 Guest (Invitado): Debería estar disponible"
echo "   🐙 GitHub OAuth: Configurado con tus credenciales"
echo ""
echo -e "${GREEN}✨ Prueba acceder a http://localhost:3002${NC}"
echo -e "${GREEN}   El error de guest debería estar solucionado${NC}"
