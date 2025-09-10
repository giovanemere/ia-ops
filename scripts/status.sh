#!/bin/bash

BASE_DIR="/home/giovanemere/ia-ops"

echo "📊 Estado de servicios IA-Ops"
echo "================================"

# Función para verificar puerto
check_port() {
    local port=$1
    local name=$2
    if ss -tln | grep -q ":$port "; then
        echo "  ✅ $name (puerto $port) - ACTIVO"
    else
        echo "  ❌ $name (puerto $port) - INACTIVO"
    fi
}

# Función para verificar contenedor Docker
check_container() {
    local container_name=$1
    local service_name=$2
    local status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
    local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
    
    if [ "$status" = "running" ]; then
        if [ "$health" = "healthy" ]; then
            echo "  ✅ $service_name - ACTIVO (healthy)"
        elif [ "$health" = "starting" ]; then
            echo "  🔄 $service_name - INICIANDO"
        elif [ "$health" = "unhealthy" ]; then
            echo "  ⚠️  $service_name - ACTIVO (unhealthy)"
        else
            echo "  ✅ $service_name - ACTIVO"
        fi
    else
        echo "  ❌ $service_name - INACTIVO"
    fi
}

echo ""
echo "🗄️  Infraestructura Base:"
check_container "iaops-postgres" "PostgreSQL (puerto 5434)"
check_container "iaops-redis" "Redis (puerto 6380)"
check_container "iaops-minio-portal" "MinIO (puerto 9899)"

echo ""
echo "🚀 Servicios Core:"
check_container "iaops-service-layer" "Service Layer (puerto 8801)"
check_container "iaops-veritas-unified" "Veritas (puerto 8869)"

echo ""
echo "🔧 Microservicios Dev-Core:"
check_container "iaops-repository-manager" "Repository Manager (puerto 8860)"
check_container "iaops-task-manager" "Task Manager (puerto 8861)"
check_container "iaops-log-manager" "Log Manager (puerto 8862)"
check_container "iaops-datasync-manager" "DataSync Manager (puerto 8863)"
check_container "iaops-github-runner-manager" "GitHub Runner Manager (puerto 8864)"
# TechDocs Builder eliminado

echo ""
echo "📚 Documentación y Portal:"
check_port 5000 "Docs Portal"
check_port 8000 "MkDocs (alternativo)"

echo ""
echo "🎭 Frontend:"
check_port 3000 "Backstage Frontend"
check_port 7007 "Backstage Backend"

echo ""
echo "🐳 Contenedores Docker activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -v "NAMES"

echo ""
echo "📋 URLs de acceso:"
echo "  🎭 Backstage: http://localhost:3000"
echo "  📚 Docs Portal: http://localhost:5000"
echo "  🗄️  PostgreSQL: localhost:5434"
echo "  📦 MinIO Console: http://localhost:9899"
echo ""
echo "  🔧 Microservicios:"
echo "     Repository Manager: http://localhost:8860"
echo "     Task Manager: http://localhost:8861"
echo "     Log Manager: http://localhost:8862"
echo "     DataSync Manager: http://localhost:8863"
echo "     GitHub Runner Manager: http://localhost:8864"
echo "# TechDocs Builder eliminado"
check_container() {
    local pattern=$1
    local name=$2
    if docker ps --format "table {{.Names}}" | grep -q "$pattern"; then
        echo "  ✅ $name - ACTIVO"
    else
        echo "  ❌ $name - INACTIVO"
    fi
}

echo ""
echo "🗄️  Infraestructura Base:"
check_container "iaops-postgres-main" "PostgreSQL"
check_container "iaops-redis-main" "Redis"
check_container "ia-ops-minio-portal" "MinIO"

echo ""
echo "🚀 Servicios Core:"
check_port 8801 "Dev-Core API"
check_container "iaops-openai" "OpenAI Service"
check_port 8869 "Veritas"

echo ""
echo "📚 Documentación y Portal:"
check_port 5000 "Docs Portal"
check_port 8000 "MkDocs (alternativo)"

echo ""
echo "🎭 Frontend:"
check_port 3000 "Backstage"

echo ""
echo "🐳 Contenedores Docker activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep iaops || echo "  No hay contenedores IA-Ops activos"

echo ""
echo "🔧 Procesos Node/Python activos:"
echo "Backstage:"
pgrep -f "backstage-cli\|yarn.*dev" | wc -l | xargs -I {} echo "  {} procesos activos"

echo "Docs Portal:"
pgrep -f "techdocs_portal.py\|python.*app.py" | wc -l | xargs -I {} echo "  {} procesos activos"

echo ""
echo "📋 Resumen de puertos:"
echo "  3000 - Backstage Frontend"
echo "  5000 - Docs Portal"
echo "  7007 - Backstage Backend"
echo "  8000 - MkDocs"
echo "  8801 - Dev-Core API"
echo "  8869 - Veritas"
echo "  9899 - MinIO Console"
echo "  5432 - PostgreSQL"
echo "  6379 - Redis"
