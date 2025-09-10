#!/bin/bash

echo "🔄 Reiniciando PostgreSQL + Redis..."
cd ia-ops-postgress
./scripts/manage.sh restart
echo "✅ PostgreSQL + Redis reiniciado"
