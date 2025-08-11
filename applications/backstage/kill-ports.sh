#!/bin/bash

# =============================================================================
# Matar Puertos de Backstage
# =============================================================================

echo "🔪 Matando procesos en puertos de Backstage..."

PORTS=(3000 3002 7007 8080 5432)
KILLED=0

for PORT in "${PORTS[@]}"; do
    PID=$(lsof -ti:$PORT 2>/dev/null)
    if [ ! -z "$PID" ]; then
        echo "🎯 Matando proceso $PID en puerto $PORT"
        kill -9 $PID 2>/dev/null
        KILLED=$((KILLED + 1))
    else
        echo "✅ Puerto $PORT ya está libre"
    fi
done

if [ $KILLED -gt 0 ]; then
    echo "💀 $KILLED procesos eliminados"
    sleep 2
    echo "🔍 Verificando puertos..."
    for PORT in "${PORTS[@]}"; do
        if lsof -ti:$PORT >/dev/null 2>&1; then
            echo "⚠️  Puerto $PORT aún ocupado"
        else
            echo "✅ Puerto $PORT libre"
        fi
    done
else
    echo "✅ Todos los puertos ya estaban libres"
fi

echo "✨ ¡Puertos listos para Backstage!"
