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
