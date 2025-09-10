#!/bin/bash

echo "🔍 Verificando políticas de reinicio en docker-compose files..."
echo "=============================================================="

# Buscar todos los docker-compose files principales
compose_files=(
    "/home/giovanemere/ia-ops/ia-ops-postgress/docker-compose.yml"
    "/home/giovanemere/ia-ops/ia-ops-minio/docker-compose.integrated.yml"
    "/home/giovanemere/ia-ops/ia-ops-dev-core/docker/docker-compose.yml"
    "/home/giovanemere/ia-ops/ia-ops-openai/docker-compose.integrated.yml"
    "/home/giovanemere/ia-ops/ia-ops-veritas/docker-compose.yml"
    "/home/giovanemere/ia-ops/ia-ops-docs/docker-compose.yml"
    "/home/giovanemere/ia-ops/ia-ops-backstage/docker-compose.yml"
    "/home/giovanemere/ia-ops/ia-ops-guard/docker-compose.dev.yml"
)

all_good=true

for file in "${compose_files[@]}"; do
    if [ -f "$file" ]; then
        echo ""
        echo "📄 Verificando: $(basename $(dirname $file))/$(basename $file)"
        
        # Contar servicios totales (solo en la sección services)
        total_services=$(awk '
        /^services:/ { in_services = 1; next }
        /^volumes:/ || /^networks:/ { in_services = 0 }
        in_services && /^  [a-zA-Z]/ { count++ }
        END { print count+0 }
        ' "$file")
        
        # Contar servicios con restart policy
        restart_services=$(awk '
        /^services:/ { in_services = 1; next }
        /^volumes:/ || /^networks:/ { in_services = 0 }
        in_services && /restart:/ { count++ }
        END { print count+0 }
        ' "$file")
        
        if [ "$restart_services" -eq "$total_services" ]; then
            echo "✅ Todos los servicios ($total_services) tienen restart policy"
        else
            echo "⚠️  Solo $restart_services de $total_services servicios tienen restart policy"
            echo "   Servicios sin restart policy:"
            
            # Mostrar servicios sin restart policy
            echo "   Servicios sin restart policy:"
            awk '
            /^services:/ { in_services = 1; next }
            /^volumes:/ || /^networks:/ { in_services = 0; next }
            in_services && /^  [a-zA-Z][^:]*:/ { 
                service_name = $1
                gsub(/:$/, "", service_name)
                services[service_name] = 0
            }
            in_services && /restart:/ {
                for (s in services) {
                    if (services[s] == 0) {
                        services[s] = 1
                        break
                    }
                }
            }
            END {
                for (s in services) {
                    if (services[s] == 0) {
                        print "   - " s
                    }
                }
            }
            ' "$file"
            
            all_good=false
        fi
    else
        echo "❌ No encontrado: $file"
        all_good=false
    fi
done

echo ""
echo "=============================================================="
if [ "$all_good" = true ]; then
    echo "✅ TODOS los servicios tienen políticas de reinicio configuradas"
    echo "🚀 Los servicios se iniciarán automáticamente al reiniciar el SO"
else
    echo "⚠️  ALGUNOS servicios necesitan configurar restart policies"
    echo "💡 Agrega 'restart: unless-stopped' a los servicios faltantes"
fi

echo ""
echo "🔧 Estado del servicio Docker:"
systemctl is-enabled docker && echo "✅ Docker habilitado para auto-inicio" || echo "❌ Docker NO habilitado para auto-inicio"
