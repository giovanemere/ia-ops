# Configuración Inicial

## 🚀 Setup del Entorno

### Prerrequisitos

- Node.js 18+
- Docker y Docker Compose
- PostgreSQL 15+
- Git

### Instalación

```bash
# Clonar repositorio
git clone git@github.com:giovanemere/ia-ops.git
cd ia-ops

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
```

### Variables de Entorno

```bash
# Database
DATABASE_URL="postgresql://user:pass@localhost:5432/iaops"

# Portal Configuration
PORTAL_PORT=3001
API_PORT=3002
DOCS_PORT=5555

# JWT Security
JWT_SECRET="your-super-secret-jwt-key"
ENCRYPTION_KEY="your-encryption-key-32-chars"

# Providers
JIRA_BASE_URL="https://company.atlassian.net"
JIRA_EMAIL="user@company.com"
JIRA_API_TOKEN="your-jira-token"

AZURE_ORGANIZATION="company"
AZURE_PROJECT="ProjectName"
AZURE_PAT="your-azure-pat"

GITHUB_TOKEN="ghp_your-github-token"
GITHUB_OWNER="organization"
GITHUB_REPO="repository"

# Storage
MINIO_ENDPOINT="localhost:9000"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin123"

# Redis (for queues)
REDIS_URL="redis://localhost:6379"
```

### Inicialización de Base de Datos

```bash
# Ejecutar migraciones
npm run db:migrate

# Seed inicial
npm run db:seed
```

### Iniciar Servicios

```bash
# Todos los servicios
./start-services-safe.sh

# Solo el portal
npm run dev

# Solo documentación
./serve-docs.sh
```

### Verificación

```bash
# Verificar servicios
curl http://localhost:3001/health
curl http://localhost:3002/api/health
curl http://localhost:5555
```
