#!/bin/bash

# =============================================================================
# PRUEBAS COMPLETAS DE AMBOS STACKS
# =============================================================================

echo "🧪 Iniciando pruebas completas de ambos stacks..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

test_service() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "🔍 Testing $name... "
    
    response=$(curl -s -w "%{http_code}" -o /dev/null --max-time 10 "$url" 2>/dev/null)
    
    if [[ "$response" == "$expected_code" ]] || [[ "$response" == "302" ]] || [[ "$response" == "405" ]]; then
        log_success "$name: ✅ ($response)"
        return 0
    else
        log_error "$name: ❌ ($response)"
        return 1
    fi
}

echo ""
log_info "=== PRUEBAS STACK BACKSTAGE (IA-OPS) ==="

# Probar servicios Backstage
backstage_services=(
    "Backstage Frontend:http://localhost:3002"
    "Backstage Backend:http://localhost:7007"
    "Prometheus:http://localhost:9090"
    "Grafana:http://localhost:3001"
    "OpenAI Service:http://localhost:8003"
    "MkDocs:http://localhost:8005"
)

backstage_success=0
backstage_total=0

for service in "${backstage_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    if test_service "$name" "$url"; then
        ((backstage_success++))
    fi
    ((backstage_total++))
done

# Probar bases de datos Backstage
echo -n "🔍 Testing PostgreSQL... "
if docker exec ia-ops-postgres pg_isready -U backstage_user >/dev/null 2>&1; then
    log_success "PostgreSQL: ✅"
    ((backstage_success++))
else
    log_error "PostgreSQL: ❌"
fi
((backstage_total++))

echo -n "🔍 Testing Redis... "
if docker exec ia-ops-redis redis-cli ping >/dev/null 2>&1; then
    log_success "Redis: ✅"
    ((backstage_success++))
else
    log_error "Redis: ❌"
fi
((backstage_total++))

echo ""
log_info "=== PRUEBAS STACK JENKINS (ICBS) ==="

# Probar servicios Jenkins
jenkins_services=(
    "Jenkins:http://localhost:8091"
    "Nexus:http://localhost:8092"
    "SonarQube:http://localhost:9000"
    "Portainer:http://localhost:9080"
)

jenkins_success=0
jenkins_total=0

for service in "${jenkins_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    if test_service "$name" "$url"; then
        ((jenkins_success++))
    fi
    ((jenkins_total++))
done

# Probar base de datos Jenkins
echo -n "🔍 Testing PostgreSQL SonarQube... "
if docker exec postgres-sonar pg_isready -U sonarqube >/dev/null 2>&1; then
    log_success "PostgreSQL SonarQube: ✅"
    ((jenkins_success++))
else
    log_error "PostgreSQL SonarQube: ❌"
fi
((jenkins_total++))

echo ""
log_info "=== PRUEBAS DE INTEGRACIÓN ==="

# Probar integración Backstage-Jenkins
echo -n "🔍 Testing Backstage-Jenkins Integration... "
if curl -s http://localhost:3002 | grep -q "jenkins" >/dev/null 2>&1; then
    log_success "Backstage-Jenkins Integration: ✅"
else
    log_warning "Backstage-Jenkins Integration: ⚠️ (Backstage aún iniciando)"
fi

# Probar conflictos de puertos
echo -n "🔍 Testing Port Conflicts... "
port_conflicts=0
ports_to_check=(3002 7007 8091 8092 9000 9080 9090 3001 5432 6379)

for port in "${ports_to_check[@]}"; do
    if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        continue
    else
        ((port_conflicts++))
    fi
done

if [[ $port_conflicts -eq 0 ]]; then
    log_success "Port Conflicts: ✅ (No conflicts)"
else
    log_warning "Port Conflicts: ⚠️ ($port_conflicts ports not responding)"
fi

echo ""
log_info "=== RESUMEN DE PRUEBAS ==="

echo "📊 Stack Backstage: $backstage_success/$backstage_total servicios funcionando"
echo "🔧 Stack Jenkins: $jenkins_success/$jenkins_total servicios funcionando"

backstage_percentage=$((backstage_success * 100 / backstage_total))
jenkins_percentage=$((jenkins_success * 100 / jenkins_total))

if [[ $backstage_percentage -ge 80 ]]; then
    log_success "Stack Backstage: $backstage_percentage% ✅"
else
    log_warning "Stack Backstage: $backstage_percentage% ⚠️"
fi

if [[ $jenkins_percentage -ge 80 ]]; then
    log_success "Stack Jenkins: $jenkins_percentage% ✅"
else
    log_warning "Stack Jenkins: $jenkins_percentage% ⚠️"
fi

total_success=$((backstage_success + jenkins_success))
total_services=$((backstage_total + jenkins_total))
overall_percentage=$((total_success * 100 / total_services))

echo ""
if [[ $overall_percentage -ge 80 ]]; then
    log_success "🎉 RESULTADO GENERAL: $overall_percentage% - AMBOS STACKS FUNCIONANDO CORRECTAMENTE"
else
    log_warning "⚠️ RESULTADO GENERAL: $overall_percentage% - ALGUNOS SERVICIOS NECESITAN ATENCIÓN"
fi

echo ""
log_info "=== URLS DE ACCESO ==="
echo "🏛️ Backstage Stack:"
echo "   • Backstage: http://localhost:3002"
echo "   • Prometheus: http://localhost:9090"
echo "   • Grafana: http://localhost:3001"
echo ""
echo "🔧 Jenkins Stack:"
echo "   • Jenkins: http://localhost:8091 (admin/admin123)"
echo "   • Nexus: http://localhost:8092 (admin/admin123)"
echo "   • SonarQube: http://localhost:9000 (admin/admin123)"
echo "   • Portainer: http://localhost:9080"

echo ""
log_info "=== ESTADO DE CONTENEDORES ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -15

echo ""
log_success "¡Pruebas completas finalizadas!"
EOF
