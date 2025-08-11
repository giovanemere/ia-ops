# 🚀 Backstage Auto-Discovery Guide

## ✅ **CONFIGURACIÓN COMPLETADA**

Tu Backstage ya está configurado para documentar automáticamente:
- 📚 **Documentación** (TechDocs)
- 👀 **Source Code** (GitHub Integration)
- 🔄 **CI/CD** (GitHub Actions)
- 📊 **Métricas y Monitoreo**

---

## 🎯 **INICIO RÁPIDO**

### 1. **Configurar Auto-Discovery (Solo una vez)**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./setup-auto-discovery.sh
```

### 2. **Iniciar Backstage con Auto-Discovery**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./start-with-auto-discovery.sh
```

### 3. **Acceder a la Interfaz**
- **URL Principal**: http://localhost:3002
- **Catálogo**: http://localhost:3002/catalog
- **Documentación**: http://localhost:3002/docs

---

## 🔍 **QUÉ VERÁS AUTOMÁTICAMENTE**

### **📚 Documentación Automática (TechDocs)**
- ✅ Documentación generada desde `mkdocs.yml` de cada repositorio
- ✅ Actualización automática cada 30 minutos
- ✅ Soporte para Markdown, diagramas y código
- ✅ Navegación integrada en Backstage

**Ubicación**: Pestaña "Docs" en cada componente

### **👀 Source Code Browsing**
- ✅ Navegación del código fuente directamente en Backstage
- ✅ Historial de commits y cambios
- ✅ Información de contributors
- ✅ Enlaces directos a GitHub

**Ubicación**: Pestaña "Source" en cada componente

### **🔄 CI/CD Integration (GitHub Actions)**
- ✅ Estado de workflows en tiempo real
- ✅ Historial de builds y deployments
- ✅ Logs de ejecución detallados
- ✅ Métricas de success rate

**Ubicación**: Pestaña "CI/CD" en cada componente

### **📊 Métricas y Monitoreo**
- ✅ Code coverage automático
- ✅ Dependency tracking
- ✅ Security vulnerabilities
- ✅ Performance metrics

**Ubicación**: Pestañas "Coverage" y "Dependencies"

---

## 🏗️ **REPOSITORIOS AUTO-DESCUBIERTOS**

| Repositorio | Tipo | Documentación | CI/CD | Source |
|-------------|------|---------------|-------|--------|
| **ia-ops** | Platform | ✅ Auto | ✅ 2 workflows | ✅ GitHub |
| **poc-billpay-back** | Spring Boot | ✅ Auto | ✅ Enterprise CI/CD | ✅ GitHub |
| **poc-billpay-front-a** | Angular | ✅ Auto | ✅ Lighthouse + E2E | ✅ GitHub |
| **poc-billpay-front-b** | Angular A/B | ✅ Auto | ✅ A/B Testing | ✅ GitHub |
| **poc-billpay-front-feature-flags** | Angular FF | ✅ Auto | ✅ Feature Flags | ✅ GitHub |
| **poc-icbs** | Oracle WebLogic | ✅ Auto | ✅ Enterprise | ✅ GitHub |

---

## ⚙️ **CONFIGURACIÓN AUTOMÁTICA**

### **Variables de Entorno Configuradas**
```bash
# GitHub Integration
GITHUB_TOKEN=tu_token_configurado
GITHUB_ORG=giovanemere

# TechDocs
TECHDOCS_BUILDER=local
TECHDOCS_GENERATOR_RUNIN=docker
TECHDOCS_PUBLISHER_TYPE=local

# Auto-Discovery
GITHUB_ACTIONS_REFRESH_INTERVAL=600000  # 10 minutos
```

### **Plugins Instalados Automáticamente**
- `@backstage/plugin-github-actions` - CI/CD integration
- `@backstage/plugin-techdocs` - Documentation
- `@backstage/plugin-github` - Source code browsing
- `@backstage/plugin-catalog-backend-module-github` - Auto-discovery
- `@backstage/plugin-code-coverage` - Coverage reports

---

## 🔄 **PROGRAMACIÓN DE ACTUALIZACIONES**

### **Auto-Discovery Schedule**
- **Repositorios**: Cada 30 minutos
- **GitHub Actions**: Cada 10 minutos
- **Documentación**: On-demand + scheduled
- **Métricas**: Tiempo real

### **Triggers Manuales**
```bash
# Forzar actualización del catálogo
curl -X POST http://localhost:7007/api/catalog/refresh

# Regenerar documentación
curl -X POST http://localhost:7007/api/techdocs/sync
```

---

## 📋 **NAVEGACIÓN EN BACKSTAGE**

### **1. Catálogo Principal**
- Ve a **Catalog** para ver todos los componentes
- Filtra por tipo: Components, APIs, Resources
- Busca por nombre o tecnología

### **2. Vista de Componente**
Cada componente tiene pestañas:
- **Overview**: Información general y dependencias
- **Docs**: Documentación automática
- **CI/CD**: GitHub Actions workflows
- **Source**: Código fuente y commits
- **Coverage**: Cobertura de código
- **Dependencies**: Dependencias y relaciones

### **3. Búsqueda Global**
- Usa la barra de búsqueda superior
- Busca por nombre, descripción, tecnología
- Filtros avanzados disponibles

---

## 🛠️ **PERSONALIZACIÓN**

### **Agregar Más Repositorios**
1. Edita `app-config.yaml`:
```yaml
catalog:
  providers:
    github:
      giovanemere:
        organization: 'giovanemere'
        filters:
          repository: 'nuevo-repo-pattern'
```

2. Reinicia Backstage

### **Configurar Documentación Personalizada**
1. Crea `mkdocs.yml` en tu repositorio
2. Agrega contenido en carpeta `docs/`
3. La documentación aparecerá automáticamente

### **Personalizar Workflows**
Los workflows aparecen automáticamente si están en `.github/workflows/`

---

## 🔧 **TROUBLESHOOTING**

### **Problema: Repositorio no aparece**
```bash
# Verificar configuración
curl http://localhost:7007/api/catalog/entities

# Forzar refresh
curl -X POST http://localhost:7007/api/catalog/refresh
```

### **Problema: Documentación no se genera**
1. Verifica que existe `mkdocs.yml` en el repo
2. Verifica que Docker está ejecutándose
3. Revisa logs: `docker logs backstage_backend`

### **Problema: GitHub Actions no aparecen**
1. Verifica `GITHUB_TOKEN` en `.env`
2. Verifica que el token tiene permisos de `repo` y `actions:read`
3. Reinicia Backstage

---

## 📞 **SOPORTE**

### **Logs Útiles**
```bash
# Backend logs
docker logs backstage_backend

# Frontend logs
docker logs backstage_frontend

# TechDocs logs
docker logs techdocs_generator
```

### **URLs de Debug**
- **API Health**: http://localhost:7007/api/catalog/health
- **Entities**: http://localhost:7007/api/catalog/entities
- **GitHub Integration**: http://localhost:7007/api/github/health

### **Archivos de Configuración**
- **Principal**: `app-config.yaml`
- **Variables**: `.env`
- **Catálogo**: `catalog-auto-discovery.yaml`

---

## 🎉 **¡LISTO PARA USAR!**

Tu Backstage ahora documenta automáticamente:
- ✅ **6 repositorios** con auto-discovery
- ✅ **Documentación** generada automáticamente
- ✅ **CI/CD workflows** integrados
- ✅ **Source code** navegable
- ✅ **Métricas** en tiempo real

**🚀 Ejecuta `./start-with-auto-discovery.sh` y disfruta de tu plataforma automatizada!**

---

*Última actualización: 2025-08-11*  
*Configuración verificada: ✅ Completa*
