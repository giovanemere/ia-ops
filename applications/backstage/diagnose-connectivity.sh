#!/bin/bash

# =============================================================================
# Diagnóstico de Conectividad de Backstage
# =============================================================================

set -e

echo "🔍 Diagnosticando conectividad de Backstage..."

# Cargar variables de entorno
source ../../.env

echo ""
echo "📋 Configuración de puertos:"
echo "=========================="
echo "• Frontend: $BACKSTAGE_FRONTEND_PORT"
echo "• Backend: $BACKSTAGE_BACKEND_PORT"
echo "• Base URL: $BACKSTAGE_BASE_URL"

echo ""
echo "🔍 Verificando puertos en uso:"
echo "=============================="
PORTS=($BACKSTAGE_FRONTEND_PORT $BACKSTAGE_BACKEND_PORT 8080 5432)
for PORT in "${PORTS[@]}"; do
    if lsof -ti:$PORT >/dev/null 2>&1; then
        PID=$(lsof -ti:$PORT)
        PROCESS=$(ps -p $PID -o comm= 2>/dev/null || echo "unknown")
        echo "🟢 Puerto $PORT: OCUPADO (PID: $PID, Proceso: $PROCESS)"
    else
        echo "🔴 Puerto $PORT: LIBRE"
    fi
done

echo ""
echo "🔍 Verificando conectividad:"
echo "============================"

# Verificar backend
echo -n "• Backend ($BACKSTAGE_BACKEND_PORT): "
if curl -s http://localhost:$BACKSTAGE_BACKEND_PORT/api/catalog/health >/dev/null 2>&1; then
    echo "✅ RESPONDE"
elif curl -s http://localhost:$BACKSTAGE_BACKEND_PORT >/dev/null 2>&1; then
    echo "⚠️  RESPONDE (sin auth)"
else
    echo "❌ NO RESPONDE"
fi

# Verificar frontend
echo -n "• Frontend ($BACKSTAGE_FRONTEND_PORT): "
if curl -s http://localhost:$BACKSTAGE_FRONTEND_PORT >/dev/null 2>&1; then
    echo "✅ RESPONDE"
else
    echo "❌ NO RESPONDE"
fi

# Verificar proxy
echo -n "• Proxy (8080): "
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ RESPONDE"
else
    echo "❌ NO RESPONDE"
fi

# Verificar PostgreSQL
echo -n "• PostgreSQL (5432): "
if command -v pg_isready &> /dev/null; then
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        echo "✅ RESPONDE"
    else
        echo "❌ NO RESPONDE"
    fi
else
    if lsof -ti:5432 >/dev/null 2>&1; then
        echo "⚠️  PUERTO OCUPADO (pg_isready no disponible)"
    else
        echo "❌ NO RESPONDE"
    fi
fi

echo ""
echo "🔍 Verificando configuración de red:"
echo "===================================="
echo "• Hostname: $(hostname)"
echo "• IP local: $(hostname -I | awk '{print $1}')"
echo "• Loopback: $(ping -c 1 127.0.0.1 >/dev/null 2>&1 && echo "✅ OK" || echo "❌ FALLO")"

echo ""
echo "🔍 URLs de acceso esperadas:"
echo "============================"
echo "• Frontend: http://localhost:$BACKSTAGE_FRONTEND_PORT"
echo "• Backend: http://localhost:$BACKSTAGE_BACKEND_PORT"
echo "• Proxy: http://localhost:8080"
echo "• Chat IA: http://localhost:8080/ai-chat"

echo ""
echo "💡 Recomendaciones:"
echo "=================="
if ! lsof -ti:$BACKSTAGE_FRONTEND_PORT >/dev/null 2>&1; then
    echo "⚠️  Frontend no está corriendo - iniciar Backstage"
fi
if ! lsof -ti:$BACKSTAGE_BACKEND_PORT >/dev/null 2>&1; then
    echo "⚠️  Backend no está corriendo - iniciar Backstage"
fi
if ! lsof -ti:5432 >/dev/null 2>&1; then
    echo "⚠️  PostgreSQL no está corriendo - ejecutar: docker-compose up -d postgres"
fi

echo ""
echo "✨ Diagnóstico completado!"
