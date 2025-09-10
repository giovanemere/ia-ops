#!/bin/bash

set -e

BASE_DIR="/home/giovanemere/ia-ops"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Puertos principales a verificar
PORTS=(5432 9000 8801 8000 8869 8845 3000)

# Función para verificar si un puerto está activo
is_port_active() {
    ss -tln | grep -q ":$1 "
}

# Contar servicios activos
count_active_services() {
    local count=0
    for port in "${PORTS[@]}"; do
        if is_port_active $port; then
            ((count++))
        fi
    done
    echo $count
}

echo "🔍 Verificando servicios activos..."

active_count=$(count_active_services)
total_services=${#PORTS[@]}

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
