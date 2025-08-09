#!/bin/bash

echo "🔍 DIAGNÓSTICO DE GITHUB ACTIONS EN BACKSTAGE"
echo "=============================================="

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    echo "✅ Archivo de entorno encontrado: ../../.env"
    set -a
    source ../../.env
    set +a
else
    echo "❌ No se encontró el archivo ../../.env"
    exit 1
fi

echo ""
echo "📋 VERIFICACIÓN DE CONFIGURACIÓN:"
echo "================================="

# 1. Verificar GitHub Token
echo "1. GitHub Token:"
if [ -z "$GITHUB_TOKEN" ]; then
    echo "   ❌ GITHUB_TOKEN no está configurado"
elif [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ]; then
    echo "   ⚠️  GITHUB_TOKEN tiene valor placeholder"
    echo "   📝 ACCIÓN REQUERIDA: Reemplaza con tu token real de GitHub"
else
    echo "   ✅ GITHUB_TOKEN está configurado"
    echo "   🔧 Token: ${GITHUB_TOKEN:0:10}..."
fi

# 2. Verificar Backend Secret
echo "2. Backend Secret:"
if [ -z "$BACKEND_SECRET" ]; then
    echo "   ❌ BACKEND_SECRET no está configurado"
else
    echo "   ✅ BACKEND_SECRET está configurado"
fi

# 3. Verificar configuración de base de datos
echo "3. Base de datos:"
echo "   🔧 Host: $POSTGRES_HOST"
echo "   🔧 Puerto: $POSTGRES_PORT"
echo "   🔧 Usuario: $POSTGRES_USER"
echo "   🔧 Base de datos: $POSTGRES_DB"

echo ""
echo "📦 VERIFICACIÓN DE PLUGINS:"
echo "=========================="

# 4. Verificar plugins instalados
echo "4. Plugins de GitHub Actions:"
if grep -q "@backstage/plugin-github-actions" packages/app/package.json; then
    echo "   ✅ Plugin frontend instalado: @backstage/plugin-github-actions"
else
    echo "   ❌ Plugin frontend NO instalado"
fi

# 5. Verificar configuración en app-config.yaml
echo "5. Configuración en app-config.yaml:"
if grep -q "github:" app-config.yaml; then
    echo "   ✅ Configuración de GitHub encontrada"
else
    echo "   ❌ Configuración de GitHub NO encontrada"
fi

if grep -q "githubActions:" app-config.yaml; then
    echo "   ⚠️  Configuración específica de githubActions encontrada (puede causar problemas)"
else
    echo "   ✅ No hay configuración específica de githubActions (correcto)"
fi

echo ""
echo "🌐 PRUEBA DE CONECTIVIDAD:"
echo "========================="

# 6. Probar conectividad con GitHub
if [ "$GITHUB_TOKEN" != "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ] && [ ! -z "$GITHUB_TOKEN" ]; then
    echo "6. Probando conectividad con GitHub API..."
    response=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo "   ✅ Conectividad con GitHub API exitosa"
        user_info=$(echo "$response" | head -c -4)
        username=$(echo "$user_info" | grep '"login"' | cut -d'"' -f4)
        echo "   👤 Usuario autenticado: $username"
    else
        echo "   ❌ Error de conectividad con GitHub API (HTTP $http_code)"
        if [ "$http_code" = "401" ]; then
            echo "   🔑 Token inválido o expirado"
        elif [ "$http_code" = "403" ]; then
            echo "   🚫 Token sin permisos suficientes"
        fi
    fi
else
    echo "6. ⚠️  No se puede probar conectividad - token no configurado"
fi

echo ""
echo "📝 RECOMENDACIONES:"
echo "=================="

if [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "🔑 PASO 1: Crear un Personal Access Token en GitHub"
    echo "   - Ve a GitHub.com → Settings → Developer settings → Personal access tokens"
    echo "   - Crea un token con permisos: repo, workflow, read:org, read:user"
    echo "   - Reemplaza 'ghp_REPLACE_WITH_YOUR_ACTUAL_TOKEN' en ../../.env"
    echo ""
fi

echo "🚀 PASO 2: Para iniciar Backstage con la configuración correcta:"
echo "   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "   ./start-with-env.sh"
echo ""

echo "🔍 PASO 3: Para probar el token después de configurarlo:"
echo "   ./test-github-token.sh"
echo ""

echo "📊 PASO 4: Una vez iniciado, GitHub Actions estará disponible en:"
echo "   - Páginas individuales de componentes (si tienen Actions configuradas)"
echo "   - http://localhost:3002 → Catalog → [Seleccionar componente] → GitHub Actions tab"
