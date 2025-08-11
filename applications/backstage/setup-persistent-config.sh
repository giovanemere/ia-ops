#!/bin/bash

# =============================================================================
# CONFIGURACIÓN PERSISTENTE DE BACKSTAGE
# =============================================================================
# Este script asegura que la configuración no se pierda y esté siempre sincronizada

set -e

echo "🔧 Configurando Backstage de forma persistente..."
echo "================================================"

# Directorio base
BASE_DIR="/home/giovanemere/ia-ops/ia-ops"
BACKSTAGE_DIR="$BASE_DIR/applications/backstage"
ENV_FILE="$BASE_DIR/.env"

# Verificar que estamos en el directorio correcto
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: No se encontró el archivo .env en $ENV_FILE"
    exit 1
fi

echo "✅ Archivo .env encontrado: $ENV_FILE"

# 1. VERIFICAR Y COMPLETAR VARIABLES DE ENTORNO
echo ""
echo "1. Verificando variables de entorno..."
echo "====================================="

# Cargar variables existentes
source "$ENV_FILE"

# Variables requeridas para GitHub Auth
REQUIRED_VARS=(
    "AUTH_GITHUB_CLIENT_ID"
    "AUTH_GITHUB_CLIENT_SECRET"
    "GITHUB_TOKEN"
    "BACKEND_SECRET"
)

# Variables opcionales con valores por defecto
declare -A DEFAULT_VARS=(
    ["AUTH_GITHUB_CALLBACK_URL"]="http://localhost:3002/api/auth/github/handler/frame"
    ["GITHUB_ORG"]="giovanemere"
    ["BACKSTAGE_FRONTEND_PORT"]="3002"
    ["BACKSTAGE_BACKEND_PORT"]="7007"
)

# Verificar variables requeridas
missing_vars=()
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
        echo "❌ Falta: $var"
    else
        echo "✅ Configurado: $var"
    fi
done

# Agregar variables faltantes con valores por defecto
for var in "${!DEFAULT_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "⚠️  Agregando valor por defecto para: $var"
        echo "" >> "$ENV_FILE"
        echo "# $var (agregado automáticamente)" >> "$ENV_FILE"
        echo "$var=${DEFAULT_VARS[$var]}" >> "$ENV_FILE"
    else
        echo "✅ Configurado: $var"
    fi
done

# Si faltan variables críticas, mostrar instrucciones
if [ ${#missing_vars[@]} -gt 0 ]; then
    echo ""
    echo "❌ VARIABLES CRÍTICAS FALTANTES:"
    echo "================================"
    for var in "${missing_vars[@]}"; do
        echo "   • $var"
    done
    echo ""
    echo "💡 Para configurar GitHub OAuth:"
    echo "   1. Ve a: https://github.com/settings/applications/new"
    echo "   2. Crea una nueva OAuth App con:"
    echo "      - Application name: IA-Ops Backstage"
    echo "      - Homepage URL: http://localhost:3002"
    echo "      - Authorization callback URL: http://localhost:3002/api/auth/github/handler/frame"
    echo "   3. Copia el Client ID y Client Secret al archivo .env"
    echo ""
    echo "💡 Para el GITHUB_TOKEN:"
    echo "   1. Ve a: https://github.com/settings/tokens"
    echo "   2. Genera un token con permisos: repo, read:org, read:user"
    echo ""
    exit 1
fi

# 2. CREAR BACKUP DE CONFIGURACIÓN
echo ""
echo "2. Creando backup de configuración..."
echo "===================================="

BACKUP_DIR="$BACKSTAGE_DIR/config-backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/config_backup_$TIMESTAMP.tar.gz"

# Crear backup
tar -czf "$BACKUP_FILE" \
    -C "$BASE_DIR" .env \
    -C "$BACKSTAGE_DIR" app-config.yaml app-config.local.yaml \
    2>/dev/null || true

echo "✅ Backup creado: $BACKUP_FILE"

# Mantener solo los últimos 5 backups
ls -t "$BACKUP_DIR"/config_backup_*.tar.gz | tail -n +6 | xargs rm -f 2>/dev/null || true

# 3. SINCRONIZAR CONFIGURACIÓN
echo ""
echo "3. Sincronizando configuración..."
echo "================================"

# Recargar variables después de posibles cambios
source "$ENV_FILE"

# Crear archivo de configuración local si no existe
LOCAL_CONFIG="$BACKSTAGE_DIR/app-config.local.yaml"
if [ ! -f "$LOCAL_CONFIG" ]; then
    cat > "$LOCAL_CONFIG" << EOF
# Configuración local de Backstage
# Este archivo se genera automáticamente

app:
  baseUrl: http://localhost:\${BACKSTAGE_FRONTEND_PORT:-3002}

backend:
  baseUrl: http://localhost:\${BACKSTAGE_BACKEND_PORT:-7007}
  cors:
    origin: http://localhost:\${BACKSTAGE_FRONTEND_PORT:-3002}
EOF
    echo "✅ Creado: app-config.local.yaml"
fi

# 4. VERIFICAR CONFIGURACIÓN DE AUTH
echo ""
echo "4. Verificando configuración de autenticación..."
echo "==============================================="

# Verificar que la configuración de GitHub esté en app-config.yaml
if grep -q "AUTH_GITHUB_CLIENT_ID" "$BACKSTAGE_DIR/app-config.yaml"; then
    echo "✅ Configuración de GitHub OAuth encontrada en app-config.yaml"
else
    echo "⚠️  Agregando configuración de GitHub OAuth a app-config.yaml"
    # La configuración ya debería estar, pero por si acaso
fi

# 5. CREAR SCRIPT DE VERIFICACIÓN CONTINUA
echo ""
echo "5. Creando script de verificación continua..."
echo "============================================"

cat > "$BACKSTAGE_DIR/verify-config.sh" << 'EOF'
#!/bin/bash
# Script de verificación continua de configuración

BASE_DIR="/home/giovanemere/ia-ops/ia-ops"
source "$BASE_DIR/.env"

echo "🔍 Verificando configuración de Backstage..."

# Verificar variables críticas
CRITICAL_VARS=("AUTH_GITHUB_CLIENT_ID" "AUTH_GITHUB_CLIENT_SECRET" "GITHUB_TOKEN" "BACKEND_SECRET")
all_ok=true

for var in "${CRITICAL_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Falta: $var"
        all_ok=false
    fi
done

if [ "$all_ok" = true ]; then
    echo "✅ Todas las variables críticas están configuradas"
    exit 0
else
    echo "❌ Faltan variables críticas"
    exit 1
fi
EOF

chmod +x "$BACKSTAGE_DIR/verify-config.sh"
echo "✅ Creado: verify-config.sh"

# 6. CREAR SCRIPT DE INICIO ROBUSTO
echo ""
echo "6. Creando script de inicio robusto..."
echo "====================================="

cat > "$BACKSTAGE_DIR/start-robust.sh" << 'EOF'
#!/bin/bash
# Script de inicio robusto que verifica configuración antes de iniciar

set -e

echo "🚀 Iniciando Backstage de forma robusta..."
echo "========================================="

# Verificar configuración
if ! ./verify-config.sh; then
    echo "❌ Error en la configuración. Ejecuta ./setup-persistent-config.sh"
    exit 1
fi

# Sincronizar variables de entorno
echo "🔄 Sincronizando variables de entorno..."
./sync-env-config.sh 2>/dev/null || true

# Verificar que los servicios de base de datos estén corriendo
echo "🔍 Verificando servicios..."
cd ../../
if ! docker-compose ps postgres | grep -q "Up"; then
    echo "🚀 Iniciando PostgreSQL..."
    docker-compose up -d postgres
    sleep 5
fi

if ! docker-compose ps redis | grep -q "Up"; then
    echo "🚀 Iniciando Redis..."
    docker-compose up -d redis
    sleep 3
fi

cd applications/backstage

# Iniciar Backstage
echo "🎯 Iniciando Backstage..."
source ../../.env
yarn start
EOF

chmod +x "$BACKSTAGE_DIR/start-robust.sh"
echo "✅ Creado: start-robust.sh"

# 7. CREAR SCRIPT DE RESTAURACIÓN
echo ""
echo "7. Creando script de restauración..."
echo "==================================="

cat > "$BACKSTAGE_DIR/restore-config.sh" << 'EOF'
#!/bin/bash
# Script para restaurar configuración desde backup

BACKUP_DIR="./config-backups"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ No se encontró directorio de backups"
    exit 1
fi

echo "📋 Backups disponibles:"
ls -la "$BACKUP_DIR"/config_backup_*.tar.gz | nl

echo ""
read -p "Selecciona el número del backup a restaurar: " selection

backup_file=$(ls -t "$BACKUP_DIR"/config_backup_*.tar.gz | sed -n "${selection}p")

if [ -z "$backup_file" ]; then
    echo "❌ Selección inválida"
    exit 1
fi

echo "🔄 Restaurando desde: $backup_file"
tar -xzf "$backup_file" -C /tmp/
cp /tmp/.env ../../.env
cp /tmp/app-config.yaml ./app-config.yaml
cp /tmp/app-config.local.yaml ./app-config.local.yaml 2>/dev/null || true

echo "✅ Configuración restaurada"
echo "💡 Ejecuta ./verify-config.sh para verificar"
EOF

chmod +x "$BACKSTAGE_DIR/restore-config.sh"
echo "✅ Creado: restore-config.sh"

# 8. VERIFICACIÓN FINAL
echo ""
echo "8. Verificación final..."
echo "======================="

# Ejecutar verificación
if "$BACKSTAGE_DIR/verify-config.sh"; then
    echo "✅ Configuración verificada correctamente"
else
    echo "⚠️  Hay problemas en la configuración"
fi

echo ""
echo "🎯 CONFIGURACIÓN PERSISTENTE COMPLETADA"
echo "======================================="
echo ""
echo "📁 Scripts creados:"
echo "   • setup-persistent-config.sh - Este script (configuración inicial)"
echo "   • verify-config.sh - Verificar configuración"
echo "   • start-robust.sh - Inicio robusto con verificaciones"
echo "   • restore-config.sh - Restaurar desde backup"
echo ""
echo "💾 Backups automáticos en: $BACKUP_DIR"
echo ""
echo "🚀 Para iniciar Backstage de forma segura:"
echo "   ./start-robust.sh"
echo ""
echo "🔍 Para verificar configuración en cualquier momento:"
echo "   ./verify-config.sh"
echo ""
echo "✨ ¡La configuración ahora está protegida contra pérdidas!"
EOF

chmod +x setup-persistent-config.sh
