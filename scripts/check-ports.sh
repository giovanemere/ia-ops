#!/bin/bash

echo "🔍 Verificando puertos de servicios IA-Ops..."
echo "=============================================="

# Función para verificar puerto y mostrar estado
check_service() {
    local port=$1
    local name=$2
    local url=$3
    
    if ss -tln | grep -q ":$port "; then
        echo "✅ $name: http://localhost:$port $url"
    else
        echo "❌ $name: Puerto $port no disponible"
    fi
}

echo ""
echo "🗄️  Base de Datos y Cache:"
check_service 5050 "pgAdmin" ""
check_service 8840 "Redis Commander" ""
check_service 5434 "PostgreSQL" "(conexión directa)"
check_service 6380 "Redis" "(conexión directa)"

echo ""
echo "📦 Almacenamiento MinIO:"
check_service 8848 "MinIO API REST" ""
check_service 9898 "MinIO API" ""
check_service 9899 "MinIO Console" ""

echo ""
echo "🤖 Servicios OpenAI:"
check_service 8000 "OpenAI API" ""
check_service 8000 "OpenAI Docs" "/docs"

echo ""
echo "🚀 Dev-Core Services:"
check_service 8801 "API Principal" ""
check_service 8801 "Documentación" "/docs"
check_service 8801 "Health Check" "/health"

echo ""
echo "🔧 Microservicios Dev-Core:"
check_service 8860 "Repository Manager" ""
check_service 8861 "Task Manager" ""
check_service 8862 "Log Manager" ""
check_service 8863 "DataSync Manager" ""
check_service 8864 "GitHub Runner Manager" ""
# Eliminar línea de TechDocs Builder

echo ""
echo "📚 Documentación:"
check_service 8845 "Portal Principal" ""
check_service 5000 "Docs Portal (alternativo)" ""

echo ""
echo "🧪 Testing y Calidad:"
check_service 8869 "Veritas" ""

echo ""
echo "🎭 Frontend:"
check_service 3000 "Backstage" ""

echo ""
echo "📋 Resumen de URLs principales:"
echo "   🎭 Backstage: http://localhost:3000"
echo "   📚 Portal Docs: http://localhost:8845"
echo "   🚀 Dev-Core API: http://localhost:8801"
echo "   🤖 OpenAI API: http://localhost:8000"
echo "   📦 MinIO Console: http://localhost:9899"
echo "   🗄️  pgAdmin: http://localhost:5050"
