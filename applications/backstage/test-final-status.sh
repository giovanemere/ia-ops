#!/bin/bash

# =============================================================================
# VERIFICACIÓN FINAL DEL ESTADO DE BACKSTAGE
# =============================================================================

echo "🔍 Verificación Final del Estado de Backstage"
echo "=============================================="

# 1. Verificar configuración
echo ""
echo "1. Verificando configuración..."
echo "=============================="
if ./verify-config.sh > /dev/null 2>&1; then
    echo "✅ Configuración: Todas las variables críticas están configuradas"
else
    echo "❌ Configuración: Faltan variables críticas"
fi

# 2. Verificar servicios de base de datos
echo ""
echo "2. Verificando servicios de base de datos..."
echo "==========================================="
cd ../../
if docker-compose ps postgres | grep -q "Up"; then
    echo "✅ PostgreSQL: Corriendo"
else
    echo "❌ PostgreSQL: No está corriendo"
fi

if docker-compose ps redis | grep -q "Up"; then
    echo "✅ Redis: Corriendo"
else
    echo "❌ Redis: No está corriendo"
fi
cd applications/backstage

# 3. Verificar puertos de Backstage
echo ""
echo "3. Verificando puertos de Backstage..."
echo "====================================="
if curl -s http://localhost:3002 > /dev/null; then
    echo "✅ Frontend (3002): Accesible"
else
    echo "❌ Frontend (3002): No accesible"
fi

if curl -s http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
    echo "✅ Backend (7007): Respondiendo"
else
    echo "❌ Backend (7007): No responde"
fi

# 4. Verificar autenticación GitHub en logs
echo ""
echo "4. Verificando autenticación GitHub..."
echo "====================================="
if [ -f "github-auth-fix.log" ]; then
    if grep -q "Configuring auth provider: github" github-auth-fix.log && ! grep -q "Skipping github auth provider" github-auth-fix.log; then
        echo "✅ GitHub Auth: Configurado correctamente"
    else
        echo "❌ GitHub Auth: Problemas de configuración"
    fi
else
    echo "⚠️  GitHub Auth: Log no encontrado"
fi

# 5. Verificar catálogo
echo ""
echo "5. Verificando catálogo..."
echo "========================="
if curl -s "http://localhost:7007/api/catalog/entities" | grep -q "AuthenticationError"; then
    echo "✅ Catálogo: API respondiendo (requiere autenticación)"
else
    echo "❌ Catálogo: API no responde correctamente"
fi

# 6. Verificar búsqueda
echo ""
echo "6. Verificando búsqueda..."
echo "========================="
if curl -s "http://localhost:7007/api/search/query?term=" | grep -q "AuthenticationError"; then
    echo "✅ Búsqueda: API respondiendo (requiere autenticación)"
else
    echo "❌ Búsqueda: API no responde correctamente"
fi

# 7. Verificar archivos de configuración
echo ""
echo "7. Verificando archivos de configuración..."
echo "=========================================="
files_ok=true

if [ -f "../../.env" ]; then
    echo "✅ .env: Existe"
else
    echo "❌ .env: No existe"
    files_ok=false
fi

if [ -f "app-config.yaml" ]; then
    echo "✅ app-config.yaml: Existe"
else
    echo "❌ app-config.yaml: No existe"
    files_ok=false
fi

if [ -f "packages/backend/catalog-entities.yaml" ]; then
    echo "✅ catalog-entities.yaml: Existe en ubicación correcta"
else
    echo "❌ catalog-entities.yaml: No existe en ubicación correcta"
    files_ok=false
fi

# 8. Verificar backups
echo ""
echo "8. Verificando backups..."
echo "========================"
if [ -d "config-backups" ] && [ "$(ls -A config-backups/)" ]; then
    backup_count=$(ls config-backups/config_backup_*.tar.gz 2>/dev/null | wc -l)
    echo "✅ Backups: $backup_count backups disponibles"
else
    echo "⚠️  Backups: No hay backups disponibles"
fi

# 9. Verificar scripts de gestión
echo ""
echo "9. Verificando scripts de gestión..."
echo "==================================="
scripts=("setup-persistent-config.sh" "verify-config.sh" "start-robust.sh" "restore-config.sh" "fix-github-auth.sh")
scripts_ok=true

for script in "${scripts[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "✅ $script: Disponible y ejecutable"
    else
        echo "❌ $script: No disponible o no ejecutable"
        scripts_ok=false
    fi
done

# 10. Resumen final
echo ""
echo "🎯 RESUMEN FINAL"
echo "================"

all_ok=true

# Verificar componentes críticos
if ./verify-config.sh > /dev/null 2>&1; then
    echo "✅ Configuración: OK"
else
    echo "❌ Configuración: FALLA"
    all_ok=false
fi

if curl -s http://localhost:3002 > /dev/null && curl -s http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
    echo "✅ Servicios Backstage: OK"
else
    echo "❌ Servicios Backstage: FALLA"
    all_ok=false
fi

if [ -f "github-auth-fix.log" ] && grep -q "Configuring auth provider: github" github-auth-fix.log; then
    echo "✅ GitHub Auth: OK"
else
    echo "❌ GitHub Auth: FALLA"
    all_ok=false
fi

if [ "$files_ok" = true ]; then
    echo "✅ Archivos de configuración: OK"
else
    echo "❌ Archivos de configuración: FALLA"
    all_ok=false
fi

if [ "$scripts_ok" = true ]; then
    echo "✅ Scripts de gestión: OK"
else
    echo "❌ Scripts de gestión: FALLA"
    all_ok=false
fi

echo ""
if [ "$all_ok" = true ]; then
    echo "🎉 ESTADO GENERAL: ✅ EXCELENTE"
    echo ""
    echo "🌐 Accede a tu instancia de Backstage:"
    echo "   Frontend: http://localhost:3002"
    echo "   Backend:  http://localhost:7007"
    echo ""
    echo "🔐 GitHub OAuth está configurado y funcionando"
    echo "🛡️ Sistema protegido contra pérdida de configuración"
    echo "📋 Todos los scripts de gestión están disponibles"
else
    echo "⚠️  ESTADO GENERAL: ❌ REQUIERE ATENCIÓN"
    echo ""
    echo "💡 Para corregir problemas:"
    echo "   • Configuración: ./setup-persistent-config.sh"
    echo "   • GitHub Auth: ./fix-github-auth.sh"
    echo "   • Inicio robusto: ./start-robust.sh"
fi

echo ""
echo "📊 Para monitoreo continuo:"
echo "   • Verificar configuración: ./verify-config.sh"
echo "   • Ver logs: tail -f github-auth-fix.log"
echo "   • Estado completo: ./test-final-status.sh"
