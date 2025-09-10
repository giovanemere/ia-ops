#!/bin/bash

set -e

# Cargar funciones comunes
source "$(dirname "$0")/common-functions.sh"

echo "🔍 Verificando servicios activos..."

active_count=$(count_active_services)
total_services=7

echo "📊 Servicios activos: $active_count/$total_services"

if [ $active_count -eq 0 ]; then
    echo "🚀 No hay servicios activos. Iniciando todos los servicios..."
    $SCRIPTS_DIR/start-services-safe.sh
elif [ $active_count -eq $total_services ]; then
    echo "✅ Todos los servicios ya están activos"
    echo ""
    echo "🎯 URLs disponibles:"
    echo "   🎭 Backstage: http://localhost:3000"
    echo "   📚 Portal Docs: http://localhost:8845"
    echo "   🚀 Dev-Core API: http://localhost:8801"
    echo "   🤖 OpenAI API: http://localhost:8000"
    echo "   📦 MinIO Console: http://localhost:9899"
else
    echo "🔄 Algunos servicios están activos. Iniciando solo los faltantes..."
    $SCRIPTS_DIR/start-missing-services.sh
fi
