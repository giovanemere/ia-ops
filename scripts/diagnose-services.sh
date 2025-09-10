#!/bin/bash

echo "🔍 DIAGNÓSTICO COMPLETO DE SERVICIOS IA-OPS"
echo "============================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar puerto
check_port() {
    local port=$1
    local name=$2
    if ss -tln | grep -q ":$port "; then
        echo -e "  ✅ ${GREEN}$name${NC} (puerto $port) - ACTIVO"
        return 0
    else
        echo -e "  ❌ ${RED}$name${NC} (puerto $port) - INACTIVO"
        return 1
    fi
}

# Función para verificar directorio y script
check_service_dir() {
    local dir=$1
    local name=$2
    local script=$3
    
    if [ -d "$dir" ]; then
        echo -e "  📁 ${GREEN}$name${NC} - Directorio existe"
        if [ -f "$dir/$script" ]; then
            echo -e "     ✅ Script de inicio: $script"
        else
            echo -e "     ❌ ${RED}Script faltante: $script${NC}"
        fi
    else
        echo -e "  ❌ ${RED}$name${NC} - Directorio no existe: $dir"
    fi
}

echo ""
echo "🗄️  INFRAESTRUCTURA BASE:"
active_infra=0
check_port 5434 "PostgreSQL" && ((active_infra++))
check_port 5050 "pgAdmin" && ((active_infra++))
check_port 6380 "Redis" && ((active_infra++))
check_port 8840 "Redis Commander" && ((active_infra++))
check_port 9899 "MinIO Console" && ((active_infra++))
check_port 9898 "MinIO API" && ((active_infra++))
check_port 8848 "MinIO REST" && ((active_infra++))

echo ""
echo "🚀 SERVICIOS CORE:"
active_core=0
check_port 8801 "Dev-Core API" && ((active_core++))
check_port 8000 "OpenAI API" && ((active_core++))

echo ""
echo "🔧 MICROSERVICIOS DEV-CORE:"
active_micro=0
check_port 8860 "Repository Manager" && ((active_micro++))
check_port 8861 "Task Manager" && ((active_micro++))
check_port 8862 "Log Manager" && ((active_micro++))
check_port 8863 "DataSync Manager" && ((active_micro++))
check_port 8864 "GitHub Runner Manager" && ((active_micro++))
check_port 8865 "TechDocs Builder" && ((active_micro++))

echo ""
echo "📚 DOCUMENTACIÓN:"
active_docs=0
check_port 8845 "Portal Principal" && ((active_docs++))
check_port 5000 "Docs Portal (alternativo)" && ((active_docs++))

echo ""
echo "🧪 TESTING:"
active_test=0
check_port 8869 "Veritas" && ((active_test++))

echo ""
echo "🎭 FRONTEND:"
active_frontend=0
check_port 3000 "Backstage" && ((active_frontend++))

echo ""
echo "📁 VERIFICACIÓN DE DIRECTORIOS Y SCRIPTS:"
echo ""
echo "Servicios disponibles:"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-postgress" "PostgreSQL" "scripts/manage.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-minio" "MinIO" "scripts/manage.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-dev-core" "Dev-Core" "scripts/start.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-openai" "OpenAI" "start-isolated.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-veritas" "Veritas" "scripts/start-unified.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-docs" "Docs Portal" "start_portal.sh"
check_service_dir "/home/giovanemere/ia-ops/ia-ops-backstage" "Backstage" "scripts/start-development.sh"

echo ""
echo "📊 RESUMEN DE ESTADO:"
echo "================================="
echo -e "🗄️  Infraestructura: ${active_infra}/7 servicios activos"
echo -e "🚀 Core Services: ${active_core}/2 servicios activos"
echo -e "🔧 Microservicios: ${active_micro}/6 servicios activos"
echo -e "📚 Documentación: ${active_docs}/2 servicios activos"
echo -e "🧪 Testing: ${active_test}/1 servicios activos"
echo -e "🎭 Frontend: ${active_frontend}/1 servicios activos"

total_active=$((active_infra + active_core + active_micro + active_docs + active_test + active_frontend))
total_services=19

echo ""
echo -e "📈 ESTADO GENERAL: ${total_active}/${total_services} servicios activos"

if [ $active_frontend -eq 0 ]; then
    echo -e "⚠️  ${YELLOW}CRÍTICO: Frontend (Backstage) no está activo${NC}"
fi

if [ $active_docs -eq 0 ]; then
    echo -e "⚠️  ${YELLOW}IMPORTANTE: Portal de documentación no está activo${NC}"
fi

echo ""
echo "🚀 ACCIONES RECOMENDADAS:"
echo "========================="

if [ $active_frontend -eq 0 ]; then
    echo "1. Iniciar Backstage: ./restart-backstage.sh"
fi

if [ $active_docs -eq 0 ]; then
    echo "2. Iniciar Docs Portal: ./restart-docs.sh"
fi

if [ $active_test -eq 0 ]; then
    echo "3. Iniciar Veritas (opcional): ./restart-veritas.sh"
fi

echo ""
echo "🔍 Para verificar después de iniciar servicios:"
echo "   ./check-ports.sh"
echo "   ./status-services.sh"

echo ""
echo "🎯 URLs principales una vez activos:"
echo "   🎭 Backstage: http://localhost:3000"
echo "   📚 Portal Docs: http://localhost:8845"
echo "   🚀 Dev-Core API: http://localhost:8801"
echo "   🤖 OpenAI API: http://localhost:8000"
echo "   📦 MinIO Console: http://localhost:9899"
