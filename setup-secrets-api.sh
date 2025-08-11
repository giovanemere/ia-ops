#!/bin/bash

# Script para configurar secrets usando API de GitHub directamente
set -e

echo "🔐 Configurando Secrets usando API de GitHub"
echo "============================================"

cd "$(dirname "$0")"

# Función para extraer valor de .env
get_env_value() {
    local key=$1
    grep "^${key}=" .env | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//'
}

# Leer variables
GITHUB_TOKEN=$(get_env_value "GITHUB_TOKEN")
DOCKER_HUB_USERNAME=$(get_env_value "DOCKER_HUB_USERNAME")
DOCKER_HUB_TOKEN=$(get_env_value "DOCKER_HUB_TOKEN")

# Configuración del repositorio
REPO_OWNER="giovanemere"
REPO_NAME="ia-ops"

echo "📋 Configuración:"
echo "   Repository: $REPO_OWNER/$REPO_NAME"
echo "   Docker Hub Username: $DOCKER_HUB_USERNAME"
echo "   Docker Hub Token: ${DOCKER_HUB_TOKEN:0:20}..."

# Función para configurar un secret usando curl
set_secret() {
    local secret_name=$1
    local secret_value=$2
    
    echo "📝 Configurando $secret_name..."
    
    # Obtener la clave pública del repositorio
    local public_key_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key")
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Error obteniendo clave pública"
        return 1
    fi
    
    local public_key=$(echo "$public_key_response" | jq -r '.key')
    local key_id=$(echo "$public_key_response" | jq -r '.key_id')
    
    if [[ "$public_key" == "null" || "$key_id" == "null" ]]; then
        echo "❌ Error: No se pudo obtener la clave pública"
        echo "Respuesta: $public_key_response"
        return 1
    fi
    
    # Instalar libsodium si no está disponible
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 no está disponible"
        return 1
    fi
    
    # Crear script Python para encriptar el secret
    cat > encrypt_secret.py << EOF
import base64
import json
import sys
from nacl import encoding, public

def encrypt_secret(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return base64.b64encode(encrypted).decode("utf-8")

if __name__ == "__main__":
    public_key = sys.argv[1]
    secret_value = sys.argv[2]
    encrypted_value = encrypt_secret(public_key, secret_value)
    print(encrypted_value)
EOF
    
    # Verificar si PyNaCl está disponible
    if ! python3 -c "import nacl" 2>/dev/null; then
        echo "❌ PyNaCl no está disponible. Instala con: sudo apt install python3-nacl"
        return 1
    fi
    
    # Encriptar el secret
    local encrypted_value=$(python3 encrypt_secret.py "$public_key" "$secret_value")
    
    if [[ -z "$encrypted_value" ]]; then
        echo "❌ Error encriptando el secret"
        rm -f encrypt_secret.py
        return 1
    fi
    
    # Enviar el secret encriptado
    local response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
    
    # Limpiar archivo temporal
    rm -f encrypt_secret.py
    
    if [[ $? -eq 0 ]]; then
        echo "✅ $secret_name configurado exitosamente"
        return 0
    else
        echo "❌ Error configurando $secret_name"
        echo "Respuesta: $response"
        return 1
    fi
}

echo ""
echo "🔧 Configurando secrets..."

# Configurar DOCKER_HUB_USERNAME
if set_secret "DOCKER_HUB_USERNAME" "$DOCKER_HUB_USERNAME"; then
    echo "✅ DOCKER_HUB_USERNAME configurado"
else
    echo "❌ Error configurando DOCKER_HUB_USERNAME"
    exit 1
fi

echo ""

# Configurar DOCKER_HUB_TOKEN
if set_secret "DOCKER_HUB_TOKEN" "$DOCKER_HUB_TOKEN"; then
    echo "✅ DOCKER_HUB_TOKEN configurado"
else
    echo "❌ Error configurando DOCKER_HUB_TOKEN"
    exit 1
fi

echo ""
echo "🎉 ¡Todos los secrets configurados exitosamente!"

echo ""
echo "📋 Resumen:"
echo "   ✅ DOCKER_HUB_USERNAME = $DOCKER_HUB_USERNAME"
echo "   ✅ DOCKER_HUB_TOKEN = configurado (oculto por seguridad)"

echo ""
echo "🔗 Enlaces útiles:"
echo "   📋 GitHub Secrets: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo "   🐳 Docker Hub Repo: https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ia-ops-backstage"
echo "   🏗️ GitHub Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"

echo ""
echo "🧪 Próximos pasos:"
echo "   1. Ejecutar workflow: gh workflow run docker-hub-push.yml"
echo "   2. Monitorear: ./monitor-docker-hub-workflow.sh"
echo "   3. Verificar imagen: ./scripts/verify-docker-hub.sh"

echo ""
echo "✅ ¡Listo para usar Docker Hub!"
