#!/bin/bash
# Script para configurar pipeline completo de TechDocs

echo "🚀 Configurando Pipeline TechDocs Completo"
echo "=========================================="

# 1. Instalar dependencias Python
echo "📦 Instalando dependencias..."
cd /home/giovanemere/ia-ops/ia-ops-mkdocs
source mkdocs-env/bin/activate
pip install pyyaml requests

# 2. Verificar servicios necesarios
echo "🔍 Verificando servicios..."

# MinIO
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9899 | grep -q "200\|302"; then
    echo "✅ MinIO funcionando"
else
    echo "❌ MinIO no disponible en puerto 9899"
fi

# MkDocs Server
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8854 | grep -q "200"; then
    echo "✅ MkDocs Server funcionando"
else
    echo "❌ MkDocs Server no disponible en puerto 8854"
fi

# Portal TechDocs
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8845/techdocs | grep -q "200"; then
    echo "✅ Portal TechDocs funcionando"
else
    echo "❌ Portal TechDocs no disponible en puerto 8845"
fi

# 3. Crear directorio de procesamiento
echo "📁 Creando directorios..."
mkdir -p /tmp/repo_processing
mkdir -p /tmp/mkdocs_sites
mkdir -p /tmp/minio_docs

# 4. Verificar configuración MinIO
echo "🗄️  Verificando MinIO..."
if mc ls minio/iaops-portal/techdocs/ > /dev/null 2>&1; then
    echo "✅ Bucket techdocs configurado"
else
    echo "⚠️  Creando bucket techdocs..."
    mc mb minio/iaops-portal/techdocs/ 2>/dev/null || true
fi

# 5. Reiniciar servicios con nueva configuración
echo "🔄 Reiniciando servicios..."

# Reiniciar MkDocs con soporte Mermaid
pkill -f "mkdocs-mermaid.py" 2>/dev/null || true
sleep 2
cd /home/giovanemere/ia-ops/ia-ops-mkdocs
source mkdocs-env/bin/activate
nohup python3 mkdocs-mermaid.py > mkdocs.log 2>&1 &

# Reiniciar Portal TechDocs
pkill -f "docs_frontend.py" 2>/dev/null || true
sleep 2
cd /home/giovanemere/ia-ops/ia-ops-docs
nohup python3 docs_frontend.py > docs.log 2>&1 &

sleep 5

# 6. Verificar pipeline completo
echo "🧪 Verificando pipeline..."

# Test API endpoints
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8845/repositories | grep -q "200"; then
    echo "✅ /repositories disponible"
else
    echo "❌ /repositories no disponible"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8845/tasks | grep -q "200"; then
    echo "✅ /tasks disponible"
else
    echo "❌ /tasks no disponible"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8845/techdocs | grep -q "200"; then
    echo "✅ /techdocs disponible"
else
    echo "❌ /techdocs no disponible"
fi

echo ""
echo "✅ PIPELINE TECHDOCS CONFIGURADO"
echo "================================"
echo "🔗 URLs del Pipeline:"
echo "  📋 Repositories: http://localhost:8845/repositories"
echo "  📊 Tasks: http://localhost:8845/tasks"
echo "  📚 TechDocs: http://localhost:8845/techdocs"
echo "  🗄️  MinIO: http://localhost:9899/browser/iaops-portal/techdocs/"
echo ""
echo "🔄 Flujo Completo:"
echo "  1. Clonar repo en /repositories → Botón Build"
echo "  2. Procesamiento automático → MinIO"
echo "  3. Cola de tareas → /tasks"
echo "  4. MkDocs rebuild automático"
echo "  5. Visualización → /techdocs iframe"
echo ""
echo "📊 Soporte Diagramas:"
echo "  ✅ Mermaid (graph TB, LR, erDiagram, sequenceDiagram)"
echo "  ✅ Base URL automático"
echo "  ✅ Navegación completa"
