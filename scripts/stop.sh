#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"
SERVICES=(
    "ia-ops-backstage"
    "ia-ops-docs"
    "ia-ops-veritas"
    "ia-ops-openai"
    "ia-ops-dev-core"
    "ia-ops-minio"
    "ia-ops-postgress"
)

echo "🛑 Deteniendo todos los servicios IA-Ops..."

# Detener servicios en orden inverso
for ((i=${#SERVICES[@]}-1; i>=0; i--)); do
    service="${SERVICES[i]}"
    if [ -d "$BASE_DIR/$service" ]; then
        echo "🛑 Deteniendo $service..."
        cd "$BASE_DIR/$service"
        
        case "$service" in
            "ia-ops-backstage")
                # Detener procesos yarn/node
                pkill -f "yarn dev" 2>/dev/null || true
                pkill -f "backstage-cli" 2>/dev/null || true
                pkill -f "node.*backstage" 2>/dev/null || true
                # Detener docker si existe
                docker-compose down 2>/dev/null || true
                echo "  ✅ Backstage detenido"
                ;;
            "ia-ops-docs")
                # Detener portal Flask
                pkill -f "techdocs_portal.py" 2>/dev/null || true
                pkill -f "python.*app.py" 2>/dev/null || true
                # Detener docker si existe
                docker-compose down 2>/dev/null || true
                echo "  ✅ Docs portal detenido"
                ;;
            "ia-ops-veritas")
                ./scripts/manage.sh stop 2>/dev/null || true
                echo "  ✅ Veritas detenido"
                ;;
            "ia-ops-openai")
                docker-compose -f docker-compose.integrated.yml down 2>/dev/null || true
                echo "  ✅ OpenAI service detenido"
                ;;
            "ia-ops-dev-core")
                # Detener Service Layer principal
                docker-compose down 2>/dev/null || true
                # Detener microservicios
                cd docker && docker-compose down 2>/dev/null || true
                echo "  ✅ Dev-Core detenido"
                ;;
            "ia-ops-minio")
                ./scripts/manage.sh stop 2>/dev/null || true
                echo "  ✅ MinIO detenido"
                ;;
            "ia-ops-postgress")
                ./scripts/manage.sh stop 2>/dev/null || true
                echo "  ✅ PostgreSQL detenido"
                ;;
        esac
        
        sleep 1
    fi
done

echo "🧹 Limpiando contenedores huérfanos..."
docker container prune -f 2>/dev/null || true

echo "✅ Todos los servicios han sido detenidos"
