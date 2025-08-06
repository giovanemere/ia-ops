#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN - BACKSTAGE READY
# =============================================================================
# Descripción: Verifica que Backstage esté listo para despliegue
# Uso: ./scripts/check-backstage-ready.sh

set -e

echo "🔍 Verificando preparación de Backstage para despliegue..."

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
        return 1
    fi
}

# Función para mostrar warning
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Función para mostrar info
show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo ""
echo "=== 📋 VERIFICACIÓN DE ARCHIVOS ==="

# Verificar archivos esenciales
files_to_check=(
    ".env"
    "docker-compose.yml"
    "applications/backstage/Dockerfile.frontend"
    "applications/backstage/Dockerfile.backend"
    "applications/backstage/package.json"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        show_status 0 "Archivo $file existe"
    else
        show_status 1 "Archivo $file NO existe"
    fi
done

echo ""
echo "=== 🔐 VERIFICACIÓN DE VARIABLES DE ENTORNO ==="

# Verificar variables críticas
if [ -f ".env" ]; then
    source .env
    
    # Variables críticas
    critical_vars=(
        "GITHUB_TOKEN"
        "AUTH_GITHUB_CLIENT_ID" 
        "AUTH_GITHUB_CLIENT_SECRET"
        "BACKEND_SECRET"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
        "POSTGRES_DB"
    )
    
    for var in "${critical_vars[@]}"; do
        if [ -n "${!var}" ]; then
            show_status 0 "Variable $var está configurada"
        else
            show_status 1 "Variable $var NO está configurada"
        fi
    done
    
    # Variables opcionales pero recomendadas
    optional_vars=(
        "OPENAI_API_KEY"
        "REDIS_PASSWORD"
        "GRAFANA_ADMIN_PASSWORD"
    )
    
    echo ""
    echo "=== ⚙️ VARIABLES OPCIONALES ==="
    for var in "${optional_vars[@]}"; do
        if [ -n "${!var}" ]; then
            show_status 0 "Variable $var está configurada"
        else
            show_warning "Variable $var no está configurada (opcional)"
        fi
    done
else
    show_status 1 "Archivo .env no encontrado"
fi

echo ""
echo "=== 🐳 VERIFICACIÓN DE DOCKER ==="

# Verificar Docker
if command -v docker &> /dev/null; then
    show_status 0 "Docker está instalado"
    
    # Verificar que Docker esté corriendo
    if docker info &> /dev/null; then
        show_status 0 "Docker daemon está corriendo"
    else
        show_status 1 "Docker daemon NO está corriendo"
    fi
else
    show_status 1 "Docker NO está instalado"
fi

# Verificar Docker Compose
if command -v docker-compose &> /dev/null; then
    show_status 0 "Docker Compose está instalado"
    
    # Verificar sintaxis del docker-compose.yml
    if docker-compose config &> /dev/null; then
        show_status 0 "docker-compose.yml tiene sintaxis válida"
    else
        show_status 1 "docker-compose.yml tiene errores de sintaxis"
    fi
else
    show_status 1 "Docker Compose NO está instalado"
fi

echo ""
echo "=== 📁 VERIFICACIÓN DE DIRECTORIOS ==="

# Verificar directorios necesarios
directories_to_check=(
    "applications/backstage"
    "applications/openai-service"
    "applications/proxy-service"
    "config/backstage"
    "config/database"
    "logs"
)

for dir in "${directories_to_check[@]}"; do
    if [ -d "$dir" ]; then
        show_status 0 "Directorio $dir existe"
    else
        show_warning "Directorio $dir no existe - se creará automáticamente"
        mkdir -p "$dir"
    fi
done

echo ""
echo "=== 🔌 VERIFICACIÓN DE PUERTOS ==="

# Verificar puertos disponibles
ports_to_check=(
    "3000:Backstage Frontend"
    "7007:Backstage Backend" 
    "8000:OpenAI Service"
    "8080:Proxy Service"
    "5432:PostgreSQL"
    "6379:Redis"
    "9090:Prometheus"
    "3001:Grafana"
)

for port_info in "${ports_to_check[@]}"; do
    port=$(echo $port_info | cut -d: -f1)
    service=$(echo $port_info | cut -d: -f2)
    
    if lsof -i :$port &> /dev/null; then
        show_warning "Puerto $port ($service) está en uso"
    else
        show_status 0 "Puerto $port ($service) está disponible"
    fi
done

echo ""
echo "=== 🏗️ VERIFICACIÓN DE APLICACIONES ==="

# Verificar estructura de Backstage
if [ -d "applications/backstage" ]; then
    backstage_files=(
        "applications/backstage/Dockerfile.frontend"
        "applications/backstage/Dockerfile.backend"
        "applications/backstage/package.json"
    )
    
    for file in "${backstage_files[@]}"; do
        if [ -f "$file" ]; then
            show_status 0 "Archivo Backstage $file existe"
        else
            show_status 1 "Archivo Backstage $file NO existe"
        fi
    done
fi

echo ""
echo "=== 📊 RESUMEN ==="

# Contar errores y warnings
error_count=$(grep -c "❌" /tmp/check_output 2>/dev/null || echo "0")
warning_count=$(grep -c "⚠️" /tmp/check_output 2>/dev/null || echo "0")

if [ "$error_count" -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Backstage está listo para despliegue!${NC}"
    echo ""
    echo "=== 🚀 COMANDOS PARA INICIAR ==="
    echo "1. Construir imágenes:"
    echo "   docker-compose build"
    echo ""
    echo "2. Iniciar servicios:"
    echo "   docker-compose up -d"
    echo ""
    echo "3. Ver logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "4. Verificar estado:"
    echo "   docker-compose ps"
    echo ""
    echo "=== 🌐 URLs DE ACCESO ==="
    echo "• Proxy Gateway: http://localhost:8080"
    echo "• Backstage Frontend: http://localhost:3000"
    echo "• Backstage Backend: http://localhost:7007"
    echo "• OpenAI Service: http://localhost:8000"
    echo "• Prometheus: http://localhost:9090"
    echo "• Grafana: http://localhost:3001"
else
    echo -e "${RED}❌ Se encontraron $error_count errores que deben corregirse antes del despliegue${NC}"
    if [ "$warning_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  También hay $warning_count advertencias que deberías revisar${NC}"
    fi
    exit 1
fi

echo ""
echo "=== 🔧 PRÓXIMOS PASOS RECOMENDADOS ==="
echo "1. Revisar y ajustar variables en .env si es necesario"
echo "2. Ejecutar: docker-compose build --no-cache"
echo "3. Ejecutar: docker-compose up -d"
echo "4. Monitorear logs: docker-compose logs -f"
echo "5. Verificar health checks: docker-compose ps"
