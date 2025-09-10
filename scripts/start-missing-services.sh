#!/bin/bash

echo "🚀 INICIANDO SERVICIOS FALTANTES"
echo "================================="

BASE_DIR="/home/giovanemere/ia-ops"

# Función para verificar si un puerto está activo
is_port_active() {
    ss -tln | grep -q ":$1 "
}

# Función para iniciar servicio si no está activo
start_if_needed() {
    local port=$1
    local name=$2
    local dir=$3
    local script=$4
    
    if is_port_active $port; then
        echo "✅ $name ya está activo (puerto $port)"
    else
        echo "🔄 Iniciando $name..."
        cd "$BASE_DIR/$dir"
        if [ -f "$script" ]; then
            ./$script
            sleep 5
            if is_port_active $port; then
                echo "✅ $name iniciado correctamente"
            else
                echo "❌ Error al iniciar $name"
            fi
        else
            echo "❌ Script no encontrado: $script"
        fi
    fi
}

echo ""
echo "1️⃣ Iniciando Portal de Documentación..."
start_if_needed 8845 "Docs Portal" "ia-ops-docs" "start_portal.sh"

echo ""
echo "2️⃣ Iniciando Backstage Frontend..."
start_if_needed 3000 "Backstage" "ia-ops-backstage" "scripts/start-development.sh"

echo ""
echo "3️⃣ Iniciando Veritas (Testing)..."
start_if_needed 8869 "Veritas" "ia-ops-veritas" "scripts/start-unified.sh"

echo ""
echo "🔍 Verificando estado final..."
sleep 3

echo ""
echo "📊 ESTADO FINAL:"
echo "================"

if is_port_active 8845; then
    echo "✅ Portal Docs: http://localhost:8845"
else
    echo "❌ Portal Docs: No disponible"
fi

if is_port_active 3000; then
    echo "✅ Backstage: http://localhost:3000"
else
    echo "❌ Backstage: No disponible"
fi

if is_port_active 8869; then
    echo "✅ Veritas: http://localhost:8869"
else
    echo "❌ Veritas: No disponible"
fi

echo ""
echo "🎯 URLs principales disponibles:"
echo "   🎭 Backstage: http://localhost:3000"
echo "   📚 Portal Docs: http://localhost:8845"
echo "   🚀 Dev-Core API: http://localhost:8801"
echo "   🤖 OpenAI API: http://localhost:8000"
echo "   📦 MinIO Console: http://localhost:9899"

echo ""
echo "✅ Proceso completado. Ejecuta './check-ports.sh' para verificación completa."
