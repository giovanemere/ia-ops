#!/bin/bash

# IA-Ops Common Functions Module
# Funciones centralizadas para evitar duplicación

# Configuración base
BASE_DIR="/home/giovanemere/ia-ops"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Servicios activos (sin TechDocs Builder)
ACTIVE_SERVICES=(
    "backstage:3000"
    "portal-docs:8845"
    "dev-core-api:8801"
    "repository-manager:8860"
    "task-manager:8861"
    "log-manager:8862"
    "datasync-manager:8863"
    "github-runner:8864"
    "mkdocs:6541"
    "veritas:8869"
    "minio-console:9899"
    "minio-dashboard:6540"
    "postgresql:5434"
    "redis:6380"
)

# Función para verificar si un puerto está activo
is_port_active() {
    ss -tln | grep -q ":$1 "
}

# Función para mostrar URLs de servicios
show_service_urls() {
    echo ""
    echo "🌐 URLs de Servicios:"
    echo "===================="
    
    # Servicios principales
    echo "  🎭 Backstage: http://localhost:3000 $(is_port_active 3000 && echo "✅" || echo "❌")"
    echo "  📚 Portal Docs (Frontend): http://localhost:8845 $(is_port_active 8845 && echo "✅" || echo "❌")"
    echo "  🔧 Docs Backend: http://localhost:8846 $(is_port_active 8846 && echo "✅" || echo "❌")"
    echo "  🚀 Dev-Core API: http://localhost:8801 $(is_port_active 8801 && echo "✅" || echo "❌")"
    
    # Microservicios
    echo "  📂 Repository Manager: http://localhost:8860 $(is_port_active 8860 && echo "✅" || echo "❌")"
    echo "  📋 Task Manager: http://localhost:8861 $(is_port_active 8861 && echo "✅" || echo "❌")"
    echo "  📊 Log Manager: http://localhost:8862 $(is_port_active 8862 && echo "✅" || echo "❌")"
    echo "  🔄 DataSync Manager: http://localhost:8863 $(is_port_active 8863 && echo "✅" || echo "❌")"
    echo "  🏃 GitHub Runner Manager: http://localhost:8864 $(is_port_active 8864 && echo "✅" || echo "❌")"
    
    # Documentación
    echo "  📝 MkDocs: http://localhost:6541 $(is_port_active 6541 && echo "✅" || echo "❌")"
    
    # Testing y Storage
    echo "  🧪 Veritas: http://localhost:8869 $(is_port_active 8869 && echo "✅" || echo "❌")"
    echo "  📦 MinIO Console: http://localhost:9899 $(is_port_active 9899 && echo "✅" || echo "❌")"
    echo "  📊 MinIO Dashboard: http://localhost:6540 $(is_port_active 6540 && echo "✅" || echo "❌")"
    
    # Base de datos
    echo "  🐘 PostgreSQL: localhost:5434 $(is_port_active 5434 && echo "✅" || echo "❌")"
    echo "  🔴 Redis: localhost:6380 $(is_port_active 6380 && echo "✅" || echo "❌")"
    
    echo ""
    echo "📋 Servicios principales:"
    echo "  🤖 OpenAI API: http://localhost:8000 $(is_port_active 8000 && echo "✅" || echo "❌")"
    echo ""
}

# Función para contar servicios activos
count_active_services() {
    local count=0
    local ports=(5434 9899 8801 8000 8869 8845 3000)
    for port in "${ports[@]}"; do
        if is_port_active $port; then
            ((count++))
        fi
    done
    echo $count
}

# Función para iniciar servicio si no está activo
start_if_needed() {
    local port=$1
    local name=$2
    local dir=$3
    local script=$4
    
    if is_port_active $port; then
        echo "✅ $name ya está activo (puerto $port)"
    else
        echo "🔄 Iniciando $name..."
        cd "$BASE_DIR/$dir"
        if [ -f "$script" ]; then
            ./$script
            sleep 5
            if is_port_active $port; then
                echo "✅ $name iniciado correctamente"
            else
                echo "❌ Error al iniciar $name"
            fi
        else
            echo "❌ Script no encontrado: $script"
        fi
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "🔧 IA-Ops Management Script"
    echo "=========================="
    echo ""
    echo "Uso: ./scripts/manage.sh [comando]"
    echo ""
    echo "Comandos principales:"
    echo "  start         - Inicio inteligente (todos si no hay, faltantes si hay algunos)"
    echo "  start-missing - Iniciar solo servicios faltantes"
    echo "  restart       - Reinicio completo (stop + start) solo si hay servicios activos"
    echo "  stop          - Detener todos los servicios"
    echo "  status        - Estado detallado de servicios"
    echo "  check         - Verificar puertos activos"
    echo "  check-restart - Verificar políticas de reinicio en docker-compose"
    echo "  diagnose      - Diagnóstico completo del sistema"
    echo ""
    echo "Comandos de repositorios:"
    echo "  update-repos  - Actualizar todos los repositorios y crear release"
    echo "  check-repos   - Verificar estado de todos los repositorios"
    echo ""
    echo "  help          - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./scripts/manage.sh start"
    echo "  ./scripts/manage.sh update-repos"
    echo "  ./scripts/manage.sh check-restart"
}
