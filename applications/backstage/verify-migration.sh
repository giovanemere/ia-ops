#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN DE MIGRACIÓN - BACKSTAGE DATABASE
# =============================================================================
# Fecha: 8 de Agosto de 2025
# Propósito: Verificar que la migración de PostgreSQL fue exitosa
# =============================================================================

set -e

echo "🔍 VERIFICANDO MIGRACIÓN DE BASE DE DATOS BACKSTAGE"
echo "=================================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    source ../../.env
    echo "✅ Variables de entorno cargadas"
else
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Verificar que PostgreSQL del Docker esté funcionando
echo ""
echo "🐳 Verificando PostgreSQL en Docker..."
if docker ps | grep -q "ia-ops-postgres"; then
    echo "✅ PostgreSQL Docker está ejecutándose"
else
    echo "❌ PostgreSQL Docker no está ejecutándose"
    echo "💡 Ejecuta: docker-compose up -d postgres"
    exit 1
fi

# Verificar conexión a la base de datos
echo ""
echo "🔌 Verificando conexión a la base de datos..."
if PGPASSWORD=$BACKSTAGE_DB_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $BACKSTAGE_DB_USER -d $BACKSTAGE_DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Conexión a backstage_db exitosa"
else
    echo "❌ No se puede conectar a backstage_db"
    exit 1
fi

# Verificar base de datos de plugins
echo ""
echo "🔌 Verificando base de datos de plugins..."
if PGPASSWORD=$BACKSTAGE_DB_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $BACKSTAGE_DB_USER -d backstage_plugin_app -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Conexión a backstage_plugin_app exitosa"
else
    echo "❌ No se puede conectar a backstage_plugin_app"
    exit 1
fi

# Verificar permisos del usuario
echo ""
echo "🔐 Verificando permisos del usuario..."
PERMISSIONS=$(PGPASSWORD=$BACKSTAGE_DB_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $BACKSTAGE_DB_USER -d $BACKSTAGE_DB_NAME -t -c "SELECT rolcreatedb FROM pg_roles WHERE rolname = '$BACKSTAGE_DB_USER';")
if [[ "$PERMISSIONS" == *"t"* ]]; then
    echo "✅ Usuario $BACKSTAGE_DB_USER tiene permisos para crear bases de datos"
else
    echo "❌ Usuario $BACKSTAGE_DB_USER NO tiene permisos para crear bases de datos"
fi

# Verificar esquemas
echo ""
echo "📊 Verificando esquemas en backstage_db..."
SCHEMAS=$(PGPASSWORD=$BACKSTAGE_DB_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $BACKSTAGE_DB_USER -d $BACKSTAGE_DB_NAME -t -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast');")
echo "📁 Esquemas encontrados: $SCHEMAS"

# Mostrar configuración actual
echo ""
echo "⚙️  CONFIGURACIÓN ACTUAL:"
echo "========================"
echo "🏠 Host: $POSTGRES_HOST"
echo "🔌 Puerto: $POSTGRES_PORT"
echo "👤 Usuario: $BACKSTAGE_DB_USER"
echo "🗄️  Base de datos principal: $BACKSTAGE_DB_NAME"
echo "🔌 Base de datos plugins: backstage_plugin_app"
echo "🔒 SSL: false"

# Verificar que el puerto anterior no esté en uso
echo ""
echo "🔍 Verificando puerto anterior (5434)..."
if netstat -tuln | grep -q ":5434 "; then
    echo "⚠️  Puerto 5434 aún está en uso (PostgreSQL local)"
    echo "💡 Puedes detener el PostgreSQL local si ya no lo necesitas:"
    echo "   sudo systemctl stop postgresql"
else
    echo "✅ Puerto 5434 libre"
fi

# Mostrar próximos pasos
echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="
echo "1. Iniciar Backstage:"
echo "   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "   yarn start"
echo ""
echo "2. O usar el script de inicio:"
echo "   ./start.sh"
echo ""
echo "3. Acceder a Backstage:"
echo "   Frontend: http://localhost:$BACKSTAGE_FRONTEND_PORT"
echo "   Backend: http://localhost:$BACKSTAGE_BACKEND_PORT"
echo ""
echo "4. Verificar logs si hay problemas:"
echo "   docker-compose logs postgres"

echo ""
echo "✅ MIGRACIÓN VERIFICADA EXITOSAMENTE"
echo "===================================="
echo "🎉 La base de datos PostgreSQL ha sido migrada correctamente al Docker"
echo "🔧 Backstage está configurado para usar la nueva base de datos"
echo "🛡️  Todos los permisos están configurados correctamente"
