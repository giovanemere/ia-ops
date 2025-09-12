# Release v1.4.0 - TechDocs Portal Completo

## 🚀 Nuevas Funcionalidades

### ✅ Portal TechDocs Funcional
- **Carga automática** de 12 repositorios desde MinIO
- **Sección de búsqueda** con campo y botón funcional
- **Estadísticas dinámicas** basadas en datos reales
- **Modal de documentación** con navegación completa

### 🔧 Arquitectura Mejorada
- **3 servicios integrados**: Frontend (8845), Backend (8846), MkDocs (8854)
- **Endpoint optimizado**: `/api/minio/folders` para obtener repositorios
- **Sincronización directa** desde MinIO storage
- **Navegación iframe** con controles (← → 🔄 🏠 🔗)

### 📊 Interfaz Completa
- **12 proyectos** cargados automáticamente
- **Botones funcionales**: Ver Docs, MinIO, Build
- **Stats en tiempo real**: Total, Activos, Builds, Última actualización
- **Diseño responsive** con Bootstrap 5

## 🛠️ Componentes Técnicos

### Frontend (ia-ops-docs - Puerto 8845)
```bash
cd /home/giovanemere/ia-ops/ia-ops-docs
source venv/bin/activate
python3 docs_frontend.py &
```

### Backend (ia-ops-dev-core - Puerto 8846)
```bash
cd /home/giovanemere/ia-ops/ia-ops-dev-core
./start_backend_venv.sh &
```

### MkDocs (ia-ops-mkdocs - Puerto 8854)
```bash
cd /home/giovanemere/ia-ops/ia-ops-mkdocs
source mkdocs-env/bin/activate
python3 mkdocs-server.py &
```

## 📋 Endpoints Principales

| Endpoint | Servicio | Función |
|----------|----------|---------|
| `GET /techdocs` | Frontend | Página principal TechDocs |
| `GET /api/minio/folders` | Backend | Lista repositorios desde MinIO |
| `GET /{project}/` | MkDocs | Documentación específica |

## 🔄 Flujo de Datos

1. Usuario accede a `http://localhost:8845/techdocs`
2. Frontend llama `GET /api/minio/folders`
3. Backend consulta MinIO y retorna 12 folders
4. Frontend transforma y muestra proyectos
5. Click "Ver Docs" abre modal con iframe a MkDocs
6. MkDocs sirve documentación desde MinIO

## 🎯 Funcionalidades Implementadas

- ✅ **Carga automática** de repositorios
- ✅ **Sección de búsqueda** estilizada
- ✅ **Estadísticas dinámicas** calculadas
- ✅ **Modal de documentación** con navegación
- ✅ **Botones MinIO** con enlaces directos
- ✅ **Nombres formateados** (Ia Ops Dev Core)
- ✅ **Status "Activo"** en todos los proyectos

## 🌐 URLs de Acceso

- **Portal Principal**: http://localhost:8845/techdocs
- **Backend API**: http://localhost:8846/docs
- **MkDocs Server**: http://localhost:8854/
- **MinIO Console**: http://localhost:9899/

## 📚 Documentación

- `ARCHITECTURE.md` - Diagrama de arquitectura del sistema
- `SEQUENCE_DIAGRAMS.md` - Diagramas de secuencia de flujos críticos
- `README.md` - Instrucciones de instalación y uso

## 🔧 Correcciones

- ✅ **Error JavaScript** de BACKEND_URL duplicado solucionado
- ✅ **Conexión rechazada** al backend corregida
- ✅ **Repositorios vacíos** solucionado con endpoint MinIO
- ✅ **Estilos CSS** de búsqueda aplicados correctamente
