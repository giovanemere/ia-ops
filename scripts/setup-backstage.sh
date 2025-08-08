#!/bin/bash

# Script para setup rápido de Backstage
set -e

echo "🚀 Configurando Backstage rápidamente..."

# Limpiar directorio anterior si existe
rm -rf applications/backstage-generated

# Crear nueva app Backstage
echo "📦 Creando nueva app Backstage..."
cd applications/
npx @backstage/create-app@latest backstage-generated --skip-install

cd backstage-generated

echo "📝 Configurando package.json optimizado..."
cat > package.json << 'EOF'
{
  "name": "ia-ops-backstage",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": "18 || 20"
  },
  "scripts": {
    "dev": "concurrently \"yarn start\" \"yarn start-backend\"",
    "start": "yarn workspace app start",
    "start-backend": "yarn workspace backend start",
    "build:backend": "yarn workspace backend build",
    "build:all": "backstage-cli repo build --all",
    "build-image": "yarn build:backend && yarn build:all"
  },
  "workspaces": {
    "packages": [
      "packages/*",
      "plugins/*"
    ]
  },
  "devDependencies": {
    "@backstage/cli": "^0.25.0",
    "concurrently": "^8.0.0"
  }
}
EOF

echo "🔧 Instalando dependencias..."
yarn install --network-timeout 300000

echo "✅ Backstage configurado exitosamente!"
echo "💡 Para iniciar: cd applications/backstage-generated && yarn dev"
