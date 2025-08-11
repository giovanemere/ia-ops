#!/bin/bash

# =============================================================================
# COMANDOS PARA PRESENTACIÓN EN VIVO - IA-OPS PLATFORM MVP
# =============================================================================
# Copiar y pegar estos comandos durante la presentación

echo "🎬 COMANDOS DE PRESENTACIÓN IA-OPS PLATFORM MVP"
echo "==============================================="
echo ""

# COMANDO 1: Verificación previa
echo "🔍 1. VERIFICACIÓN PREVIA:"
echo "docker-compose ps"
echo "curl -s http://localhost:8003/health | jq ."
echo ""

# COMANDO 2: Análisis IA en vivo
echo "🤖 2. ANÁLISIS IA EN VIVO:"
echo "time curl -s -X POST http://localhost:8003/analyze-repository \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"repository_url\": \"https://github.com/giovanemere/poc-billpay-back\", \"branch\": \"trunk\"}' | jq '.result.analysis.technologies, .result.analysis.architecture'"
echo ""

# COMANDO 3: Mostrar entidades generadas
echo "📚 3. ENTIDADES BACKSTAGE GENERADAS:"
echo "head -20 applications/backstage/catalog-mvp-demo.yaml"
echo ""

# COMANDO 4: Documentación automática
echo "📖 4. DOCUMENTACIÓN GENERADA:"
echo "head -25 ai-generated-documentation.md"
echo ""

# COMANDO 5: Pipeline completo
echo "🔗 5. PIPELINE COMPLETO:"
echo "./simulate-backstage-integration.sh | tail -15"
echo ""

# COMANDO 6: Métricas de tiempo
echo "⏱️ 6. MÉTRICAS DE TIEMPO:"
echo "echo '| Proceso           | Manual    | IA-Ops    | Reducción |'"
echo "echo '|-------------------|-----------|-----------|-----------| '"
echo "echo '| Análisis código   | 2-4 horas | 5 seg     | 99.9%     |'"
echo "echo '| Catalogación      | 1-2 horas | 0 min     | 100%      |'"
echo "echo '| Documentación     | 3-6 horas | 10 seg    | 99.9%     |'"
echo "echo '| **TOTAL**         | **6-12h** | **30 seg**| **99.9%** |'"
echo ""

# COMANDO 7: ROI
echo "💰 7. CÁLCULO DE ROI:"
echo "echo 'Costo desarrollador senior: \$50/hora'"
echo "echo 'Ahorro por aplicación: \$300-600'"
echo "echo 'Con 10 aplicaciones/mes: \$3,000-6,000'"
echo "echo 'Ahorro anual estimado: \$36,000-72,000'"
echo ""

# COMANDO 8: Validación técnica
echo "✅ 8. VALIDACIÓN TÉCNICA:"
echo "cat mvp-validation-report.json | jq '.mvp_validation | {total_checks, passed_checks, success_rate, status, ready_for_production}'"
echo ""

echo "🎯 TIPS PARA LA PRESENTACIÓN:"
echo "============================"
echo "• Ejecutar comandos uno por uno"
echo "• Explicar cada resultado antes de continuar"
echo "• Destacar la velocidad y precisión"
echo "• Enfatizar el valor de negocio"
echo "• Mantener energía y entusiasmo"
echo ""
echo "🎉 ¡BUENA SUERTE CON LA PRESENTACIÓN!"
