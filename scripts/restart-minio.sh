#!/bin/bash

echo "🔄 Reiniciando MinIO con persistencia..."
cd ia-ops-minio

# Reiniciar con volúmenes persistentes
docker-compose -f docker-compose.integrated.yml restart

# Esperar a que esté listo
echo "⏳ Esperando a que MinIO esté listo..."
sleep 15

# Verificar buckets (recrear si es necesario)
echo "📦 Verificando buckets..."
cd /home/giovanemere/ia-ops/ia-ops-docs
source venv/bin/activate
python3 /home/giovanemere/ia-ops/ia-ops-minio/init-buckets.py

echo "✅ MinIO reiniciado correctamente"
