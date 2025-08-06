#!/bin/bash
echo "🚀 Iniciando Backstage en modo desarrollo..."
echo "📊 Backend: http://localhost:7007"
echo "🌐 Frontend: http://localhost:3000"
echo ""
echo "⚠️  Presiona Ctrl+C para detener"
echo ""

# Cargar variables de entorno
export $(grep -v '^#' ../../.env | xargs)

# Iniciar Backstage
yarn dev --config app-config.yaml --config app-config.local.yaml
