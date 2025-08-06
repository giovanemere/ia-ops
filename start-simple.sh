#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - INICIO SIMPLE
# =============================================================================
# USA TUS VARIABLES .ENV EXACTAS - SIN COMPILACIÓN COMPLEJA

set -e

echo "🚀 Iniciando IA-Ops Platform (Modo Simple)"

# Verificar .env
if [ ! -f .env ]; then
    echo "❌ Error: .env no encontrado"
    exit 1
fi

echo "✅ Usando variables de .env existente"

# Parar servicios existentes
echo "🛑 Parando servicios..."
docker-compose down 2>/dev/null || true

# Usar override simple (sin compilación)
echo "🚀 Iniciando con configuración simple..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

echo ""
echo "🎉 IA-Ops Platform iniciado!"
echo ""
echo "📋 URLs:"
echo "   🌐 Proxy:     http://localhost:8080"
echo "   🏛️ Backstage: http://localhost:7007"
echo "   🤖 OpenAI:    http://localhost:8000"
echo ""
echo "🔍 Ver estado:"
echo "   docker-compose ps"
echo ""

# Verificar servicios
sleep 5
echo "🔍 Estado de servicios:"
docker-compose ps
