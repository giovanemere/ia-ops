#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"
# Orden por dependencias de red: DB -> Storage -> Core -> Apps -> Frontend
SERVICES=(
    "ia-ops-postgress"
    "ia-ops-minio"
    "ia-ops-dev-core"
    "openai-service"
    "ia-ops-veritas"
    "ia-ops-docs"
)

# Servicios opcionales (se inician solo si se solicita)
# OPTIONAL_SERVICES=(
#     "ia-ops-guard"  # Temporalmente deshabilitado
# )

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
                ./scripts/start.sh
                ;;
            "openai-service")
                ./start-integrated.sh start
                ;;
            "ia-ops-veritas")
                ./scripts/manage.sh start
                ;;
            "ia-ops-docs")
                ./start_portal.sh
                ;;
            "ia-ops-guard")
                ./manage-integrated.sh start
                ;;
        esac
        
        sleep 3  # Esperar entre servicios
    fi
done

echo "✅ Servicios principales iniciados"

echo "🎭 Iniciando Backstage (en segundo plano)..."
cd "$BASE_DIR/ia-ops-backstage"
if [ -f "./scripts/start-development.sh" ]; then
    nohup ./scripts/start-development.sh > backstage.log 2>&1 &
else
    nohup yarn dev > backstage.log 2>&1 &
fi

echo "✅ Todos los servicios iniciados (volúmenes preservados)"
