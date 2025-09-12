#!/bin/bash

# Script para iniciar el portal completo IA-Ops
# Incluye: MinIO + MkDocs + Backstage integrados

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Iniciando Portal Completo IA-Ops..."
echo "=================================="

# Función para verificar puertos
check_port() {
    lsof -i:$1 >/dev/null 2>&1
}

# 1. Verificar e iniciar servicios base
echo "📦 1. Verificando servicios base..."
if ! check_port 9898; then
    echo "   🔄 Iniciando MinIO y servicios base..."
    cd "$BASE_DIR"
    ./scripts/manage.sh start
    sleep 5
else
    echo "   ✅ MinIO ya está corriendo"
fi

# 2. Iniciar MkDocs TechDocs
echo "📖 2. Iniciando MkDocs TechDocs..."
if ! check_port 8845; then
    echo "   🔄 Iniciando servidor MkDocs..."
    cd "$BASE_DIR/ia-ops-mkdocs"
    nohup ./start-server.sh > mkdocs.log 2>&1 &
    echo $! > mkdocs.pid
    sleep 5
    echo "   ✅ MkDocs iniciado (PID: $(cat mkdocs.pid))"
else
    echo "   ✅ MkDocs ya está corriendo"
fi

# 3. Iniciar Backstage
echo "🎭 3. Iniciando Backstage Portal..."
if ! check_port 3000; then
    echo "   📦 Preparando Backstage..."
    cd "$BASE_DIR/ia-ops-backstage"
    
    # Instalar dependencias si es necesario
    if [ ! -d "node_modules" ]; then
        echo "   📦 Instalando dependencias..."
        yarn install --frozen-lockfile
    fi
    
    echo "   🚀 Iniciando Backstage..."
    yarn start --config app-config.development.yaml
else
    echo "   ✅ Backstage ya está corriendo"
fi

echo ""
echo "🌐 Portal IA-Ops Iniciado Completamente!"
echo "========================================"
echo "📖 MkDocs TechDocs: http://localhost:8845"
echo "🎭 Backstage Portal: http://localhost:3000"
echo "📦 MinIO Console: http://localhost:9899"
echo ""
echo "En Backstage, ve a '📖 TechDocs' para ver la documentación integrada"
