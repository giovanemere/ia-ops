#!/bin/bash

echo "🔍 Diagnosticando problema de linting en Backstage..."
echo "=================================================="

# Verificar si hay procesos de linting corriendo
echo "1. Verificando procesos activos..."
LINT_PROCESSES=$(ps aux | grep -E "(lint|eslint)" | grep -v grep)
if [ -n "$LINT_PROCESSES" ]; then
    echo "⚠️  Procesos de linting encontrados:"
    echo "$LINT_PROCESSES"
    echo ""
    echo "🛑 Matando procesos de linting..."
    pkill -f "lint" || true
    pkill -f "eslint" || true
else
    echo "✅ No hay procesos de linting corriendo"
fi

# Verificar yarn processes
echo ""
echo "2. Verificando procesos de yarn..."
YARN_PROCESSES=$(ps aux | grep yarn | grep -v grep)
if [ -n "$YARN_PROCESSES" ]; then
    echo "⚠️  Procesos de yarn encontrados:"
    echo "$YARN_PROCESSES"
else
    echo "✅ No hay procesos de yarn corriendo"
fi

# Verificar archivos de lock
echo ""
echo "3. Verificando archivos de lock..."
if [ -f ".eslintcache" ]; then
    echo "⚠️  Encontrado .eslintcache - eliminando..."
    rm -f .eslintcache
fi

if [ -f "node_modules/.cache" ]; then
    echo "⚠️  Encontrado cache de node_modules - limpiando..."
    rm -rf node_modules/.cache
fi

# Verificar configuración de ESLint
echo ""
echo "4. Verificando configuración de ESLint..."
if [ -f ".eslintrc.js" ]; then
    echo "✅ .eslintrc.js encontrado"
    echo "Contenido:"
    cat .eslintrc.js
else
    echo "❌ .eslintrc.js no encontrado"
fi

# Verificar package.json scripts
echo ""
echo "5. Verificando scripts de package.json..."
if [ -f "package.json" ]; then
    echo "Scripts de linting disponibles:"
    grep -A 5 -B 5 "lint" package.json || echo "No se encontraron scripts de lint"
else
    echo "❌ package.json no encontrado"
fi

# Test rápido de linting
echo ""
echo "6. Probando comando de linting con timeout..."
echo "Ejecutando: timeout 30s yarn lint:all --help"
if timeout 30s yarn lint:all --help 2>&1; then
    echo "✅ Comando de linting responde correctamente"
else
    echo "❌ Comando de linting no responde o tiene problemas"
fi

# Verificar memoria y recursos
echo ""
echo "7. Verificando recursos del sistema..."
echo "Memoria disponible:"
free -h
echo ""
echo "Espacio en disco:"
df -h . | tail -1

# Verificar node_modules
echo ""
echo "8. Verificando node_modules..."
if [ -d "node_modules" ]; then
    echo "✅ node_modules existe"
    echo "Tamaño: $(du -sh node_modules | cut -f1)"
    
    # Verificar eslint específicamente
    if [ -d "node_modules/.bin" ]; then
        echo "Binarios disponibles:"
        ls -la node_modules/.bin/ | grep -E "(eslint|lint)" || echo "No se encontraron binarios de linting"
    fi
else
    echo "❌ node_modules no existe - ejecutar yarn install"
fi

echo ""
echo "🔧 Recomendaciones para solucionar el problema:"
echo "=============================================="
echo "1. Limpiar cache: yarn cache clean"
echo "2. Reinstalar dependencias: rm -rf node_modules && yarn install"
echo "3. Usar linting con timeout: timeout 60s yarn lint:all"
echo "4. Saltar linting temporalmente: modificar sync-env-config.sh"
echo ""
echo "🚀 Script de solución rápida:"
echo "cd /home/giovanemere/ia-ops/ia-ops/applications/backstage"
echo "./fix-linting-timeout.sh"
