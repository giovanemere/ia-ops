#!/bin/bash

# Script para configurar GCP en IA-Ops desde CLI
set -e

echo "🔧 Configurando GCP para IA-Ops..."

# Verificar si gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI no está instalado"
    exit 1
fi

# Verificar autenticación
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
    echo "❌ No estás autenticado en gcloud"
    echo "Ejecuta: gcloud auth login"
    exit 1
fi

# Obtener proyecto actual
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No hay proyecto configurado"
    echo "Ejecuta: gcloud config set project TU_PROJECT_ID"
    exit 1
fi

echo "📋 Proyecto: $PROJECT_ID"

# Crear service account si no existe
SA_NAME="ia-ops-service"
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

if ! gcloud iam service-accounts describe $SA_EMAIL &>/dev/null; then
    echo "🔧 Creando Service Account..."
    gcloud iam service-accounts create $SA_NAME \
        --display-name="IA-Ops Service Account" \
        --description="Service Account para IA-Ops Portal"
    
    # Asignar roles básicos
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/viewer"
    
    echo "✅ Service Account creado"
else
    echo "ℹ️ Service Account ya existe"
fi

# Crear nueva key
KEY_FILE="/tmp/gcp-key-$PROJECT_ID.json"
echo "🔑 Creando nueva key..."
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SA_EMAIL

# Configurar en IA-Ops via API
echo "📡 Configurando en IA-Ops..."
curl -s -X POST http://localhost:8846/api/v1/providers \
    -H "Content-Type: application/json" \
    -d "{
        \"provider\": \"gcp\",
        \"projectId\": \"$PROJECT_ID\",
        \"serviceAccountKey\": $(cat $KEY_FILE | jq -c .)
    }" | jq

# Limpiar archivo temporal
rm -f $KEY_FILE

echo "✅ GCP configurado correctamente en IA-Ops"
echo "🌐 Ve a: http://localhost:8845/settings para verificar"
