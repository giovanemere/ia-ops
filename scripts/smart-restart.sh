#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Función para verificar si un puerto está activo
is_port_active() {
    ss -tln | grep -q ":$1 "
}

# Contar servicios activos
count_active_services() {
    local count=0
    local ports=(5432 9000 8801 8000 8869 8845 3000)
    for port in "${ports[@]}"; do
        if is_port_active $port; then
            ((count++))
        fi
    done
    echo $count
}

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
echo "✅ Reinicio completado"
