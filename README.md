# IA-Ops Portal

Portal principal que integra todos los módulos de la solución IA-Ops para gestión inteligente de proyectos y operaciones.

## 🏗️ Arquitectura

```
IA-Ops Portal
├── 💡 Business Ideas Module
├── 🔗 Provider Connectors (Jira, Azure, etc.)
├── 📋 Task Structure Management
├── 🏢 Organizational Structure
├── 🔄 Refinement Workspace
├── 📊 Submission & Tracking
└── 🌐 Portal Links Hub
```

## 🚀 Servicios Integrados

| Servicio | Puerto | Descripción | Estado |
|----------|--------|-------------|--------|
| **Backstage** | 3000 | Portal de desarrollo | ✅ |
| **Docs** | 8000 | Documentación | ✅ |
| **Dev-Core** | 8080 | APIs Core | ✅ |
| **Veritas** | 8081 | Validación | ✅ |
| **Guard** | 8082 | Seguridad | 🔄 |
| **Monitoring** | 8083 | Monitoreo | 🔄 |

## 🎯 Módulos Principales

### 1. Business Ideas Module
- Captura y gestión de ideas de negocio
- Evaluación y priorización
- Conversión a proyectos

### 2. Provider Connectors
- **Jira**: Integración completa
- **Azure DevOps**: Boards y Work Items
- **GitHub**: Issues y Projects
- **Extensible**: Nuevos providers

### 3. Task Structure Management
- Mapeo dinámico de estructuras
- Adaptación por provider
- Templates organizacionales

### 4. Organizational Areas
- Requerimientos
- Arquitectura
- Desarrollo
- Pruebas
- Seguridad
- DevOps
- Infraestructura
- Operaciones
- Monitoreo

## 🚀 Inicio Rápido

```bash
# Iniciar todos los servicios
./start-services-safe.sh

# Limpiar archivos temporales
./clean-root-only.sh

# Crear backup
./backup-root-files.sh
```

## 📁 Estructura del Proyecto

```
ia-ops/
├── portal/                 # Portal principal
├── docs/                   # Documentación MkDocs
├── api/                    # APIs del portal
├── providers/              # Conectores
├── modules/                # Módulos funcionales
├── config/                 # Configuraciones
└── scripts/                # Scripts de gestión
```

## 🔧 Configuración

Ver `config/README.md` para configuración detallada de providers y módulos.

## 📚 Documentación

La documentación completa está disponible en `/docs` y se sirve via MkDocs.

## 🤝 Contribución

Este es el repositorio principal que orquesta todos los módulos de IA-Ops.
