#!/bin/bash

# Script para iniciar el portal integrado completo
# MinIO + MkDocs + Portal Web + Backstage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Iniciando Portal Integrado IA-Ops..."
echo "======================================="

check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# 1. Servicios base (MinIO, PostgreSQL, Redis)
echo "📦 1. Verificando servicios base..."
if ! check_port 9898; then
    echo "   🔄 Iniciando servicios base..."
    cd "$BASE_DIR"
    ./scripts/manage.sh start
    sleep 5
else
    echo "   ✅ Servicios base activos"
fi

# 2. MkDocs TechDocs
echo "📖 2. Iniciando MkDocs TechDocs..."
if ! check_port 8845; then
    cd "$BASE_DIR/ia-ops-mkdocs"
    nohup ./start-server.sh > mkdocs.log 2>&1 &
    echo $! > mkdocs.pid
    sleep 3
    echo "   ✅ MkDocs iniciado (PID: $(cat mkdocs.pid))"
else
    echo "   ✅ MkDocs ya está corriendo"
fi

# 3. Portal Web Integrado
echo "🌐 3. Iniciando Portal Web..."
if ! check_port 8844; then
    cd "$BASE_DIR/ia-ops-mkdocs"
    nohup python3 portal-server.py > portal.log 2>&1 &
    echo $! > portal.pid
    sleep 2
    echo "   ✅ Portal Web iniciado (PID: $(cat portal.pid))"
else
    echo "   ✅ Portal Web ya está corriendo"
fi

# 4. Backstage (opcional)
echo "🎭 4. Verificando Backstage..."
if ! check_port 3000; then
    echo "   ⚠️  Backstage no está corriendo"
    echo "   💡 Para iniciarlo: cd ia-ops-backstage && yarn start"
else
    echo "   ✅ Backstage ya está corriendo"
fi

echo ""
echo "🎉 Portal Integrado IA-Ops Iniciado!"
echo "===================================="
echo "🌐 Portal Principal: http://localhost:8844"
echo "📖 MkDocs Directo: http://localhost:8845"
echo "📦 MinIO Console: http://localhost:9899"
echo "📊 MinIO Dashboard: http://localhost:6540"
echo "🎭 Backstage: http://localhost:3000"
echo ""
echo "💡 Accede al Portal Principal para navegar entre todos los servicios"

# Función de limpieza
cleanup() {
    echo -e "\n🛑 Deteniendo servicios..."
    
    if [ -f "$BASE_DIR/ia-ops-mkdocs/portal.pid" ]; then
        PID=$(cat "$BASE_DIR/ia-ops-mkdocs/portal.pid")
        if kill -0 $PID 2>/dev/null; then
            kill $PID && echo "🛑 Portal Web detenido"
        fi
        rm -f "$BASE_DIR/ia-ops-mkdocs/portal.pid"
    fi
    
    if [ -f "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid" ]; then
        PID=$(cat "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid")
        if kill -0 $PID 2>/dev/null; then
            kill $PID && echo "🛑 MkDocs detenido"
        fi
        rm -f "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid"
    fi
    
    exit 0
}

trap cleanup INT TERM

# Mantener el script corriendo
echo "Presiona Ctrl+C para detener todos los servicios"
while true; do
    sleep 10
    
    # Verificar que los servicios sigan corriendo
    if [ -f "$BASE_DIR/ia-ops-mkdocs/portal.pid" ]; then
        PID=$(cat "$BASE_DIR/ia-ops-mkdocs/portal.pid")
        if ! kill -0 $PID 2>/dev/null; then
            echo "⚠️  Portal Web se detuvo inesperadamente"
            break
        fi
    fi
done
