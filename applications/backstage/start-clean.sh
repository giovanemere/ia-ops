#!/bin/bash

echo "🚀 INICIANDO BACKSTAGE - INSTALACIÓN LIMPIA OFICIAL"
echo "=================================================="
echo ""
echo "✅ Instalación: Backstage oficial con create-app"
echo "✅ Base de datos: PostgreSQL con migraciones automáticas"
echo "✅ Configuración: Siguiendo plan de implementación"
echo ""

# Verificar que PostgreSQL esté ejecutándose
echo "🔍 Verificando PostgreSQL..."
if ! docker exec ia-ops-postgres psql -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ PostgreSQL no está ejecutándose. Iniciando..."
    cd /home/giovanemere/ia-ops/ia-ops && docker-compose up -d postgres
    sleep 10
fi

echo "✅ PostgreSQL funcionando correctamente"
echo ""

# Cargar variables de entorno desde el archivo .env
echo "🔧 Cargando variables de entorno..."
if [ -f "../../.env" ]; then
    export $(grep -v '^#' ../../.env | xargs)
    echo "✅ Variables de entorno cargadas desde .env"
else
    echo "⚠️  Archivo .env no encontrado, usando valores por defecto"
    # Configurar variables de entorno por defecto
    export POSTGRES_HOST=localhost
    export POSTGRES_PORT=5432
    export POSTGRES_USER=backstage_user
    export POSTGRES_PASSWORD=backstage_pass_2025
    export POSTGRES_DB=backstage_db
    export BACKEND_SECRET=your-secret-key-here-change-in-production
    export GITHUB_TOKEN=your-github-token-here
fi

echo ""
echo "🔍 Variables de entorno configuradas:"
echo "   POSTGRES_HOST: ${POSTGRES_HOST}"
echo "   POSTGRES_PORT: ${POSTGRES_PORT}"
echo "   POSTGRES_USER: ${POSTGRES_USER}"
echo "   POSTGRES_DB: ${POSTGRES_DB}"
echo ""

echo "🌐 URLs de acceso:"
echo "   Frontend: http://localhost:3002"
echo "   Backend:  http://localhost:7007"
echo ""
echo "📋 Próximos pasos según el plan:"
echo "   1. ✅ Infraestructura base - COMPLETADO"
echo "   2. 🔄 Instalar plugins específicos (OpenAI, MkDocs, GitHub, etc.)"
echo "   3. 🔄 Configurar Asistente DevOps IA"
echo "   4. 🔄 Integrar aplicaciones BillPay e ICBS"
echo ""
echo "⚠️  Presiona Ctrl+C para detener"
echo ""

# Iniciar Backstage
yarn start
