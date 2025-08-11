#!/bin/bash

# =============================================================================
# Limpiar Todos los Archivos de Backup Automáticamente
# =============================================================================

set -e

echo "🧹 Limpiando todos los archivos de backup automáticamente..."

# Contar backups antes de eliminar
ENV_BACKUP_COUNT=$(find packages/app/src/config/ -name "env.ts.backup.*" 2>/dev/null | wc -l)
CHAT_BACKUP_COUNT=$(find packages/app/src/components/AiChat/ -name "*.backup.*" 2>/dev/null | wc -l)

echo "📊 Archivos encontrados:"
echo "   • Backups de env.ts: $ENV_BACKUP_COUNT"
echo "   • Backups del chat: $CHAT_BACKUP_COUNT"

# Eliminar backups de env.ts
if [ "$ENV_BACKUP_COUNT" -gt 0 ]; then
    find packages/app/src/config/ -name "env.ts.backup.*" -delete
    echo "✅ $ENV_BACKUP_COUNT backups de env.ts eliminados"
else
    echo "✅ No hay backups de env.ts para eliminar"
fi

# Eliminar backups del chat
if [ "$CHAT_BACKUP_COUNT" -gt 0 ]; then
    find packages/app/src/components/AiChat/ -name "*.backup.*" -delete
    echo "✅ $CHAT_BACKUP_COUNT backups del chat eliminados"
else
    echo "✅ No hay backups del chat para eliminar"
fi

# Verificar limpieza
REMAINING_ENV=$(find packages/app/src/config/ -name "env.ts.backup.*" 2>/dev/null | wc -l)
REMAINING_CHAT=$(find packages/app/src/components/AiChat/ -name "*.backup.*" 2>/dev/null | wc -l)

echo ""
echo "🎯 Resultado de la limpieza:"
echo "   • Backups de env.ts eliminados: $ENV_BACKUP_COUNT"
echo "   • Backups del chat eliminados: $CHAT_BACKUP_COUNT"
echo "   • Archivos restantes: $((REMAINING_ENV + REMAINING_CHAT))"

if [ $((REMAINING_ENV + REMAINING_CHAT)) -eq 0 ]; then
    echo ""
    echo "✨ ¡Todos los backups eliminados exitosamente!"
else
    echo ""
    echo "⚠️  Algunos archivos no pudieron ser eliminados"
fi
