#!/bin/bash

# =============================================================================
# Iniciar Backstage con Variables de Entorno Correctas
# =============================================================================

set -e

echo "🚀 Iniciando Backstage con configuración de entorno..."

# Ruta al archivo .env principal
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

# Verificar que el archivo .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env en $ENV_FILE"
    exit 1
fi

echo "📋 Cargando variables de entorno desde $ENV_FILE"

# Cargar variables de entorno
set -a  # Exportar automáticamente todas las variables
source "$ENV_FILE"
set +a

# Verificar variables críticas
echo "🔍 Verificando variables críticas:"
echo "   • AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:0:10}..."
echo "   • AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
echo "   • GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}..."
echo "   • POSTGRES_USER: $POSTGRES_USER"
echo "   • POSTGRES_DB: $POSTGRES_DB"

# Verificar que las variables críticas están definidas
if [ -z "$AUTH_GITHUB_CLIENT_ID" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_ID no está definido"
    exit 1
fi

if [ -z "$AUTH_GITHUB_CLIENT_SECRET" ]; then
    echo "❌ Error: AUTH_GITHUB_CLIENT_SECRET no está definido"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no está definido"
    exit 1
fi

echo "✅ Variables de entorno cargadas correctamente"

# Ejecutar los scripts de preparación
echo "🔄 Ejecutando scripts de preparación..."

# Matar puertos ocupados
./kill-ports.sh

# Generar archivos de catálogo
./generate-catalog-files.sh

# Sincronizar configuración de entorno
./sync-env-config.sh

echo "🎯 Iniciando servicios de Backstage..."

# Iniciar backend en background
echo "🔧 Iniciando Backstage Backend..."
yarn dev --config app-config.yaml &
BACKEND_PID=$!

# Esperar a que el backend esté listo
echo "⏳ Esperando a que el backend esté listo..."
sleep 10

# Verificar que el backend está corriendo
if ! curl -s http://localhost:7007/api/catalog/entities > /dev/null; then
    echo "❌ Error: El backend no está respondiendo"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Backend iniciado correctamente"
echo "🌐 Backstage disponible en:"
echo "   • Frontend: http://localhost:3002"
echo "   • Backend API: http://localhost:7007"
echo "   • Via Proxy: http://localhost:8080"

echo ""
echo "📊 Estado de los servicios:"
echo "   • Backend PID: $BACKEND_PID"
echo "   • Logs: Revisa la consola para ver los logs en tiempo real"

echo ""
echo "🛑 Para detener Backstage:"
echo "   • Presiona Ctrl+C"
echo "   • O ejecuta: kill $BACKEND_PID"

# Mantener el script corriendo
wait $BACKEND_PID
