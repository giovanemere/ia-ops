#!/bin/bash

# Script para iniciar todos los servicios Python

BASE_DIR="/home/giovanemere/ia-ops"

echo "🐍 Iniciando servicios Python..."

# ia-ops-docs
if [ -d "$BASE_DIR/ia-ops-docs" ]; then
    echo "📚 Iniciando ia-ops-docs..."
    cd "$BASE_DIR/ia-ops-docs"
    nohup python3 app.py > docs.log 2>&1 &
    echo "   PID: $!"
fi

# ia-ops-dev-core  
if [ -d "$BASE_DIR/ia-ops-dev-core" ]; then
    echo "🔧 Iniciando ia-ops-dev-core..."
    cd "$BASE_DIR/ia-ops-dev-core"
    nohup python3 main.py > dev-core.log 2>&1 &
    echo "   PID: $!"
fi

# ia-ops-mkdocs
if [ -d "$BASE_DIR/ia-ops-mkdocs" ]; then
    echo "📖 Iniciando ia-ops-mkdocs..."
    cd "$BASE_DIR/ia-ops-mkdocs"
    nohup python3 simple-techdocs-server.py > techdocs.log 2>&1 &
    echo "   TechDocs PID: $!"
    nohup python3 portal-server.py > portal.log 2>&1 &
    echo "   Portal PID: $!"
fi

echo "✅ Servicios Python iniciados"
