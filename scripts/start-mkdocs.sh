#!/bin/bash
# Script para iniciar MkDocs Multi-Repositorio

MKDOCS_DIR="/home/giovanemere/ia-ops/ia-ops-mkdocs"

echo "🚀 Iniciando MkDocs Multi-Repositorio..."

# Verificar si ya está corriendo
if pgrep -f "mkdocs-server.py" > /dev/null; then
    echo "✅ MkDocs ya está corriendo"
    echo "🌐 Disponible en: http://localhost:8854/"
    exit 0
fi

# Iniciar servicio
cd "$MKDOCS_DIR"
if [ -f "mkdocs-env/bin/activate" ]; then
    source mkdocs-env/bin/activate
    nohup python3 mkdocs-server.py > mkdocs.log 2>&1 &
    sleep 3
    
    if pgrep -f "mkdocs-server.py" > /dev/null; then
        echo "✅ MkDocs iniciado correctamente"
        echo "🌐 URL: http://localhost:8854/"
        echo "📖 Repositorios: http://localhost:8854/{repo}/"
    else
        echo "❌ Error iniciando MkDocs"
        exit 1
    fi
else
    echo "❌ Entorno virtual no encontrado"
    echo "💡 Ejecuta: cd $MKDOCS_DIR && python3 -m venv mkdocs-env"
    exit 1
fi
