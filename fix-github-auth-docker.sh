#!/bin/bash

# =============================================================================
# Fix GitHub Authentication Variables in Docker Compose
# =============================================================================

set -e

echo "🔧 Corrigiendo variables de autenticación de GitHub en docker-compose.yml..."

# Archivos a modificar
DOCKER_COMPOSE_FILE="/home/giovanemere/ia-ops/ia-ops/docker-compose.yml"
ENV_FILE="/home/giovanemere/ia-ops/ia-ops/.env"

# Verificar que los archivos existen
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "❌ Error: No se encontró docker-compose.yml en $DOCKER_COMPOSE_FILE"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró .env en $ENV_FILE"
    exit 1
fi

echo "✅ Archivos encontrados"

# Leer variables del .env
source "$ENV_FILE"

echo "📋 Variables de GitHub encontradas:"
echo "   • GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}..."
echo "   • AUTH_GITHUB_CLIENT_ID: $AUTH_GITHUB_CLIENT_ID"
echo "   • AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:0:10}..."
echo "   • AUTH_GITHUB_CALLBACK_URL: $AUTH_GITHUB_CALLBACK_URL"

# Crear backup del docker-compose.yml
BACKUP_FILE="${DOCKER_COMPOSE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$DOCKER_COMPOSE_FILE" "$BACKUP_FILE"
echo "💾 Backup creado: $BACKUP_FILE"

# Verificar si las variables ya están en el docker-compose.yml
if grep -q "AUTH_GITHUB_CLIENT_ID:" "$DOCKER_COMPOSE_FILE"; then
    echo "✅ Variables de GitHub ya están presentes en docker-compose.yml"
else
    echo "⚠️  Variables de GitHub no encontradas en docker-compose.yml"
fi

# Crear un archivo temporal con las correcciones
TEMP_FILE=$(mktemp)

# Procesar el docker-compose.yml línea por línea
while IFS= read -r line; do
    echo "$line" >> "$TEMP_FILE"
    
    # Si encontramos la línea de GITHUB_TOKEN, agregar las variables de auth faltantes
    if [[ "$line" == *"GITHUB_TOKEN:"* ]]; then
        # Verificar si las siguientes líneas ya contienen las variables de auth
        if ! grep -A 10 "GITHUB_TOKEN:" "$DOCKER_COMPOSE_FILE" | grep -q "AUTH_GITHUB_CLIENT_ID:"; then
            echo "      AUTH_GITHUB_CLIENT_ID: \${AUTH_GITHUB_CLIENT_ID:-}" >> "$TEMP_FILE"
            echo "      AUTH_GITHUB_CLIENT_SECRET: \${AUTH_GITHUB_CLIENT_SECRET:-}" >> "$TEMP_FILE"
            echo "      AUTH_GITHUB_CALLBACK_URL: \${AUTH_GITHUB_CALLBACK_URL:-}" >> "$TEMP_FILE"
            echo "🔧 Agregadas variables de autenticación de GitHub"
        fi
    fi
done < "$DOCKER_COMPOSE_FILE"

# Reemplazar el archivo original
mv "$TEMP_FILE" "$DOCKER_COMPOSE_FILE"

echo "✅ docker-compose.yml actualizado"

# Verificar que las variables están ahora presentes
echo "🔍 Verificando variables en docker-compose.yml..."
if grep -q "AUTH_GITHUB_CLIENT_ID:" "$DOCKER_COMPOSE_FILE" && \
   grep -q "AUTH_GITHUB_CLIENT_SECRET:" "$DOCKER_COMPOSE_FILE" && \
   grep -q "AUTH_GITHUB_CALLBACK_URL:" "$DOCKER_COMPOSE_FILE"; then
    echo "✅ Todas las variables de GitHub están presentes"
else
    echo "❌ Error: Algunas variables de GitHub siguen faltando"
    echo "🔄 Restaurando backup..."
    mv "$BACKUP_FILE" "$DOCKER_COMPOSE_FILE"
    exit 1
fi

# Mostrar las líneas relevantes
echo ""
echo "📋 Variables de GitHub en docker-compose.yml:"
grep -A 5 -B 2 "GITHUB_TOKEN:" "$DOCKER_COMPOSE_FILE" | head -10

echo ""
echo "🎯 Próximos pasos:"
echo "1. Reiniciar los servicios de Backstage:"
echo "   cd /home/giovanemere/ia-ops/ia-ops"
echo "   docker-compose restart backstage-backend backstage-frontend"
echo ""
echo "2. O ejecutar el comando completo:"
echo "   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "   ./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh"
echo ""
echo "✨ ¡Corrección completada!"
