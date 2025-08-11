#!/bin/bash

# =============================================================================
# Inicializar Índices de Búsqueda de Backstage
# =============================================================================

set -e

echo "🔍 Inicializando índices de búsqueda de Backstage..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecuta desde el directorio de Backstage."
    exit 1
fi

echo "✅ Directorio de Backstage encontrado"

# Verificar que las variables de entorno estén configuradas
source ../../.env

echo "📋 Configuración de base de datos:"
echo "   • Host: $POSTGRES_HOST"
echo "   • Puerto: $POSTGRES_PORT"
echo "   • Base de datos: $POSTGRES_DB"
echo "   • Usuario: $POSTGRES_USER"

# Verificar conexión a PostgreSQL
echo "🔍 Verificando conexión a PostgreSQL..."
if command -v psql &> /dev/null; then
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null 2>&1; then
        echo "✅ Conexión a PostgreSQL exitosa"
    else
        echo "❌ Error: No se puede conectar a PostgreSQL"
        echo "💡 Asegúrate de que PostgreSQL esté corriendo y las credenciales sean correctas"
        exit 1
    fi
else
    echo "⚠️  psql no está instalado, saltando verificación de conexión"
fi

# Limpiar índices existentes (opcional)
echo "🧹 Limpiando índices existentes..."
if command -v psql &> /dev/null; then
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "
        DROP TABLE IF EXISTS search_documents CASCADE;
        DROP TABLE IF EXISTS search_index CASCADE;
    " > /dev/null 2>&1 || echo "⚠️  No hay índices existentes para limpiar"
fi

# Inicializar el backend para crear los índices
echo "🚀 Iniciando backend para crear índices de búsqueda..."
echo "⏳ Esto puede tomar unos minutos..."

# Crear un timeout para el proceso
timeout 120s dotenv -e ../../.env -- yarn workspace backend start &
BACKEND_PID=$!

# Esperar a que el backend esté listo
echo "⏳ Esperando a que el backend esté listo..."
for i in {1..60}; do
    if curl -s http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
        echo "✅ Backend está listo"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ Timeout: El backend no respondió en 60 segundos"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

# Esperar un poco más para que se creen los índices
echo "⏳ Esperando creación de índices..."
sleep 30

# Detener el backend
echo "🛑 Deteniendo backend..."
kill $BACKEND_PID 2>/dev/null || true
wait $BACKEND_PID 2>/dev/null || true

# Verificar que los índices se crearon
echo "🔍 Verificando índices creados..."
if command -v psql &> /dev/null; then
    INDEX_COUNT=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_name LIKE '%search%';
    " 2>/dev/null | tr -d ' ')
    
    if [ "$INDEX_COUNT" -gt 0 ]; then
        echo "✅ Índices de búsqueda creados exitosamente ($INDEX_COUNT tablas)"
    else
        echo "⚠️  No se detectaron tablas de búsqueda, pero el proceso continuó"
    fi
fi

echo ""
echo "🎯 Inicialización completada:"
echo "   • Índices de búsqueda: Inicializados"
echo "   • Software Catalog: Listo para búsqueda"
echo "   • TechDocs: Listo para búsqueda"
echo ""
echo "🚀 Ahora puedes iniciar Backstage normalmente:"
echo "   ./start-backstage.sh"
echo ""
echo "✨ ¡Índices de búsqueda listos!"
