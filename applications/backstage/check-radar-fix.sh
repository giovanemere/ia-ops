#!/bin/bash

echo "🔍 Verificando que el icono Radar fue corregido..."
echo "================================================"
echo

ROOT_FILE="packages/app/src/components/Root/Root.tsx"

if [ ! -f "$ROOT_FILE" ]; then
    echo "❌ No se encontró $ROOT_FILE"
    exit 1
fi

echo "📋 Verificando imports de iconos:"
echo "--------------------------------"

# Verificar que no hay import de Radar
if grep -q "from '@material-ui/icons/Radar'" "$ROOT_FILE"; then
    echo "❌ PROBLEMA: Aún hay import de Radar"
    grep -n "Radar" "$ROOT_FILE"
else
    echo "✅ No hay import de icono Radar"
fi

# Verificar que hay import de Timeline
if grep -q "from '@material-ui/icons/Timeline'" "$ROOT_FILE"; then
    echo "✅ Import de Timeline encontrado"
else
    echo "❌ PROBLEMA: No se encontró import de Timeline"
fi

echo
echo "📋 Verificando uso de iconos:"
echo "----------------------------"

# Verificar que no se usa RadarIcon
if grep -q "RadarIcon" "$ROOT_FILE"; then
    echo "❌ PROBLEMA: Aún se usa RadarIcon"
    grep -n "RadarIcon" "$ROOT_FILE"
else
    echo "✅ No se usa RadarIcon"
fi

# Verificar que se usa TimelineIcon
if grep -q "TimelineIcon" "$ROOT_FILE"; then
    echo "✅ TimelineIcon se usa correctamente"
    grep -n "TimelineIcon" "$ROOT_FILE" | head -2
else
    echo "❌ PROBLEMA: No se usa TimelineIcon"
fi

echo
echo "📋 Todos los imports de iconos actuales:"
echo "---------------------------------------"
grep -n "from '@material-ui/icons/" "$ROOT_FILE" | sed 's/^/  /'

echo
echo "📋 Todos los usos de iconos en SidebarItem:"
echo "------------------------------------------"
grep -n "icon={.*Icon}" "$ROOT_FILE" | sed 's/^/  /'

echo
echo "✅ Verificación completada!"
echo
if ! grep -q "Radar" "$ROOT_FILE"; then
    echo "🎉 ¡ÉXITO! El problema del icono Radar ha sido solucionado."
    echo "   Ahora puedes iniciar la aplicación sin errores de iconos."
else
    echo "⚠️  Aún hay referencias a Radar que necesitan ser corregidas."
fi
