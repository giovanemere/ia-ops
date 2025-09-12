#!/bin/bash

# Script para iniciar Backstage + MkDocs integrados
# Inicia ambos servicios de forma coordinada

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Iniciando IA-Ops Portal Integrado..."

# Función para verificar si un puerto está en uso
check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# Función para iniciar MkDocs en background
start_mkdocs() {
    echo "📖 Iniciando servidor MkDocs..."
    cd "$BASE_DIR/ia-ops-mkdocs"
    
    if check_port 8845; then
        echo "✅ MkDocs ya está corriendo en puerto 8845"
    else
        nohup ./start-server.sh > mkdocs.log 2>&1 &
        echo $! > mkdocs.pid
        echo "🌐 MkDocs iniciado en background (PID: $(cat mkdocs.pid))"
        sleep 3
    fi
}

# Función para iniciar Backstage
start_backstage() {
    echo "🎭 Iniciando Backstage..."
    cd "$BASE_DIR/ia-ops-backstage"
    
    if check_port 3000; then
        echo "✅ Backstage ya está corriendo en puerto 3000"
    else
        echo "📦 Instalando dependencias si es necesario..."
        yarn install --frozen-lockfile
        
        echo "🚀 Iniciando Backstage con configuración integrada..."
        yarn start --config app-config.development.yaml --config config/techdocs-mkdocs.yaml
    fi
}

# Función de limpieza
cleanup() {
    echo -e "\n🛑 Deteniendo servicios..."
    
    # Detener MkDocs si lo iniciamos nosotros
    if [ -f "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid" ]; then
        PID=$(cat "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid")
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo "🛑 MkDocs detenido"
        fi
        rm -f "$BASE_DIR/ia-ops-mkdocs/mkdocs.pid"
    fi
    
    exit 0
}

# Manejar señales
trap cleanup INT TERM

# Verificar dependencias
echo "🔍 Verificando servicios base..."
if ! check_port 9898; then
    echo "❌ MinIO no está corriendo. Iniciando servicios base..."
    cd "$BASE_DIR"
    ./scripts/manage.sh start
    sleep 5
fi

# Iniciar servicios
start_mkdocs
start_backstage

# Mantener el script corriendo
wait
