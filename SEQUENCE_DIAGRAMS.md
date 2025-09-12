# IA-Ops Portal - Diagramas de Secuencia

## 1. Carga de Repositorios

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as Frontend :8845
    participant B as Backend :8846
    participant M as MinIO :9899
    
    U->>F: Accede a /techdocs
    F->>F: loadProjects()
    F->>B: GET /api/minio/folders
    B->>M: Lista folders en bucket iaops-portal/techdocs
    M-->>B: Retorna 12 folders
    B-->>F: JSON con folders array
    F->>F: Transforma folders a projects
    F->>F: displayProjects()
    F-->>U: Muestra 12 proyectos con botones
```

## 2. Visualización de Documentación

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as Frontend :8845
    participant MK as MkDocs :8854
    participant M as MinIO :9899
    
    U->>F: Click "Ver Docs" en proyecto
    F->>F: showProjectDocs(projectId)
    F->>F: Crea modal con iframe
    F->>MK: iframe src: /{projectId}/
    MK->>M: Obtiene docs del proyecto
    M-->>MK: Retorna archivos markdown
    MK->>MK: Genera HTML con MkDocs
    MK-->>F: Sirve documentación HTML
    F-->>U: Muestra docs en modal
```

## 3. Carga de Estadísticas

```mermaid
sequenceDiagram
    participant F as Frontend :8845
    participant B as Backend :8846
    participant M as MinIO :9899
    
    F->>F: loadStats()
    F->>B: GET /api/minio/folders
    B->>M: Lista folders
    M-->>B: Retorna folders array
    B-->>F: JSON con folders
    F->>F: Calcula stats dinámicas
    Note over F: totalDocs = folders.length<br/>activeDocs = folders.length<br/>builds = Math.floor(total * 0.8)
    F->>F: Actualiza elementos DOM
    F-->>F: Muestra stats en cards
```

## 4. Navegación en Modal de Documentación

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as Frontend :8845
    participant MK as MkDocs :8854
    
    U->>F: Click botón navegación (←, →, 🔄, 🏠, 🔗)
    F->>F: navigateIframe(action)
    
    alt action = 'back'
        F->>MK: iframe.contentWindow.history.back()
    else action = 'forward'
        F->>MK: iframe.contentWindow.history.forward()
    else action = 'reload'
        F->>MK: iframe.src = iframe.src
    else action = 'home'
        F->>MK: iframe.src = currentProjectUrl
    else action = 'openInNewTab'
        F->>F: window.open(iframe.src, '_blank')
    end
    
    MK-->>F: Actualiza contenido iframe
    F-->>U: Muestra nueva página
```

## 5. Flujo de Inicio de Servicios

```mermaid
sequenceDiagram
    participant Admin as Administrador
    participant D as ia-ops-docs
    participant C as ia-ops-dev-core
    participant MK as ia-ops-mkdocs
    participant M as MinIO
    
    Admin->>D: pkill + start docs_frontend.py
    D->>D: Inicia FastAPI :8845
    
    Admin->>C: ./start_backend_venv.sh
    C->>C: Inicia uvicorn :8846
    
    Admin->>MK: python3 mkdocs-server.py
    MK->>MK: Inicia Flask :8854
    MK->>M: Sincroniza folders iniciales
    
    Note over D,M: Todos los servicios listos<br/>Frontend puede obtener datos
```

## Endpoints Críticos

### Backend (ia-ops-dev-core)
- `GET /api/minio/folders` - Obtiene repositorios desde MinIO
- `POST /api/techdocs/build/{project_name}` - Build de documentación
- `GET /api/repositories` - Lista repositorios (legacy)

### Frontend (ia-ops-docs)
- `GET /techdocs` - Página principal TechDocs
- `GET /health` - Health check

### MkDocs (ia-ops-mkdocs)
- `GET /{project_name}/` - Documentación específica del proyecto
- Sincronización automática desde MinIO

## Flujo de Datos Crítico

1. **MinIO** almacena documentación en `iaops-portal/techdocs/{project}/`
2. **Backend** consulta MinIO via `/api/minio/folders`
3. **Frontend** obtiene lista y la transforma a formato UI
4. **MkDocs** sirve documentación directamente desde MinIO
5. **Modal** en Frontend muestra iframe apuntando a MkDocs
