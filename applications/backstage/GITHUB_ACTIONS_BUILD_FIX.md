# 🔧 Corrección de GitHub Actions Build - Backstage

## 🚨 Problema Identificado

El workflow de GitHub Actions fallaba con el error:
```
ERROR: failed to build: failed to solve: failed to read dockerfile: open Dockerfile.optimized: no such file or directory
```

## ✅ Soluciones Aplicadas

### 1. **Creación de Dockerfile.optimized**
- ✅ Creado `Dockerfile.optimized` específico para CI/CD
- ✅ Optimizado para builds multi-stage con cache
- ✅ Actualizado a Node.js 20 (compatible con package.json)
- ✅ Mejorada gestión de dependencias con Yarn 4.4.1

### 2. **Actualización de Dockerfile Principal**
- ✅ Actualizado `Dockerfile` a Node.js 20
- ✅ Mejorada configuración de build
- ✅ Añadido soporte para .yarnrc.yml

### 3. **Optimización de .dockerignore**
- ✅ Mejorado para excluir archivos innecesarios
- ✅ Reducido tamaño del contexto de build
- ✅ Excluidos logs, tests y archivos temporales

### 4. **Corrección del Workflow**
- ✅ Workflow actualizado para usar `Dockerfile.optimized`
- ✅ Configuración correcta de contexto y archivo
- ✅ Mantenido soporte para multi-arquitectura (amd64, arm64)

## 📁 Archivos Modificados/Creados

```
applications/backstage/
├── Dockerfile                    # ✅ Actualizado (Node 20)
├── Dockerfile.optimized          # ✅ Nuevo (CI/CD optimizado)
├── .dockerignore                 # ✅ Mejorado
├── test-docker-build.sh          # ✅ Nuevo (pruebas locales)
├── diagnose-github-build.sh      # ✅ Nuevo (diagnóstico)
└── GITHUB_ACTIONS_BUILD_FIX.md   # ✅ Este archivo

.github/workflows/
└── backstage-build.yml           # ✅ Corregido
```

## 🏗️ Características del Dockerfile.optimized

### Multi-Stage Build Optimizado:
1. **base**: Imagen base con dependencias del sistema
2. **dependencies**: Instalación de dependencias Node.js
3. **build**: Compilación de la aplicación
4. **runtime**: Imagen final optimizada

### Optimizaciones:
- ✅ Cache de dependencias separado
- ✅ Usuario no-root para seguridad
- ✅ Health check incluido
- ✅ Logs directory configurado
- ✅ Configuración multi-arquitectura

## 🧪 Verificación

### Diagnóstico Completo:
```bash
./diagnose-github-build.sh
```

### Prueba Local:
```bash
./test-docker-build.sh
```

### Resultados del Diagnóstico:
- ✅ Todos los archivos críticos presentes
- ✅ Versiones de Node.js consistentes (20)
- ✅ Yarn 4.4.1 configurado correctamente
- ✅ Workflow referencia Dockerfile.optimized
- ✅ Estructura de directorios correcta

## 🎯 Workflow Actualizado

```yaml
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: ./applications/backstage
    file: ./applications/backstage/Dockerfile.optimized  # ✅ Corregido
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
    platforms: linux/amd64,linux/arm64
```

## 🚀 Próximos Pasos

1. **Commit y Push**: Subir cambios al repositorio
2. **Trigger Build**: Push a branch `trunk` para activar workflow
3. **Monitorear**: Verificar que el build sea exitoso
4. **Validar**: Confirmar que la imagen se publique en GHCR

## 📊 Beneficios de las Correcciones

- 🚀 **Build más rápido**: Cache optimizado y stages separados
- 🔒 **Más seguro**: Usuario no-root y health checks
- 📦 **Menor tamaño**: .dockerignore optimizado
- 🔧 **Más mantenible**: Dockerfiles separados para dev/prod
- 🎯 **Más confiable**: Diagnósticos y pruebas incluidos

## ✅ Estado Final

- ✅ Error de Dockerfile.optimized resuelto
- ✅ Compatibilidad Node.js 20 asegurada
- ✅ Workflow de GitHub Actions corregido
- ✅ Optimizaciones de build aplicadas
- ✅ Scripts de diagnóstico y prueba creados

**🎉 El build de GitHub Actions ahora debería funcionar correctamente!**
