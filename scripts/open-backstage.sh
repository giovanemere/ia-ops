#!/bin/bash

# =============================================================================
# SCRIPT PARA ABRIR BACKSTAGE EN EL NAVEGADOR
# =============================================================================
# Descripción: Abre las URLs correctas de Backstage en el navegador
# Uso: ./scripts/open-backstage.sh

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏛️ Abriendo Backstage en el navegador...${NC}"
echo ""

# Verificar que los servicios estén corriendo
echo -e "${YELLOW}Verificando servicios...${NC}"

# Verificar frontend
if curl -s -f http://localhost:3000 > /dev/null; then
    echo -e "✅ Frontend disponible en: ${GREEN}http://localhost:3000${NC}"
    FRONTEND_OK=true
else
    echo -e "❌ Frontend NO disponible en puerto 3000"
    FRONTEND_OK=false
fi

# Verificar backend
if curl -s -f http://localhost:7007/health > /dev/null; then
    echo -e "✅ Backend disponible en: ${GREEN}http://localhost:7007${NC}"
    BACKEND_OK=true
else
    echo -e "❌ Backend NO disponible en puerto 7007"
    BACKEND_OK=false
fi

# Verificar proxy (opcional)
if curl -s -f http://localhost:8080/health > /dev/null; then
    echo -e "✅ Proxy disponible en: ${GREEN}http://localhost:8080${NC}"
    PROXY_OK=true
else
    echo -e "⚠️  Proxy no disponible en puerto 8080"
    PROXY_OK=false
fi

echo ""

# Mostrar URLs disponibles
echo -e "${BLUE}🌐 URLs disponibles:${NC}"
echo ""

if [ "$FRONTEND_OK" = true ]; then
    echo -e "${GREEN}📱 FRONTEND (Interfaz Principal):${NC}"
    echo "   http://localhost:3000"
    echo "   👆 Esta es la URL principal para usar Backstage"
    echo ""
fi

if [ "$BACKEND_OK" = true ]; then
    echo -e "${GREEN}🔧 BACKEND (APIs):${NC}"
    echo "   http://localhost:7007"
    echo "   http://localhost:7007/health"
    echo "   http://localhost:7007/api/catalog/entities"
    echo ""
fi

if [ "$PROXY_OK" = true ]; then
    echo -e "${GREEN}🌐 PROXY (Gateway):${NC}"
    echo "   http://localhost:8080"
    echo ""
fi

# Intentar abrir en el navegador
if [ "$FRONTEND_OK" = true ]; then
    echo -e "${YELLOW}🚀 Abriendo Backstage Frontend...${NC}"
    
    # Detectar el comando para abrir navegador según el OS
    if command -v xdg-open > /dev/null; then
        # Linux
        xdg-open http://localhost:3000
    elif command -v open > /dev/null; then
        # macOS
        open http://localhost:3000
    elif command -v start > /dev/null; then
        # Windows
        start http://localhost:3000
    else
        echo -e "${YELLOW}No se pudo abrir automáticamente el navegador.${NC}"
        echo -e "Por favor, abre manualmente: ${GREEN}http://localhost:3000${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ ¡Backstage debería abrirse en tu navegador!${NC}"
    echo ""
    echo -e "${BLUE}💡 Información importante:${NC}"
    echo "• Frontend (interfaz visual): http://localhost:3000"
    echo "• Backend (APIs): http://localhost:7007"
    echo "• El puerto 7007 es solo para APIs, no para navegador"
    echo "• Usa el puerto 3000 para la interfaz web"
    
else
    echo -e "${YELLOW}⚠️  El frontend no está disponible.${NC}"
    echo "Ejecuta: docker-compose up -d backstage-frontend"
fi

echo ""
echo -e "${BLUE}🔧 Comandos útiles:${NC}"
echo "• Ver estado: docker-compose ps"
echo "• Ver logs: docker-compose logs -f backstage-frontend"
echo "• Reiniciar: docker-compose restart backstage-frontend"
