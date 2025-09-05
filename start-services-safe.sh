#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"
# Orden por dependencias de red: DB -> Storage -> Core -> Apps
SERVICES=(
    "ia-ops-postgress"
    "ia-ops-minio"
    "ia-ops-dev-core"
    "openai-service"
    "ia-ops-veritas"
    "ia-ops-docs"
)

echo "🔍 Verificando red..."
docker network create iaops-network 2>/dev/null || true

echo "🚀 Iniciando servicios (SIN recompilar)..."
for service in "${SERVICES[@]}"; do
    if [ -d "$BASE_DIR/$service" ]; then
        echo "📦 $service..."
        cd "$BASE_DIR/$service"
        
        case "$service" in
            "ia-ops-postgress")
                ./scripts/manage.sh start
                ;;
            "ia-ops-minio")
                ./scripts/manage.sh start
                ;;
            "ia-ops-dev-core")
                ./manage-complete.sh start
                ;;
            "openai-service")
                ./start-isolated.sh
                ;;
            "ia-ops-veritas")
                ./scripts/start-unified.sh
                ;;
            "ia-ops-docs")
                ./start_portal.sh
                ;;
        esac
        
        sleep 3  # Esperar entre servicios
    fi
done

echo "🎭 Backstage..."
cd "$BASE_DIR/ia-ops-backstage"
if [ -f "./scripts/start-development.sh" ]; then
    ./scripts/start-development.sh
else
    yarn dev
fi

echo "✅ Servicios iniciados (volúmenes preservados)"
