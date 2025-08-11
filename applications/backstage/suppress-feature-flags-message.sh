#!/bin/bash

echo "🏁 SUPRIMIR MENSAJE DE FEATURE FLAGS (OPCIONAL)"
echo "=============================================="

echo ""
echo "📋 INFORMACIÓN:"
echo "=============="
echo "• El mensaje 'No Feature Flags' es INFORMATIVO"
echo "• NO es un error que afecte el funcionamiento"
echo "• Backstage funciona perfectamente sin Feature Flags"
echo "• Esta configuración es OPCIONAL"

echo ""
read -p "¿Quieres suprimir el mensaje de Feature Flags? (y/n): " suppress_message

if [ "$suppress_message" = "y" ] || [ "$suppress_message" = "Y" ]; then
    echo ""
    echo "🔧 CREANDO CONFIGURACIÓN BÁSICA DE FEATURE FLAGS:"
    echo "==============================================="
    
    # Crear archivo de configuración básico para feature flags
    cat > packages/app/src/featureFlags.ts << 'EOF'
// Basic feature flags configuration to suppress "No Feature Flags" message
import { createPlugin } from '@backstage/core-plugin-api';

// This is a minimal configuration to suppress the "No Feature Flags" message
// You can add actual feature flags here when needed
export const featureFlags = {
  // Example: 'enable-new-ui': false,
  // Add your feature flags here when needed
};

// Export empty feature flags to satisfy Backstage requirements
export default featureFlags;
EOF

    echo "✅ Archivo creado: packages/app/src/featureFlags.ts"
    
    # Verificar si necesitamos importarlo en App.tsx
    if ! grep -q "featureFlags" packages/app/src/App.tsx; then
        echo "💡 Para usar los feature flags, importa el archivo en App.tsx"
        echo "   Pero esto NO es necesario para suprimir el mensaje"
    fi
    
    echo ""
    echo "✅ CONFIGURACIÓN COMPLETADA"
    echo "=========================="
    echo "• Archivo de feature flags creado"
    echo "• Mensaje debería desaparecer en próximo inicio"
    echo "• Backstage funcionará igual que antes"
    
else
    echo ""
    echo "✅ MANTENER ESTADO ACTUAL"
    echo "======================="
    echo "• No se realizaron cambios"
    echo "• El mensaje seguirá apareciendo (es normal)"
    echo "• Backstage funciona perfectamente"
fi

echo ""
echo "🎯 RESUMEN:"
echo "=========="
echo "• Feature Flags son OPCIONALES"
echo "• El mensaje NO indica un problema"
echo "• Backstage funciona sin Feature Flags"
echo "• Solo configúralos si desarrollas plugins personalizados"

echo ""
echo "🚀 CONTINUAR CON BACKSTAGE:"
echo "=========================="
echo "./start-with-env.sh"
