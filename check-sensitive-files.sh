#!/bin/bash

# =============================================================================
# SCRIPT PARA VERIFICAR ARCHIVOS SENSIBLES
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICANDO ARCHIVOS SENSIBLES                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

cd /home/giovanemere/ia-ops/ia-ops

# =============================================================================
# 1. VERIFICAR QUE .env ESTÁ IGNORADO
# =============================================================================

echo -e "${BLUE}=== 1. VERIFICANDO ARCHIVOS .env ===${NC}"

if [ -f ".env" ]; then
    if git check-ignore .env >/dev/null 2>&1; then
        echo -e "${GREEN}✅ .env existe y está ignorado por Git${NC}"
    else
        echo -e "${RED}❌ .env existe pero NO está ignorado por Git${NC}"
        echo -e "${YELLOW}⚠️ PELIGRO: .env podría subirse al repositorio${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ .env no existe - crear desde .env.example${NC}"
fi

# =============================================================================
# 2. VERIFICAR ARCHIVOS TRACKEADOS SENSIBLES
# =============================================================================

echo ""
echo -e "${BLUE}=== 2. VERIFICANDO ARCHIVOS SENSIBLES TRACKEADOS ===${NC}"

sensitive_patterns=(
    "\.env$"
    "\.env\."
    "token"
    "secret"
    "password"
    "credential"
    "\.key$"
    "\.pem$"
)

found_sensitive=false
for pattern in "${sensitive_patterns[@]}"; do
    files=$(git ls-files | grep -i "$pattern" 2>/dev/null || true)
    if [ -n "$files" ]; then
        echo -e "${RED}❌ Archivos sensibles encontrados con patrón '$pattern':${NC}"
        echo "$files" | sed 's/^/   /'
        found_sensitive=true
    fi
done

if [ "$found_sensitive" = false ]; then
    echo -e "${GREEN}✅ No se encontraron archivos sensibles trackeados${NC}"
fi

# =============================================================================
# 3. VERIFICAR ARCHIVOS EN STAGING
# =============================================================================

echo ""
echo -e "${BLUE}=== 3. VERIFICANDO ARCHIVOS EN STAGING ===${NC}"

staged_files=$(git diff --cached --name-only 2>/dev/null || true)
if [ -n "$staged_files" ]; then
    echo "Archivos en staging:"
    echo "$staged_files" | sed 's/^/   /'
    
    # Verificar si hay archivos sensibles en staging
    sensitive_in_staging=false
    for pattern in "${sensitive_patterns[@]}"; do
        if echo "$staged_files" | grep -qi "$pattern"; then
            echo -e "${RED}❌ PELIGRO: Archivos sensibles en staging${NC}"
            sensitive_in_staging=true
            break
        fi
    done
    
    if [ "$sensitive_in_staging" = false ]; then
        echo -e "${GREEN}✅ No hay archivos sensibles en staging${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️ No hay archivos en staging${NC}"
fi

# =============================================================================
# 4. VERIFICAR .gitignore
# =============================================================================

echo ""
echo -e "${BLUE}=== 4. VERIFICANDO .gitignore ===${NC}"

if [ -f ".gitignore" ]; then
    if grep -q "^\.env$" .gitignore; then
        echo -e "${GREEN}✅ .env está en .gitignore${NC}"
    else
        echo -e "${RED}❌ .env NO está en .gitignore${NC}"
    fi
    
    if grep -q "^\*\.log$" .gitignore; then
        echo -e "${GREEN}✅ Logs están ignorados${NC}"
    else
        echo -e "${YELLOW}⚠️ Logs podrían no estar ignorados${NC}"
    fi
else
    echo -e "${RED}❌ .gitignore no existe${NC}"
fi

# =============================================================================
# 5. VERIFICAR .env.example
# =============================================================================

echo ""
echo -e "${BLUE}=== 5. VERIFICANDO .env.example ===${NC}"

if [ -f ".env.example" ]; then
    echo -e "${GREEN}✅ .env.example existe${NC}"
    
    # Verificar que no contiene valores reales
    if grep -q "ghp_\|sk-\|tu_.*_aqui" .env.example; then
        echo -e "${GREEN}✅ .env.example contiene placeholders, no valores reales${NC}"
    else
        echo -e "${YELLOW}⚠️ Verificar que .env.example no contiene valores reales${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ .env.example no existe - se recomienda crearlo${NC}"
fi

# =============================================================================
# 6. RECOMENDACIONES
# =============================================================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                               RECOMENDACIONES                                ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$found_sensitive" = true ] || [ "$sensitive_in_staging" = true ]; then
    echo -e "${RED}🚨 ACCIÓN REQUERIDA:${NC}"
    echo "1. Remover archivos sensibles del tracking:"
    echo "   git rm --cached archivo_sensible"
    echo "2. Agregar patrones al .gitignore"
    echo "3. Hacer commit de los cambios"
    echo ""
fi

echo -e "${YELLOW}💡 MEJORES PRÁCTICAS:${NC}"
echo "• Siempre usar .env.example como plantilla"
echo "• Nunca commitear archivos con credenciales reales"
echo "• Revisar archivos antes de hacer commit"
echo "• Usar este script regularmente"
echo ""

echo -e "${CYAN}🔧 COMANDOS ÚTILES:${NC}"
echo "   Verificar qué archivos están ignorados: git check-ignore *"
echo "   Ver archivos trackeados: git ls-files"
echo "   Remover del tracking: git rm --cached archivo"
echo "   Verificar staging: git diff --cached --name-only"
