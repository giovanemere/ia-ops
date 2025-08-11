#!/bin/bash
# Script de verificación continua de configuración

BASE_DIR="/home/giovanemere/ia-ops/ia-ops"
source "$BASE_DIR/.env"

echo "🔍 Verificando configuración de Backstage..."

# Verificar variables críticas
CRITICAL_VARS=("AUTH_GITHUB_CLIENT_ID" "AUTH_GITHUB_CLIENT_SECRET" "GITHUB_TOKEN" "BACKEND_SECRET")
all_ok=true

for var in "${CRITICAL_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Falta: $var"
        all_ok=false
    fi
done

if [ "$all_ok" = true ]; then
    echo "✅ Todas las variables críticas están configuradas"
    exit 0
else
    echo "❌ Faltan variables críticas"
    exit 1
fi
