# Arquitectura del Sistema

## 🏗️ Diagrama de Arquitectura General

```mermaid
graph TB
    subgraph "IA-Ops Portal"
        A[Business Ideas Module]
        B[Provider Connectors]
        C[Task Structure Engine]
        D[Refinement Workspace]
        E[Submission & Tracking]
        F[Portal Links Hub]
    end
    
    subgraph "Core Services"
        G[Backstage - Service Catalog]
        H[Dev-Core - APIs]
        I[Docs - Documentation]
        J[Veritas - Validation]
    end
    
    subgraph "Security & Monitoring"
        K[Guard - Security]
        L[Monitoring - Observability]
    end
    
    subgraph "External Providers"
        M[Jira]
        N[Azure DevOps]
        O[GitHub]
        P[Custom APIs]
    end
    
    subgraph "Data Layer"
        Q[PostgreSQL]
        R[MinIO Storage]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    
    B --> M
    B --> N
    B --> O
    B --> P
    
    A --> H
    C --> H
    D --> H
    E --> H
    
    H --> Q
    H --> R
    
    F --> G
    F --> I
    F --> J
    F --> K
    F --> L
```

## 🎯 Componentes Principales

### 1. Business Ideas Module
**Propósito**: Captura y gestión inicial de ideas de negocio

**Funcionalidades**:
- Formulario inteligente de captura
- Categorización automática
- Evaluación de viabilidad
- Priorización basada en criterios

**Tecnologías**: React, TypeScript, API REST

### 2. Provider Connectors
**Propósito**: Integración con sistemas externos de gestión de proyectos

**Providers Soportados**:
- **Jira**: Issues, Epics, Stories, Tasks
- **Azure DevOps**: Work Items, Boards, Backlogs
- **GitHub**: Issues, Projects, Milestones
- **Custom**: APIs personalizadas

**Patrón de Diseño**: Strategy Pattern para intercambio de providers

### 3. Task Structure Engine
**Propósito**: Mapeo dinámico de estructuras organizacionales a estructuras de providers

**Características**:
- Templates configurables por área organizacional
- Mapeo automático de campos
- Validación de estructura
- Adaptación a diferentes modelos

### 4. Refinement Workspace
**Propósito**: Espacio colaborativo para ajustar propuestas antes de la creación

**Funcionalidades**:
- Editor visual de estructura
- Comentarios y sugerencias
- Versionado de cambios
- Aprobación por roles

### 5. Submission & Tracking
**Propósito**: Creación final y seguimiento de tareas en providers

**Características**:
- Cola de procesamiento
- Logs detallados de creación
- Estado de sincronización
- Auditoría completa

## 🔄 Flujo de Datos

```mermaid
sequenceDiagram
    participant U as Usuario
    participant BI as Business Ideas
    participant PC as Provider Connector
    participant TSE as Task Structure Engine
    participant RW as Refinement Workspace
    participant ST as Submission & Tracking
    participant EP as External Provider
    
    U->>BI: Crear idea de negocio
    BI->>TSE: Solicitar estructura sugerida
    TSE->>PC: Obtener template del provider
    PC->>TSE: Retornar estructura
    TSE->>BI: Proponer estructura
    BI->>RW: Enviar a refinamiento
    U->>RW: Ajustar y aprobar
    RW->>ST: Enviar para creación
    ST->>PC: Crear tareas
    PC->>EP: Ejecutar creación
    EP->>PC: Confirmar creación
    PC->>ST: Actualizar estado
    ST->>U: Notificar completado
```

## 🏢 Áreas Organizacionales

### Estructura Configurable
```yaml
organizational_areas:
  requirements:
    name: "Requerimientos"
    roles: ["Business Analyst", "Product Owner"]
    templates: ["user_story", "acceptance_criteria"]
    
  architecture:
    name: "Arquitectura"
    roles: ["Solution Architect", "Technical Lead"]
    templates: ["technical_design", "architecture_decision"]
    
  development:
    name: "Desarrollo"
    roles: ["Developer", "Tech Lead"]
    templates: ["feature", "bug_fix", "technical_debt"]
    
  testing:
    name: "Pruebas"
    roles: ["QA Engineer", "Test Lead"]
    templates: ["test_case", "test_plan", "defect"]
    
  security:
    name: "Seguridad"
    roles: ["Security Engineer", "Security Architect"]
    templates: ["security_review", "vulnerability_assessment"]
    
  devops:
    name: "DevOps"
    roles: ["DevOps Engineer", "Platform Engineer"]
    templates: ["deployment", "infrastructure", "automation"]
    
  infrastructure:
    name: "Infraestructura"
    roles: ["Infrastructure Engineer", "Cloud Architect"]
    templates: ["provisioning", "configuration", "monitoring"]
    
  operations:
    name: "Operaciones"
    roles: ["Operations Engineer", "Site Reliability Engineer"]
    templates: ["incident", "maintenance", "runbook"]
    
  monitoring:
    name: "Monitoreo"
    roles: ["Monitoring Engineer", "Observability Engineer"]
    templates: ["alert", "dashboard", "metric"]
```

## 🔧 Tecnologías Utilizadas

### Frontend
- **React 18**: UI principal
- **TypeScript**: Tipado estático
- **Material-UI**: Componentes de interfaz
- **React Query**: Gestión de estado del servidor

### Backend
- **Node.js**: Runtime principal
- **Express**: Framework web
- **TypeScript**: Tipado estático
- **Prisma**: ORM para base de datos

### Base de Datos
- **PostgreSQL**: Base de datos principal
- **MinIO**: Almacenamiento de objetos

### Infraestructura
- **Docker**: Containerización
- **Docker Compose**: Orquestación local
- **Nginx**: Proxy reverso

## 📊 Métricas y Monitoreo

### KPIs del Sistema
- Tiempo promedio de creación de ideas
- Tasa de conversión idea → proyecto
- Tiempo de refinamiento por área
- Éxito de sincronización con providers
- Satisfacción del usuario

### Observabilidad
- Logs estructurados (JSON)
- Métricas de performance
- Trazabilidad distribuida
- Alertas automáticas
