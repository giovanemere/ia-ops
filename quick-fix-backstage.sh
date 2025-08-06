#!/bin/bash

# =============================================================================
# SCRIPT DE RECUPERACIÓN RÁPIDA - BACKSTAGE
# =============================================================================
# Descripción: Solución rápida para problemas de compilación de Backstage
# Tiempo estimado: 15-20 minutos

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚨 INICIANDO RECUPERACIÓN RÁPIDA DE BACKSTAGE${NC}"
echo -e "${YELLOW}⏰ Tiempo estimado: 15-20 minutos${NC}"
echo ""

# Paso 1: Limpiar contenedores existentes
echo -e "${BLUE}📋 Paso 1: Limpiando contenedores existentes...${NC}"
docker-compose down -v 2>/dev/null || true
docker system prune -f 2>/dev/null || true

# Paso 2: Verificar archivos necesarios
echo -e "${BLUE}📋 Paso 2: Verificando archivos necesarios...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
    exit 1
fi

if [ ! -f "applications/backstage/package.json" ]; then
    echo -e "${RED}❌ Backstage package.json no encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archivos necesarios encontrados${NC}"

# Paso 3: Construir solo servicios básicos primero
echo -e "${BLUE}📋 Paso 3: Iniciando servicios básicos...${NC}"
docker-compose -f docker-compose.backstage-only.yml up -d postgres redis

# Esperar a que los servicios básicos estén listos
echo -e "${YELLOW}⏳ Esperando servicios básicos...${NC}"
sleep 30

# Verificar que los servicios básicos estén funcionando
echo -e "${BLUE}📋 Paso 4: Verificando servicios básicos...${NC}"
if ! docker-compose -f docker-compose.backstage-only.yml ps | grep -q "Up (healthy)"; then
    echo -e "${RED}❌ Servicios básicos no están funcionando correctamente${NC}"
    docker-compose -f docker-compose.backstage-only.yml logs
    exit 1
fi

echo -e "${GREEN}✅ Servicios básicos funcionando${NC}"

# Paso 5: Construir backend de Backstage
echo -e "${BLUE}📋 Paso 5: Construyendo backend de Backstage...${NC}"
docker-compose -f docker-compose.backstage-only.yml build backstage-backend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backend construido exitosamente${NC}"
else
    echo -e "${RED}❌ Error construyendo backend${NC}"
    echo -e "${YELLOW}💡 Intentando construcción alternativa...${NC}"
    
    # Construcción alternativa sin cache
    docker-compose -f docker-compose.backstage-only.yml build --no-cache backstage-backend
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error crítico en construcción de backend${NC}"
        exit 1
    fi
fi

# Paso 6: Iniciar backend
echo -e "${BLUE}📋 Paso 6: Iniciando backend de Backstage...${NC}"
docker-compose -f docker-compose.backstage-only.yml up -d backstage-backend

# Esperar a que el backend esté listo
echo -e "${YELLOW}⏳ Esperando backend (60 segundos)...${NC}"
sleep 60

# Verificar backend
if curl -f http://localhost:7007/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend funcionando correctamente${NC}"
else
    echo -e "${RED}❌ Backend no responde${NC}"
    echo -e "${YELLOW}📋 Logs del backend:${NC}"
    docker-compose -f docker-compose.backstage-only.yml logs backstage-backend | tail -20
    exit 1
fi

# Paso 7: Construir frontend
echo -e "${BLUE}📋 Paso 7: Construyendo frontend de Backstage...${NC}"
docker-compose -f docker-compose.backstage-only.yml build backstage-frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend construido exitosamente${NC}"
else
    echo -e "${RED}❌ Error construyendo frontend${NC}"
    echo -e "${YELLOW}💡 Intentando construcción alternativa...${NC}"
    
    # Construcción alternativa sin cache
    docker-compose -f docker-compose.backstage-only.yml build --no-cache backstage-frontend
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error crítico en construcción de frontend${NC}"
        exit 1
    fi
fi

# Paso 8: Iniciar frontend
echo -e "${BLUE}📋 Paso 8: Iniciando frontend de Backstage...${NC}"
docker-compose -f docker-compose.backstage-only.yml up -d backstage-frontend

# Esperar a que el frontend esté listo
echo -e "${YELLOW}⏳ Esperando frontend (30 segundos)...${NC}"
sleep 30

# Verificar frontend
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend funcionando correctamente${NC}"
else
    echo -e "${RED}❌ Frontend no responde${NC}"
    echo -e "${YELLOW}📋 Logs del frontend:${NC}"
    docker-compose -f docker-compose.backstage-only.yml logs backstage-frontend | tail -20
    exit 1
fi

# Paso 9: Verificación final
echo -e "${BLUE}📋 Paso 9: Verificación final...${NC}"
echo ""
echo -e "${GREEN}🎉 RECUPERACIÓN COMPLETADA EXITOSAMENTE${NC}"
echo ""
echo -e "${BLUE}📊 Estado de los servicios:${NC}"
docker-compose -f docker-compose.backstage-only.yml ps

echo ""
echo -e "${BLUE}🌐 URLs de acceso:${NC}"
echo -e "  • Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  • Backend:  ${GREEN}http://localhost:7007${NC}"
echo -e "  • API:      ${GREEN}http://localhost:7007/api/catalog/entities${NC}"

echo ""
echo -e "${BLUE}🧪 Comandos de prueba:${NC}"
echo -e "  curl http://localhost:3000"
echo -e "  curl http://localhost:7007/health"
echo -e "  curl http://localhost:7007/api/catalog/entities"

echo ""
echo -e "${YELLOW}⚠️  Para usar el sistema completo, ejecuta:${NC}"
echo -e "  docker-compose up -d"

echo ""
echo -e "${GREEN}✅ Backstage está listo para usar${NC}"
