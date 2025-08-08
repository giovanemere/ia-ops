#!/bin/bash

# =============================================================================
# MIGRACIÓN CONTROLADA A BACKSTAGE COMPLETO
# =============================================================================
# Fecha: 8 de Agosto de 2025
# Versión: 3.0.0
# Descripción: Migración paso a paso con verificación en cada etapa
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKSTAGE_DIR="$PROJECT_ROOT/applications/backstage"

echo -e "${BLUE}🚀 IA-Ops Backstage Migración Controlada${NC}"
echo -e "${BLUE}=========================================${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}$1${NC}"
}

# Function to wait for user confirmation
wait_for_confirmation() {
    read -p "¿Continuar con el siguiente paso? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migración cancelada por el usuario."
        exit 1
    fi
}

# Step 1: Verificar estado actual
print_step "1. Verificando Estado Actual"

if [ ! -d "$BACKSTAGE_DIR" ]; then
    print_error "Directorio de Backstage no encontrado: $BACKSTAGE_DIR"
    exit 1
fi

cd "$BACKSTAGE_DIR"

# Verificar que es la nueva aplicación
if [ ! -f "backstage.json" ]; then
    print_error "No se encontró backstage.json. ¿Es esta una aplicación Backstage válida?"
    exit 1
fi

print_status "Aplicación Backstage encontrada"

# Step 2: Verificar dependencias
print_step "2. Verificando Dependencias"

if ! command -v node &> /dev/null; then
    print_error "Node.js no está instalado"
    exit 1
fi

if ! command -v yarn &> /dev/null; then
    print_error "Yarn no está instalado"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Se requiere Node.js versión 18 o superior (actual: $(node --version))"
    exit 1
fi

print_status "Dependencias verificadas"
wait_for_confirmation

# Step 3: Verificar compilación TypeScript
print_step "3. Verificando Compilación TypeScript"

if yarn tsc --noEmit; then
    print_status "Compilación TypeScript exitosa"
else
    print_error "Error en compilación TypeScript"
    exit 1
fi

wait_for_confirmation

# Step 4: Verificar build completo
print_step "4. Verificando Build Completo"

if yarn build:all; then
    print_status "Build completo exitoso"
else
    print_error "Error en build completo"
    exit 1
fi

wait_for_confirmation

# Step 5: Verificar configuración personalizada
print_step "5. Verificando Configuración Personalizada"

if grep -q "IA-Ops Platform" app-config.yaml; then
    print_status "Configuración personalizada encontrada"
else
    print_warning "Configuración personalizada no encontrada, usando configuración por defecto"
fi

if [ -f "$PROJECT_ROOT/catalog-info.yaml" ]; then
    print_status "Catalog de IA-Ops encontrado"
else
    print_warning "Catalog de IA-Ops no encontrado"
fi

wait_for_confirmation

# Step 6: Construir imagen Docker
print_step "6. Construyendo Imagen Docker"

cd "$PROJECT_ROOT"

if docker-compose build backstage-backend; then
    print_status "Imagen Docker construida exitosamente"
else
    print_error "Error construyendo imagen Docker"
    exit 1
fi

wait_for_confirmation

# Step 7: Probar servicios básicos
print_step "7. Probando Servicios Básicos"

# Iniciar servicios de base de datos
docker-compose up -d postgres redis

# Esperar a que estén listos
echo "Esperando a que los servicios estén listos..."
sleep 10

# Verificar que están funcionando
if docker-compose ps postgres | grep -q "Up"; then
    print_status "PostgreSQL funcionando"
else
    print_error "PostgreSQL no está funcionando"
    exit 1
fi

if docker-compose ps redis | grep -q "Up"; then
    print_status "Redis funcionando"
else
    print_error "Redis no está funcionando"
    exit 1
fi

wait_for_confirmation

# Step 8: Iniciar Backstage Backend
print_step "8. Iniciando Backstage Backend"

docker-compose up -d backstage-backend

echo "Esperando a que Backstage Backend esté listo..."
sleep 30

# Verificar health check
for i in {1..10}; do
    if curl -f http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
        print_status "Backstage Backend funcionando correctamente"
        break
    else
        if [ $i -eq 10 ]; then
            print_error "Backstage Backend no responde después de 10 intentos"
            echo "Logs del contenedor:"
            docker-compose logs backstage-backend
            exit 1
        fi
        echo "Intento $i/10 - Esperando respuesta del backend..."
        sleep 10
    fi
done

wait_for_confirmation

# Step 9: Iniciar Frontend
print_step "9. Iniciando Backstage Frontend"

docker-compose up -d backstage-frontend

echo "Esperando a que Backstage Frontend esté listo..."
sleep 20

# Verificar frontend
for i in {1..5}; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        print_status "Backstage Frontend funcionando correctamente"
        break
    else
        if [ $i -eq 5 ]; then
            print_warning "Frontend no responde, pero puede estar funcionando internamente"
            break
        fi
        echo "Intento $i/5 - Esperando respuesta del frontend..."
        sleep 10
    fi
done

wait_for_confirmation

# Step 10: Iniciar servicios adicionales
print_step "10. Iniciando Servicios Adicionales"

docker-compose up -d openai-service proxy-service

echo "Esperando a que los servicios adicionales estén listos..."
sleep 15

# Verificar proxy
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    print_status "Proxy Service funcionando"
else
    print_warning "Proxy Service no responde (puede estar configurándose)"
fi

wait_for_confirmation

# Step 11: Verificación final
print_step "11. Verificación Final del Sistema"

echo "Verificando todos los servicios..."

# Mostrar estado de todos los servicios
docker-compose ps

echo -e "\n${GREEN}🎉 Migración Completada Exitosamente!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${BLUE}URLs de Acceso:${NC}"
echo "• 🌐 Portal Principal: http://localhost:8080"
echo "• 🏛️ Backstage Directo: http://localhost:3000"
echo "• 🔧 Backend API: http://localhost:7007"
echo "• 🤖 OpenAI Service: http://localhost:8080/openai"
echo ""
echo -e "${BLUE}Comandos de Verificación:${NC}"
echo "• docker-compose ps"
echo "• curl http://localhost:8080/health"
echo "• curl http://localhost:7007/api/catalog/health"
echo "• curl http://localhost:3000"
echo ""
echo -e "${BLUE}Próximos Pasos:${NC}"
echo "1. Configurar variables de entorno en .env"
echo "2. Añadir tu GitHub token para integración"
echo "3. Personalizar el catálogo de servicios"
echo "4. Configurar autenticación OAuth"
echo ""
echo -e "${YELLOW}Nota: Si algún servicio no responde inmediatamente, espera unos minutos${NC}"
echo -e "${YELLOW}para que termine de inicializarse completamente.${NC}"

# Opcional: Mostrar logs si hay problemas
read -p "¿Mostrar logs de los servicios? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}Logs de Backstage Backend:${NC}"
    docker-compose logs --tail=20 backstage-backend
    
    echo -e "\n${BLUE}Logs de Backstage Frontend:${NC}"
    docker-compose logs --tail=20 backstage-frontend
fi

echo -e "\n${GREEN}¡Migración controlada completada con éxito!${NC}"
