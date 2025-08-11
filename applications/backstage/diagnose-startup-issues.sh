#!/bin/bash

# =============================================================================
# Script de Diagnóstico para Problemas de Inicio de Backstage
# =============================================================================

echo "🔍 Diagnóstico de Problemas de Backstage"
echo "========================================"

# Función para logging con colores
log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }

# 1. Verificar archivos de configuración
log_info "📋 Verificando archivos de configuración..."

if [ -f "app-config.yaml" ]; then
    log_success "✅ app-config.yaml existe"
else
    log_error "❌ app-config.yaml no existe"
fi

if [ -f "../../.env" ]; then
    log_success "✅ .env existe"
    source ../../.env
else
    log_error "❌ .env no existe"
fi

# 2. Verificar variables de entorno críticas
log_info "🔧 Verificando variables de entorno críticas..."

check_var() {
    local var_name=$1
    local var_value=${!var_name}
    if [ -n "$var_value" ]; then
        log_success "✅ $var_name está definido"
    else
        log_error "❌ $var_name no está definido"
    fi
}

check_var "BACKEND_SECRET"
check_var "POSTGRES_HOST"
check_var "POSTGRES_PORT"
check_var "POSTGRES_USER"
check_var "POSTGRES_PASSWORD"
check_var "POSTGRES_DB"
check_var "GITHUB_TOKEN"

# 3. Verificar servicios Docker
log_info "🐳 Verificando servicios Docker..."

cd ../../
services=("postgres" "redis")
for service in "${services[@]}"; do
    if docker-compose ps $service | grep -q "Up"; then
        log_success "✅ $service está corriendo"
    else
        log_error "❌ $service no está corriendo"
    fi
done

# 4. Verificar conectividad de base de datos
log_info "🗄️ Verificando conectividad de base de datos..."

if docker-compose exec -T postgres pg_isready -U $POSTGRES_USER -d $POSTGRES_DB >/dev/null 2>&1; then
    log_success "✅ PostgreSQL está accesible"
    
    # Verificar si la base de datos tiene tablas
    table_count=$(docker-compose exec -T postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    if [ "$table_count" -gt 0 ]; then
        log_success "✅ Base de datos tiene $table_count tablas"
    else
        log_warn "⚠️  Base de datos está vacía (sin tablas)"
    fi
else
    log_error "❌ No se puede conectar a PostgreSQL"
fi

cd applications/backstage

# 5. Verificar puertos
log_info "🌐 Verificando puertos..."

check_port() {
    local port=$1
    local service=$2
    if lsof -ti:$port >/dev/null 2>&1; then
        log_warn "⚠️  Puerto $port ($service) está ocupado"
        local pid=$(lsof -ti:$port)
        local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
        echo "    Proceso: $process (PID: $pid)"
    else
        log_success "✅ Puerto $port ($service) está libre"
    fi
}

check_port 3002 "Frontend"
check_port 7007 "Backend"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"

# 6. Verificar dependencias de Node.js
log_info "📦 Verificando dependencias de Node.js..."

if [ -d "node_modules" ]; then
    log_success "✅ node_modules existe"
    
    # Verificar integridad de yarn
    if [ -f "node_modules/.yarn-integrity" ]; then
        log_success "✅ Yarn integrity check OK"
    else
        log_warn "⚠️  Yarn integrity check faltante"
    fi
else
    log_error "❌ node_modules no existe"
fi

# 7. Verificar archivos de TypeScript
log_info "🔧 Verificando configuración de TypeScript..."

if [ -f "tsconfig.json" ]; then
    log_success "✅ tsconfig.json existe"
else
    log_error "❌ tsconfig.json no existe"
fi

# 8. Verificar logs recientes
log_info "📋 Verificando logs recientes..."

if [ -f "backstage-clean-final.log" ]; then
    log_info "📄 Últimas líneas del log:"
    tail -10 backstage-clean-final.log | while read line; do
        if echo "$line" | grep -q "error\|Error\|ERROR"; then
            log_error "   $line"
        elif echo "$line" | grep -q "warn\|Warning\|WARN"; then
            log_warn "   $line"
        else
            echo "   $line"
        fi
    done
fi

# 9. Verificar configuración de autenticación
log_info "🔐 Verificando configuración de autenticación..."

if grep -q "auth:" app-config.yaml 2>/dev/null; then
    log_success "✅ Configuración de auth encontrada"
else
    log_warn "⚠️  Configuración de auth no encontrada"
fi

# 10. Resumen y recomendaciones
echo ""
log_info "📊 RESUMEN Y RECOMENDACIONES:"
echo "================================"

echo ""
echo "🔧 Para solucionar problemas comunes:"
echo "1. Ejecutar: ./fix-backstage-startup.sh"
echo "2. Si persisten errores de DB: docker-compose restart postgres"
echo "3. Si hay problemas de dependencias: rm -rf node_modules && yarn install"
echo "4. Para logs detallados: yarn start --verbose"
echo ""
echo "🌐 URLs una vez iniciado:"
echo "- Frontend: http://localhost:3002"
echo "- Backend: http://localhost:7007"
echo "- Proxy: http://localhost:8080"
echo ""
echo "📞 Si necesitas ayuda adicional, revisa los logs en:"
echo "- backstage-clean-final.log"
echo "- backstage-production.log"
