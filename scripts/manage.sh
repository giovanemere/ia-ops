#!/bin/bash

BASE_DIR="/home/giovanemere/ia-ops"
SCRIPTS_DIR="$BASE_DIR/scripts"

show_help() {
    echo "🔧 IA-Ops Management Script"
    echo "=========================="
    echo ""
    echo "Uso: ./scripts/manage.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start      - Inicio inteligente (todos si no hay, faltantes si hay algunos)"
    echo "  start-missing - Iniciar solo servicios faltantes"
    echo "  restart    - Reinicio completo (stop + start) solo si hay servicios activos"
    echo "  stop       - Detener todos los servicios"
    echo "  status     - Estado detallado de servicios"
    echo "  check      - Verificar puertos activos"
    echo "  diagnose   - Diagnóstico completo del sistema"
    echo "  help       - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./scripts/manage.sh start"
    echo "  ./scripts/manage.sh diagnose"
    echo "  ./scripts/manage.sh check"
}

case "$1" in
    "start")
        echo "🚀 Iniciando servicios inteligentemente..."
        $SCRIPTS_DIR/smart-start.sh
        ;;
    "start-missing")
        echo "🔄 Iniciando servicios faltantes..."
        $SCRIPTS_DIR/start-missing-services.sh
        ;;
    "restart")
        echo "🔄 Reinicio inteligente de servicios..."
        $SCRIPTS_DIR/smart-restart.sh
        ;;
    "stop")
        echo "🛑 Deteniendo servicios..."
        $SCRIPTS_DIR/stop.sh
        ;;
    "status")
        echo "📊 Estado de servicios..."
        $SCRIPTS_DIR/status.sh
        ;;
    "check")
        echo "🔍 Verificando puertos..."
        $SCRIPTS_DIR/check-ports.sh
        ;;
    "diagnose")
        echo "🔍 Diagnóstico completo..."
        $SCRIPTS_DIR/diagnose-services.sh
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo "❌ Comando no reconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
