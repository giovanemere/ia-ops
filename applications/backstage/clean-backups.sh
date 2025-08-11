#!/bin/bash

# =============================================================================
# Limpiar Archivos de Backup
# =============================================================================

set -e

echo "🧹 Limpiando archivos de backup..."

# Buscar y eliminar backups de env.ts
BACKUP_COUNT=$(find packages/app/src/config/ -name "env.ts.backup.*" 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "📁 Encontrados $BACKUP_COUNT archivos de backup:"
    find packages/app/src/config/ -name "env.ts.backup.*" -exec basename {} \;
    
    echo ""
    read -p "¿Deseas eliminar todos los backups? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find packages/app/src/config/ -name "env.ts.backup.*" -delete
        echo "✅ Backups eliminados exitosamente"
    else
        echo "❌ Operación cancelada"
    fi
else
    echo "✅ No se encontraron archivos de backup"
fi

# Buscar y eliminar backups del chat
CHAT_BACKUP_COUNT=$(find packages/app/src/components/AiChat/ -name "*.backup.*" 2>/dev/null | wc -l)

if [ "$CHAT_BACKUP_COUNT" -gt 0 ]; then
    echo ""
    echo "📁 Encontrados $CHAT_BACKUP_COUNT backups del chat:"
    find packages/app/src/components/AiChat/ -name "*.backup.*" -exec basename {} \;
    
    echo ""
    read -p "¿Deseas eliminar también los backups del chat? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find packages/app/src/components/AiChat/ -name "*.backup.*" -delete
        echo "✅ Backups del chat eliminados exitosamente"
    else
        echo "❌ Operación cancelada para backups del chat"
    fi
fi

echo ""
echo "🎯 Resumen de limpieza:"
echo "   • Backups de env.ts: $(find packages/app/src/config/ -name "env.ts.backup.*" 2>/dev/null | wc -l) restantes"
echo "   • Backups del chat: $(find packages/app/src/components/AiChat/ -name "*.backup.*" 2>/dev/null | wc -l) restantes"
echo ""
echo "✨ ¡Limpieza completada!"
