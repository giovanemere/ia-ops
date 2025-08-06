#!/bin/bash

# Script para matar todos los procesos de Backstage
# Uso: ./kill-backstage.sh

echo "🔴 Matando procesos de Backstage..."

# Matar procesos por puerto
sudo fuser -k 3000/tcp 2>/dev/null
sudo fuser -k 7007/tcp 2>/dev/null

# Matar procesos de Node.js relacionados
sudo pkill -f "backstage" 2>/dev/null
sudo pkill -f "yarn.*start" 2>/dev/null
sudo pkill -f "node.*backstage" 2>/dev/null

# Detener contenedores Docker
cd /home/giovanemere/ia-ops/ia-ops
docker-compose stop backstage-frontend backstage-backend 2>/dev/null

# Verificar que los puertos estén libres
echo "📊 Verificando puertos..."
if sudo netstat -tlnp | grep -E ":3000|:7007" > /dev/null; then
    echo "⚠️  Algunos puertos aún están en uso:"
    sudo netstat -tlnp | grep -E ":3000|:7007"
else
    echo "✅ Puertos 3000 y 7007 están libres"
fi

# Cambiar al directorio de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
echo "📁 Directorio actual: $(pwd)"

echo "✅ Procesos de Backstage eliminados"
