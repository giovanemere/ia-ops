# IA-Ops Portal - Arquitectura del Sistema

## Diagrama de Arquitectura General

```mermaid
graph TB
    subgraph "Frontend Layer"
        UI[TechDocs Frontend<br/>:8845<br/>ia-ops-docs]
    end
    
    subgraph "Backend Layer"
        API[Backend API<br/>:8846<br/>ia-ops-dev-core]
        MKDOCS[MkDocs Server<br/>:8854<br/>ia-ops-mkdocs]
    end
    
    subgraph "Storage Layer"
        MINIO[MinIO Storage<br/>:9899<br/>ia-ops-minio]
        POSTGRES[PostgreSQL<br/>:5432<br/>ia-ops-postgres]
    end
    
    subgraph "External Services"
        BACKSTAGE[Backstage<br/>:3000<br/>ia-ops-backstage]
        OPENAI[OpenAI API<br/>:8000<br/>ia-ops-openai]
        VERITAS[Veritas Service<br/>ia-ops-veritas]
    end
    
    UI --> API
    UI --> MKDOCS
    API --> MINIO
    API --> POSTGRES
    MKDOCS --> MINIO
    UI --> BACKSTAGE
    API --> OPENAI
    API --> VERITAS
    
    classDef frontend fill:#e1f5fe
    classDef backend fill:#f3e5f5
    classDef storage fill:#e8f5e8
    classDef external fill:#fff3e0
    
    class UI frontend
    class API,MKDOCS backend
    class MINIO,POSTGRES storage
    class BACKSTAGE,OPENAI,VERITAS external
```

## Componentes Principales

### Frontend (Puerto 8845)
- **ia-ops-docs**: Portal de documentación técnica
- **Tecnologías**: FastAPI, Jinja2, Bootstrap 5
- **Funciones**: 
  - Interfaz web para TechDocs
  - Gestión de repositorios
  - Modal de navegación de documentación

### Backend (Puerto 8846)
- **ia-ops-dev-core**: API principal del sistema
- **Tecnologías**: FastAPI, Python
- **Funciones**:
  - API REST `/api/minio/folders`
  - Integración con MinIO
  - Gestión de configuraciones

### MkDocs Server (Puerto 8854)
- **ia-ops-mkdocs**: Servidor de documentación
- **Tecnologías**: MkDocs, Flask, Python
- **Funciones**:
  - Servir documentación de repositorios
  - Sincronización automática desde MinIO
  - Generación dinámica de sitios

## Puertos y Servicios

| Servicio | Puerto | Repositorio | Función |
|----------|--------|-------------|---------|
| Frontend | 8845 | ia-ops-docs | Portal web TechDocs |
| Backend | 8846 | ia-ops-dev-core | API REST |
| MkDocs | 8854 | ia-ops-mkdocs | Documentación |
| MinIO | 9899 | ia-ops-minio | Storage |
| PostgreSQL | 5432 | ia-ops-postgres | Database |
| Backstage | 3000 | ia-ops-backstage | Dev Portal |
| OpenAI | 8000 | ia-ops-openai | AI Services |
