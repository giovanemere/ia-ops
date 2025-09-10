#!/bin/bash

echo "🔄 Reiniciando Dev-Core..."
cd ia-ops-dev-core

# Detener Service Layer principal
docker-compose down 2>/dev/null || true

# Detener microservicios
cd docker && docker-compose down 2>/dev/null || true
cd ..

sleep 2

# Iniciar Service Layer principal
./start.sh

# Iniciar microservicios
cd docker && docker-compose up -d 2>/dev/null || true

echo "✅ Dev-Core reiniciado (Service Layer + Microservicios)"
