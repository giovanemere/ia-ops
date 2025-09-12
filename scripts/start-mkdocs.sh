#!/bin/bash

# Script para iniciar el servidor MkDocs TechDocs desde el sistema principal
# Integrado con el sistema de gestión IA-Ops

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
MKDOCS_DIR="$BASE_DIR/ia-ops-mkdocs"

echo "🚀 Iniciando MkDocs TechDocs Portal..."

# Verificar que existe el directorio
if [ ! -d "$MKDOCS_DIR" ]; then
    echo "❌ Directorio ia-ops-mkdocs no encontrado en: $MKDOCS_DIR"
    exit 1
fi

# Cambiar al directorio y ejecutar
cd "$MKDOCS_DIR"

# Verificar si ya está corriendo
if lsof -i:8845 >/dev/null 2>&1; then
    echo "⚠️  El servidor MkDocs ya está corriendo en puerto 8845"
    echo "🌐 Acceso directo: http://localhost:8845"
    echo "🔗 TechDocs URL: http://localhost:8845/techdocs"
    exit 0
fi

# Iniciar servidor
echo "📖 Iniciando servidor en puerto 8845..."
./start-server.sh
