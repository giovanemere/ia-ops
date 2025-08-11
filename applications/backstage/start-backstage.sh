#!/bin/bash

# =============================================================================
# Iniciar Backstage con Configuración Completa
# =============================================================================

set -e

echo "🚀 Iniciando Backstage con configuración completa..."
echo ""

# Paso 1: Configurar base de datos
echo "📋 Paso 1: Configurando base de datos..."
./setup-database.sh

echo ""

# Paso 2: Sincronizar configuración
echo "📋 Paso 2: Sincronizando configuración de variables de entorno..."
./sync-env-config.sh

echo ""
echo "🌐 Paso 3: Iniciando Backstage..."
echo ""
echo "📍 URLs disponibles:"
echo "   • Backstage Frontend: http://localhost:3000"
echo "   • Backstage Backend: http://localhost:7007"
echo "   • Chat de IA: http://localhost:8080/ai-chat"
echo ""
echo "⚙️ Configuración activa:"
echo "   • Modelo: gpt-4o-mini"
echo "   • Max Tokens: 150"
echo "   • Temperature: 0.7"
echo ""
echo "💡 Nota: Los índices de búsqueda se crearán automáticamente"
echo "   durante el primer inicio. Esto puede tomar unos minutos."
echo ""
echo "🔄 Iniciando servicios con dotenv..."
echo ""

# Paso 3: Iniciar con dotenv
exec dotenv -e ../../.env -- yarn start
