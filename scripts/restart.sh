#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"

echo "🔄 Reiniciando servicios IA-Ops en orden de dependencias..."

# 1. Infraestructura Base (PostgreSQL + Redis)
echo "🗄️  Reiniciando PostgreSQL + Redis..."
cd "$BASE_DIR/ia-ops-postgress"
if [ -f "scripts/manage.sh" ]; then
    ./scripts/manage.sh restart
else
    docker-compose restart
fi
sleep 2

# 2. Almacenamiento (MinIO)
echo "📦 Reiniciando MinIO..."
cd "$BASE_DIR/ia-ops-minio"
if [ -f "scripts/manage.sh" ]; then
    ./scripts/manage.sh restart
else
    docker-compose restart
fi
sleep 2

# 3. APIs Core (Dev-Core)
echo "🚀 Reiniciando Dev-Core..."
cd "$BASE_DIR/ia-ops-dev-core"
if [ -f "scripts/restart.sh" ]; then
    ./scripts/restart.sh
else
    docker-compose restart
fi
sleep 2

# 4. Servicios de IA (OpenAI)
echo "🤖 Reiniciando OpenAI Service..."
cd "$BASE_DIR/ia-ops-openai"
if [ -f "docker-compose.integrated.yml" ]; then
    docker-compose -f docker-compose.integrated.yml restart
else
    docker-compose restart
fi
sleep 2

# 5. Validación (Veritas)
echo "🧪 Reiniciando Veritas..."
cd "$BASE_DIR/ia-ops-veritas"
if [ -f "scripts/restart.sh" ]; then
    ./scripts/restart.sh
else
    docker-compose restart
fi
sleep 2

# 6. Portal de Documentación
echo "📚 Reiniciando Docs Portal..."
cd "$BASE_DIR/ia-ops-docs"
if pgrep -f "techdocs_portal.py" > /dev/null; then
    echo "  🛑 Deteniendo proceso actual..."
    pkill -f "techdocs_portal.py"
    sleep 2
fi
echo "  🚀 Iniciando nuevo proceso..."
./start_portal.sh > /dev/null 2>&1 &
sleep 3

# 7. Frontend (Backstage)
echo "🎭 Reiniciando Backstage..."
cd "$BASE_DIR/ia-ops-backstage"
if pgrep -f "yarn.*dev\|backstage-cli" > /dev/null; then
    echo "  🛑 Deteniendo procesos actuales..."
    pkill -f "yarn.*dev\|backstage-cli"
    sleep 3
fi
echo "  🚀 Iniciando nuevo proceso..."
./scripts/start-development.sh > /dev/null 2>&1 &

echo ""
echo "✅ Restart completado en orden de dependencias"
echo ""
echo "📊 Verificar estado: ./status-services.sh"
echo ""
echo "🔗 URLs de acceso:"
echo "   - Backstage: http://localhost:3000"
echo "   - Docs Portal: http://localhost:5000"
echo "   - Dev-Core API: http://localhost:8080"
echo "   - Veritas API: http://localhost:8081"
echo "   - MinIO Console: http://localhost:9899"
echo "   - PostgreSQL: localhost:5432"
