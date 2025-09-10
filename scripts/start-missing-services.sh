#!/bin/bash

# Cargar funciones comunes
source "$(dirname "$0")/common-functions.sh"

echo "🚀 INICIANDO SERVICIOS FALTANTES"
echo "================================="

echo ""
echo "1️⃣ Iniciando Dev-Core API..."
start_if_needed 8801 "Dev-Core API" "ia-ops-dev-core" "start.sh"

echo ""
echo "2️⃣ Iniciando Portal de Documentación..."
start_if_needed 8845 "Docs Portal" "ia-ops-docs" "start_portal.sh"

echo ""
echo "3️⃣ Iniciando Veritas (Testing)..."
start_if_needed 8869 "Veritas" "ia-ops-veritas" "scripts/manage.sh start"

echo ""
echo "4️⃣ Iniciando Backstage Frontend (en segundo plano)..."
if ! is_port_active 3000; then
    echo "🔄 Iniciando Backstage..."
    cd "$BASE_DIR/ia-ops-backstage"
    if [ -f "./scripts/start-development.sh" ]; then
        nohup ./scripts/start-development.sh > backstage.log 2>&1 &
    else
        nohup yarn dev > backstage.log 2>&1 &
    fi
    echo "✅ Backstage iniciado en segundo plano"
else
    echo "✅ Backstage ya está activo (puerto 3000)"
fi

echo ""
echo "🔍 Verificando estado final..."
sleep 5

echo ""
echo "📊 ESTADO FINAL:"
echo "================"

is_port_active 8801 && echo "✅ Dev-Core API: http://localhost:8801" || echo "❌ Dev-Core API: No disponible"
is_port_active 8845 && echo "✅ Portal Docs: http://localhost:8845" || echo "❌ Portal Docs: No disponible"
is_port_active 8869 && echo "✅ Veritas: http://localhost:8869" || echo "❌ Veritas: No disponible"
is_port_active 3000 && echo "✅ Backstage: http://localhost:3000" || echo "🔄 Backstage: Iniciando..."

echo ""
echo "🎯 URLs principales disponibles:"
echo "   🎭 Backstage: http://localhost:3000"
echo "   📚 Portal Docs: http://localhost:8845"
echo "   🚀 Dev-Core API: http://localhost:8801"
echo "   🤖 OpenAI API: http://localhost:8000"
echo "   📦 MinIO Console: http://localhost:9899"

echo ""
echo "✅ Proceso completado. Ejecuta './check-ports.sh' para verificación completa."
