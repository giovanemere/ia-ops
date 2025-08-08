#!/bin/bash
# =============================================================================
# IA-OPS PLATFORM - DATABASE UPDATE SCRIPT
# =============================================================================
# Descripción: Script para aplicar la separación de bases de datos
# =============================================================================

echo "🔄 Actualizando configuración de bases de datos..."

# Crear directorio de scripts si no existe
mkdir -p scripts

# Parar servicios actuales
echo "⏹️ Parando servicios actuales..."
docker-compose down

# Limpiar volúmenes de base de datos (CUIDADO: Esto borra datos existentes)
echo "🗑️ Limpiando volúmenes de base de datos..."
docker volume rm ia-ops_postgres_data 2>/dev/null || true

# Reconstruir y iniciar servicios
echo "🏗️ Reconstruyendo servicios..."
docker-compose build --no-cache postgres

echo "🚀 Iniciando servicios con nueva configuración..."
docker-compose up -d postgres redis

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 30

# Verificar que las bases de datos se crearon correctamente
echo "🔍 Verificando bases de datos creadas..."
docker-compose exec postgres psql -U postgres -c "\l"

# Iniciar el resto de servicios
echo "🚀 Iniciando todos los servicios..."
docker-compose up -d

echo "✅ Actualización completada!"
echo ""
echo "📊 Bases de datos separadas:"
echo "  - backstage_db (puerto 5432) → Backstage"
echo "  - grafana_db (puerto 5432) → Grafana"  
echo "  - monitoring_db (puerto 5432) → OpenAI Service"
echo ""
echo "📚 MkDocs (puerto 8005) → Sin base de datos (solo archivos)"
echo ""
echo "🌐 URLs de acceso:"
echo "  - Proxy Gateway: http://localhost:8080"
echo "  - Backstage: http://localhost:3002"
echo "  - MkDocs: http://localhost:8005"
echo "  - Grafana: http://localhost:3001"
echo ""
echo "🔧 Para verificar el estado:"
echo "  docker-compose ps"
echo "  docker-compose logs -f [servicio]"
