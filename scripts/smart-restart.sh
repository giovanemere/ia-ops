#!/bin/bash

set -e

# Cargar funciones comunes
source "$(dirname "$0")/common-functions.sh"

echo "🔄 REINICIO INTELIGENTE DE SERVICIOS"
echo "===================================="

active_count=$(count_active_services)

if [ $active_count -eq 0 ]; then
    echo "⚠️  No hay servicios activos. Usa 'start' en su lugar."
    echo "💡 Ejecuta: ./scripts/manage.sh start"
    exit 0
fi

echo "📊 Servicios activos detectados: $active_count"
echo ""
echo "🛑 Deteniendo servicios..."
$SCRIPTS_DIR/stop.sh

echo ""
echo "⏳ Esperando limpieza completa..."
sleep 5

echo ""
echo "🚀 Iniciando servicios..."
$SCRIPTS_DIR/start-services-safe.sh

echo ""
echo "⏳ Esperando que los servicios estén listos..."
sleep 10

echo ""
echo "✅ Reinicio completado"
