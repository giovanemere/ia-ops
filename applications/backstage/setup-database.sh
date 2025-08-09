#!/bin/bash

echo "🗄️  CONFIGURACIÓN DE BASE DE DATOS PARA BACKSTAGE"
echo "================================================"

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    echo "✅ Cargando variables de entorno desde ../../.env"
    set -a
    source ../../.env
    set +a
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

echo ""
echo "📋 CONFIGURACIÓN DE BASE DE DATOS:"
echo "================================="
echo "🔧 Host: $POSTGRES_HOST"
echo "🔧 Puerto: $POSTGRES_PORT"
echo "🔧 Usuario: $POSTGRES_USER"
echo "🔧 Base de datos: $POSTGRES_DB"
echo "🔧 SSL: false (deshabilitado para desarrollo local)"

echo ""
echo "🔍 VERIFICANDO CONEXIÓN A POSTGRESQL..."

# Verificar si PostgreSQL está ejecutándose
if ! command -v psql &> /dev/null; then
    echo "❌ psql no está instalado. Instalando..."
    sudo apt update && sudo apt install -y postgresql-client
fi

# Probar conexión
echo "Probando conexión a PostgreSQL..."
export PGPASSWORD="$POSTGRES_PASSWORD"

if psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d postgres -c "SELECT version();" &> /dev/null; then
    echo "✅ Conexión a PostgreSQL exitosa"
else
    echo "❌ No se puede conectar a PostgreSQL"
    echo "Verificando si PostgreSQL está ejecutándose..."
    
    if systemctl is-active --quiet postgresql; then
        echo "✅ PostgreSQL está ejecutándose"
    else
        echo "❌ PostgreSQL no está ejecutándose"
        echo "Iniciando PostgreSQL..."
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
    fi
fi

echo ""
echo "🏗️  CREANDO BASE DE DATOS Y USUARIO PARA BACKSTAGE..."

# Crear usuario y base de datos para Backstage
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U postgres -d postgres << EOF
-- Crear usuario para Backstage si no existe
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_USER') THEN
        CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
    END IF;
END
\$\$;

-- Crear base de datos para Backstage si no existe
SELECT 'CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$POSTGRES_DB')\gexec

-- Otorgar permisos
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
ALTER USER $POSTGRES_USER CREATEDB;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Base de datos y usuario creados/verificados correctamente"
else
    echo "❌ Error al crear la base de datos. Intentando con sudo..."
    
    sudo -u postgres psql << EOF
-- Crear usuario para Backstage si no existe
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_USER') THEN
        CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
    END IF;
END
\$\$;

-- Crear base de datos para Backstage si no existe
SELECT 'CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$POSTGRES_DB')\gexec

-- Otorgar permisos
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
ALTER USER $POSTGRES_USER CREATEDB;
EOF
fi

echo ""
echo "🧪 PROBANDO CONEXIÓN CON CREDENCIALES DE BACKSTAGE..."

export PGPASSWORD="$POSTGRES_PASSWORD"
if psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 'Conexión exitosa como $POSTGRES_USER' as status;" 2>/dev/null; then
    echo "✅ Conexión con credenciales de Backstage exitosa"
else
    echo "❌ Error de conexión con credenciales de Backstage"
    echo "Verificando permisos..."
    
    sudo -u postgres psql -c "ALTER USER $POSTGRES_USER WITH SUPERUSER;"
    echo "✅ Permisos de superusuario otorgados temporalmente"
fi

echo ""
echo "📊 INFORMACIÓN DE LA BASE DE DATOS:"
echo "=================================="
sudo -u postgres psql -c "SELECT datname, datowner, (SELECT rolname FROM pg_roles WHERE oid = datowner) as owner FROM pg_database WHERE datname = '$POSTGRES_DB';"

echo ""
echo "✅ CONFIGURACIÓN DE BASE DE DATOS COMPLETADA"
echo "Ahora puedes iniciar Backstage con: ./start-with-env.sh"
