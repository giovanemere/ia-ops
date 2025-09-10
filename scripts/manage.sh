#!/bin/bash

# Directorio base
BASE_DIR="/home/giovanemere/ia-ops"

# Cargar funciones comunes
source "$(dirname "$0")/common-functions.sh"

case "$1" in
    "start")
        echo "🚀 Iniciando servicios inteligentemente..."
        $SCRIPTS_DIR/smart-start.sh
        show_service_urls
        ;;
    "start-missing")
        echo "🔄 Iniciando servicios faltantes..."
        $SCRIPTS_DIR/start-missing-services.sh
        show_service_urls
        ;;
    "restart")
        echo "🔄 Reinicio inteligente de servicios..."
        $SCRIPTS_DIR/smart-restart.sh
        echo ""
        echo "⏳ Verificando servicios después del reinicio..."
        sleep 5
        show_service_urls
        ;;
    "stop")
        echo "🛑 Deteniendo servicios..."
        $SCRIPTS_DIR/stop.sh
        show_service_urls
        ;;
    "status")
        echo "📊 Estado de servicios..."
        $SCRIPTS_DIR/status.sh
        show_service_urls
        ;;
    "check")
        echo "🔍 Verificando puertos..."
        $SCRIPTS_DIR/check-ports.sh
        show_service_urls
        ;;
    "check-restart")
        echo "🔍 Verificando políticas de reinicio..."
        $SCRIPTS_DIR/check-restart-policies.sh
        ;;
    "update-repos")
        echo "🚀 Actualizando todos los repositorios..."
        $SCRIPTS_DIR/update-all-repos.sh
        ;;
    "check-repos")
        echo "🔍 Verificando estado de repositorios..."
        $SCRIPTS_DIR/check-repos-status.sh
        ;;
    # "guard")
    #     case "$2" in
    #         "start"|"stop"|"restart"|"status"|"logs")
    #             echo "🛡️ Gestionando IA-Ops Guard..."
    #             cd "$BASE_DIR/ia-ops-guard"
    #             ./manage-integrated.sh "$2"
    #             ;;
    #         *)
    #             echo "🛡️ IA-Ops Guard Commands"
    #             echo "========================"
    #             echo "Uso: ./scripts/manage.sh guard [comando]"
    #             echo ""
    #             echo "Comandos:"
    #             echo "  start   - Iniciar servicios de seguridad"
    #             echo "  stop    - Detener servicios"
    #             echo "  restart - Reiniciar servicios"
    #             echo "  status  - Ver estado"
    #             echo "  logs    - Ver logs"
    #             ;;
    #     esac
    #     ;;
    "diagnose")
        echo "🔍 Diagnóstico completo..."
        $SCRIPTS_DIR/diagnose-services.sh
        show_service_urls
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
