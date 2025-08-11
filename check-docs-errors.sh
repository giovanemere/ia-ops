#!/bin/bash

# =============================================================================
# SCRIPT PARA VERIFICAR ERRORES DE DOCUMENTACIÓN
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
echo "║                    VERIFICANDO ERRORES DE DOCUMENTACIÓN                     ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Buscar el log más reciente
latest_log=$(ls -t backstage-*.log 2>/dev/null | head -1)

if [ -z "$latest_log" ]; then
    echo -e "${RED}❌ No se encontraron logs de Backstage${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Analizando log: $latest_log${NC}"
echo ""

# Verificar errores de TechDocs
echo -e "${BLUE}=== 1. ERRORES DE TECHDOCS ===${NC}"
techdocs_errors=$(grep -c "techdocs.*error\|Failed to build the docs page" "$latest_log" 2>/dev/null || echo "0")
if [ "$techdocs_errors" -gt 0 ]; then
    echo -e "${RED}❌ Encontrados $techdocs_errors errores de TechDocs${NC}"
    echo "Últimos errores:"
    grep "techdocs.*error\|Failed to build the docs page" "$latest_log" | tail -3 | sed 's/^/   /'
else
    echo -e "${GREEN}✅ No se encontraron errores de TechDocs${NC}"
fi

# Verificar errores de GitHub API
echo ""
echo -e "${BLUE}=== 2. ERRORES DE GITHUB API ===${NC}"
github_errors=$(grep -c "Request failed for https://api.github.com" "$latest_log" 2>/dev/null || echo "0")
if [ "$github_errors" -gt 0 ]; then
    echo -e "${RED}❌ Encontrados $github_errors errores de GitHub API${NC}"
    echo "Últimos errores:"
    grep "Request failed for https://api.github.com" "$latest_log" | tail -3 | sed 's/^/   /'
else
    echo -e "${GREEN}✅ No se encontraron errores de GitHub API${NC}"
fi

# Verificar errores de catálogo
echo ""
echo -e "${BLUE}=== 3. ERRORES DE CATÁLOGO ===${NC}"
catalog_errors=$(grep -c "catalog.*error\|Unable to read url" "$latest_log" 2>/dev/null || echo "0")
if [ "$catalog_errors" -gt 0 ]; then
    echo -e "${YELLOW}⚠️ Encontrados $catalog_errors warnings/errores de catálogo${NC}"
    echo "Últimos errores:"
    grep "catalog.*error\|Unable to read url" "$latest_log" | tail -3 | sed 's/^/   /'
else
    echo -e "${GREEN}✅ No se encontraron errores de catálogo${NC}"
fi

# Verificar errores generales
echo ""
echo -e "${BLUE}=== 4. ERRORES GENERALES ===${NC}"
general_errors=$(grep -c "\\berror\\b" "$latest_log" 2>/dev/null || echo "0")
if [ "$general_errors" -gt 0 ]; then
    echo -e "${YELLOW}⚠️ Encontrados $general_errors errores generales${NC}"
    echo "Últimos errores (excluyendo TechDocs):"
    grep "\\berror\\b" "$latest_log" | grep -v "techdocs\|Failed to build the docs page" | tail -3 | sed 's/^/   /'
else
    echo -e "${GREEN}✅ No se encontraron errores generales${NC}"
fi

# Verificar estado de servicios
echo ""
echo -e "${BLUE}=== 5. ESTADO DE SERVICIOS ===${NC}"
if curl -s --max-time 3 "http://localhost:3002" >/dev/null; then
    echo -e "${GREEN}✅ Frontend: http://localhost:3002${NC}"
else
    echo -e "${RED}❌ Frontend: http://localhost:3002${NC}"
fi

if curl -s --max-time 3 "http://localhost:7007" >/dev/null; then
    echo -e "${GREEN}✅ Backend: http://localhost:7007${NC}"
else
    echo -e "${RED}❌ Backend: http://localhost:7007${NC}"
fi

# Resumen
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                RESUMEN                                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

total_issues=$((techdocs_errors + github_errors))
if [ "$total_issues" -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡No se encontraron errores críticos de documentación!${NC}"
    echo -e "${GREEN}✨ Backstage está funcionando correctamente${NC}"
else
    echo -e "${YELLOW}⚠️ Se encontraron $total_issues problemas de documentación${NC}"
    echo -e "${CYAN}💡 Los errores de documentación no afectan la funcionalidad principal${NC}"
fi

echo ""
echo -e "${CYAN}🔧 COMANDOS ÚTILES:${NC}"
echo "   Ver log completo: tail -f $latest_log"
echo "   Reiniciar Backstage: ./start-backstage-only.sh"
echo "   Verificar servicios: ./quick-check.sh"
