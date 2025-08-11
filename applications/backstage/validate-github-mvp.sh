#!/bin/bash

# =============================================================================
# VALIDACIÓN DE GITHUB TOKEN - MVP
# =============================================================================
# Script para validar acceso a GitHub para el MVP de 8 horas

set -e

echo "🔍 Validando GitHub Token para MVP..."

# Cargar variables de entorno
if [ -f "../../.env" ]; then
    source ../../.env
    echo "✅ Variables de entorno cargadas"
else
    echo "❌ No se encontró archivo .env"
    exit 1
fi

# Verificar que GITHUB_TOKEN esté configurado
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN no está configurado en .env"
    exit 1
fi

echo "🔑 GitHub Token configurado: ${GITHUB_TOKEN:0:10}..."

# Test 1: Verificar acceso básico a GitHub API
echo ""
echo "📡 Test 1: Acceso básico a GitHub API"
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user)

if echo "$response" | grep -q '"login"'; then
    username=$(echo "$response" | grep '"login"' | cut -d'"' -f4)
    echo "✅ Acceso a GitHub API exitoso - Usuario: $username"
else
    echo "❌ Error en acceso a GitHub API"
    echo "Response: $response"
    exit 1
fi

# Test 2: Verificar acceso a repositorio poc-billpay-back
echo ""
echo "📡 Test 2: Acceso a repositorio poc-billpay-back"
repo_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/giovanemere/poc-billpay-back)

if echo "$repo_response" | grep -q '"full_name"'; then
    repo_name=$(echo "$repo_response" | grep '"full_name"' | cut -d'"' -f4)
    echo "✅ Acceso a repositorio exitoso: $repo_name"
    
    # Obtener información adicional
    default_branch=$(echo "$repo_response" | grep '"default_branch"' | cut -d'"' -f4)
    echo "   📋 Rama por defecto: $default_branch"
    
    language=$(echo "$repo_response" | grep '"language"' | cut -d'"' -f4)
    echo "   💻 Lenguaje principal: $language"
    
else
    echo "❌ Error en acceso a repositorio poc-billpay-back"
    echo "Response: $repo_response"
    exit 1
fi

# Test 3: Verificar acceso a contenido del repositorio
echo ""
echo "📡 Test 3: Acceso a contenido del repositorio (package.json)"
content_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/giovanemere/poc-billpay-back/contents/package.json)

if echo "$content_response" | grep -q '"content"'; then
    echo "✅ Acceso a contenido del repositorio exitoso"
    
    # Decodificar y mostrar parte del package.json
    content=$(echo "$content_response" | grep '"content"' | cut -d'"' -f4 | tr -d '\n' | base64 -d)
    echo "   📦 package.json encontrado:"
    echo "$content" | head -10 | sed 's/^/      /'
    
else
    echo "❌ Error en acceso a contenido del repositorio"
    echo "Response: $content_response"
    exit 1
fi

# Test 4: Verificar otros repositorios objetivo
echo ""
echo "📡 Test 4: Verificar acceso a otros repositorios BillPay"

repos=(
    "giovanemere/poc-billpay-front-a"
    "giovanemere/poc-billpay-front-b" 
    "giovanemere/poc-billpay-front-feature-flags"
    "giovanemere/poc-icbs"
)

for repo in "${repos[@]}"; do
    echo "   🔍 Verificando $repo..."
    repo_check=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$repo)
    
    if echo "$repo_check" | grep -q '"full_name"'; then
        echo "   ✅ $repo - Accesible"
    else
        echo "   ❌ $repo - No accesible o no existe"
    fi
done

# Test 5: Crear datos de prueba para Backstage
echo ""
echo "📡 Test 5: Generar datos para integración con Backstage"

cat > github-integration-test.json << EOF
{
  "github_integration": {
    "status": "success",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "user": "$username",
    "repositories": {
      "poc-billpay-back": {
        "accessible": true,
        "default_branch": "$default_branch",
        "language": "$language"
      }
    },
    "backstage_config": {
      "integrations": {
        "github": [
          {
            "host": "github.com",
            "token": "configured",
            "organization": "giovanemere"
          }
        ]
      },
      "catalog": {
        "locations": [
          {
            "type": "github",
            "target": "https://github.com/giovanemere/poc-billpay-back/blob/main/catalog-info.yaml"
          }
        ]
      }
    }
  }
}
EOF

echo "✅ Datos de integración generados en github-integration-test.json"

echo ""
echo "🎉 VALIDACIÓN COMPLETA - GitHub Token funcionando correctamente"
echo "📋 Resumen:"
echo "   ✅ Acceso a GitHub API"
echo "   ✅ Acceso a repositorio poc-billpay-back"
echo "   ✅ Acceso a contenido del repositorio"
echo "   ✅ Datos de integración generados"
echo ""
echo "🚀 Listo para integración con Backstage MVP"
