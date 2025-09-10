#!/bin/bash

echo "🔄 Reiniciando Veritas..."
cd ia-ops-veritas
./scripts/manage.sh restart
echo "✅ Veritas reiniciado"
