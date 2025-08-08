#!/bin/bash

# =============================================================================
# MONITOR BACKSTAGE - ESTADO EN TIEMPO REAL
# =============================================================================

echo "🔍 Monitoreando Backstage con OpenAI..."
echo "Presiona Ctrl+C para salir"
echo

while true; do
    clear
    echo "🤖 IA-Ops Platform - Monitor de Estado"
    echo "========================================"
    echo "Fecha: $(date)"
    echo

    # Estado de contenedores
    echo "📦 CONTENEDORES:"
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(postgres|backstage)"; then
        echo "✅ Contenedores encontrados"
    else
        echo "❌ No hay contenedores corriendo"
    fi
    echo

    # Estado de PostgreSQL
    echo "🗄️  POSTGRESQL:"
    if docker exec ia-ops-postgres pg_isready -U postgres 2>/dev/null; then
        echo "✅ PostgreSQL está listo"
    else
        echo "❌ PostgreSQL no responde"
    fi
    echo

    # Estado de Backstage Backend
    echo "🔧 BACKSTAGE BACKEND:"
    if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
        echo "✅ Backend API funcionando (puerto 7007)"
        entity_count=$(curl -s "http://localhost:7007/api/catalog/entities" | jq '. | length' 2>/dev/null || echo "?")
        echo "📊 Entidades en catálogo: $entity_count"
    else
        echo "⏳ Backend iniciando o no disponible"
    fi
    echo

    # Estado de Backstage Frontend
    echo "🎭 BACKSTAGE FRONTEND:"
    if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
        echo "✅ Frontend funcionando (puerto 3000)"
    else
        echo "⏳ Frontend iniciando o no disponible"
    fi
    echo

    # Estado de OpenAI Proxy
    echo "🤖 OPENAI PROXY:"
    if curl -s -f "http://localhost:7007/api/proxy/openai/models" >/dev/null 2>&1; then
        echo "✅ Proxy OpenAI funcionando"
    else
        echo "⏳ Proxy OpenAI no disponible"
    fi
    echo

    # Últimos logs
    echo "📋 ÚLTIMOS LOGS:"
    docker logs ia-ops-backstage --tail=3 2>/dev/null | sed 's/^/   /'
    echo

    # URLs de acceso
    echo "🌐 ACCESO:"
    echo "   Frontend: http://localhost:3000"
    echo "   Backend:  http://localhost:7007"
    echo "   Test OpenAI: file://$(pwd)/openai-test.html"
    echo

    sleep 10
done
