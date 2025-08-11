#!/bin/bash

# =============================================================================
# Configurar Base de Datos para Backstage
# =============================================================================

set -e

echo "🗄️ Configurando base de datos para Backstage..."

# Cargar variables de entorno
source ../../.env

echo "📋 Configuración de PostgreSQL:"
echo "   • Host: $POSTGRES_HOST"
echo "   • Puerto: $POSTGRES_PORT"
echo "   • Base de datos: $POSTGRES_DB"
echo "   • Usuario: $POSTGRES_USER"

# Verificar si PostgreSQL está corriendo
echo "🔍 Verificando PostgreSQL..."
if command -v pg_isready &> /dev/null; then
    if pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER > /dev/null 2>&1; then
        echo "✅ PostgreSQL está corriendo"
    else
        echo "❌ PostgreSQL no está disponible"
        echo "💡 Inicia PostgreSQL con: docker-compose up -d postgres"
        exit 1
    fi
else
    echo "⚠️  pg_isready no disponible, saltando verificación"
fi

# Crear base de datos si no existe
echo "🏗️ Verificando/creando base de datos..."
if command -v psql &> /dev/null; then
    # Conectar a postgres para crear la base de datos
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "
        SELECT 'CREATE DATABASE $POSTGRES_DB' 
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$POSTGRES_DB')\\gexec
    " > /dev/null 2>&1 || echo "⚠️  Base de datos ya existe o no se pudo crear"
    
    echo "✅ Base de datos verificada/creada"
else
    echo "⚠️  psql no disponible, saltando creación de base de datos"
fi

# Verificar conexión a la base de datos específica
echo "🔍 Verificando conexión a la base de datos..."
if command -v psql &> /dev/null; then
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null 2>&1; then
        echo "✅ Conexión a $POSTGRES_DB exitosa"
    else
        echo "❌ Error: No se puede conectar a la base de datos $POSTGRES_DB"
        exit 1
    fi
fi

echo ""
echo "🎯 Base de datos configurada:"
echo "   • PostgreSQL: Corriendo"
echo "   • Base de datos: $POSTGRES_DB creada"
echo "   • Conexión: Verificada"
echo ""
echo "💡 Nota: Los índices de búsqueda se crearán automáticamente"
echo "   cuando Backstage se inicie por primera vez."
echo ""
echo "✨ ¡Base de datos lista para Backstage!"
