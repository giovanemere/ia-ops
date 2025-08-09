#!/bin/bash

echo "🔧 SOLUCIONANDO CONFLICTO DE RAMA 'backstage-integration'"
echo "========================================================"

echo ""
echo "❌ ERROR DETECTADO:"
echo "=================="
echo "Reference already exists - La rama 'backstage-integration' ya existe"

echo ""
echo "🔍 DIAGNOSTICANDO EL PROBLEMA:"
echo "============================="

# Verificar si estamos en un repositorio git
if [ -d ".git" ]; then
    echo "✅ Estamos en un repositorio Git"
    
    # Verificar rama actual
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "📍 Rama actual: $current_branch"
    
    # Verificar ramas locales
    echo ""
    echo "📋 Ramas locales:"
    git branch 2>/dev/null || echo "No se pudieron listar las ramas locales"
    
    # Verificar ramas remotas
    echo ""
    echo "📋 Ramas remotas:"
    git branch -r 2>/dev/null || echo "No se pudieron listar las ramas remotas"
    
    # Verificar si la rama backstage-integration existe localmente
    if git branch | grep -q "backstage-integration"; then
        echo ""
        echo "⚠️  La rama 'backstage-integration' existe LOCALMENTE"
        LOCAL_EXISTS=true
    else
        echo ""
        echo "✅ La rama 'backstage-integration' NO existe localmente"
        LOCAL_EXISTS=false
    fi
    
    # Verificar si existe remotamente
    if git branch -r | grep -q "backstage-integration"; then
        echo "⚠️  La rama 'backstage-integration' existe REMOTAMENTE"
        REMOTE_EXISTS=true
    else
        echo "✅ La rama 'backstage-integration' NO existe remotamente"
        REMOTE_EXISTS=false
    fi
    
else
    echo "❌ No estamos en un repositorio Git"
    echo "💡 Este error puede venir de Backstage intentando crear ramas en GitHub"
    LOCAL_EXISTS=false
    REMOTE_EXISTS=false
fi

echo ""
echo "🛠️  SOLUCIONES DISPONIBLES:"
echo "=========================="

echo ""
echo "SOLUCIÓN 1: Usar un nombre diferente"
echo "===================================="
echo "• Cambiar el nombre de la rama a algo único"
echo "• Ejemplos:"
echo "  - backstage-integration-$(date +%Y%m%d)"
echo "  - backstage-setup-$(whoami)"
echo "  - ia-ops-backstage-integration"

echo ""
echo "SOLUCIÓN 2: Eliminar la rama existente (si es tuya)"
echo "=================================================="
if [ "$LOCAL_EXISTS" = true ]; then
    echo "Para eliminar la rama local:"
    echo "  git branch -D backstage-integration"
fi

if [ "$REMOTE_EXISTS" = true ]; then
    echo "Para eliminar la rama remota:"
    echo "  git push origin --delete backstage-integration"
fi

echo ""
echo "SOLUCIÓN 3: Usar la rama existente"
echo "=================================="
echo "Si la rama ya tiene el contenido que necesitas:"
echo "  git checkout backstage-integration"
echo "  git pull origin backstage-integration"

echo ""
echo "🔧 SCRIPT AUTOMÁTICO PARA LIMPIAR:"
echo "=================================="

read -p "¿Quieres eliminar la rama 'backstage-integration' existente? (y/n): " delete_branch

if [ "$delete_branch" = "y" ] || [ "$delete_branch" = "Y" ]; then
    echo ""
    echo "🗑️  ELIMINANDO RAMA EXISTENTE:"
    echo "============================="
    
    # Cambiar a main/master si estamos en la rama a eliminar
    if [ "$current_branch" = "backstage-integration" ]; then
        echo "📍 Cambiando a rama principal..."
        git checkout main 2>/dev/null || git checkout master 2>/dev/null || echo "⚠️  No se pudo cambiar a rama principal"
    fi
    
    # Eliminar rama local si existe
    if [ "$LOCAL_EXISTS" = true ]; then
        echo "🗑️  Eliminando rama local..."
        git branch -D backstage-integration 2>/dev/null && echo "✅ Rama local eliminada" || echo "❌ Error eliminando rama local"
    fi
    
    # Eliminar rama remota si existe
    if [ "$REMOTE_EXISTS" = true ]; then
        echo "🗑️  Eliminando rama remota..."
        git push origin --delete backstage-integration 2>/dev/null && echo "✅ Rama remota eliminada" || echo "❌ Error eliminando rama remota (puede requerir permisos)"
    fi
    
    echo ""
    echo "✅ LIMPIEZA COMPLETADA"
    echo "====================="
    echo "Ahora puedes crear la rama 'backstage-integration' nuevamente"
    
else
    echo ""
    echo "✅ NO SE REALIZARON CAMBIOS"
    echo "=========================="
    echo "La rama 'backstage-integration' sigue existiendo"
fi

echo ""
echo "💡 RECOMENDACIONES:"
echo "=================="
echo "1. 🎯 MEJOR PRÁCTICA: Usar nombres únicos para ramas"
echo "   - backstage-integration-$(date +%Y%m%d-%H%M)"
echo "   - feature/backstage-setup"
echo "   - setup/ia-ops-backstage"

echo ""
echo "2. 🔍 VERIFICAR ANTES DE CREAR:"
echo "   git branch -a | grep backstage"

echo ""
echo "3. 🚀 CREAR RAMA CON NOMBRE ÚNICO:"
echo "   git checkout -b backstage-integration-$(date +%Y%m%d)"

echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "================="
echo "1. Decidir qué hacer con la rama existente"
echo "2. Usar un nombre diferente o limpiar la existente"
echo "3. Continuar con la configuración de Backstage"
echo "4. Si el error viene de Backstage, verificar configuración de GitHub"
