# Configuración de Entorno

## 🔧 Variables de Entorno

### Configuración por Entorno

#### Development
```bash
NODE_ENV=development
LOG_LEVEL=debug
ENABLE_CORS=true
ENABLE_SWAGGER=true
```

#### Production
```bash
NODE_ENV=production
LOG_LEVEL=info
ENABLE_CORS=false
ENABLE_SWAGGER=false
```

### Configuración de Seguridad

```bash
# JWT Configuration
JWT_SECRET="your-256-bit-secret"
JWT_EXPIRES_IN="24h"
JWT_REFRESH_EXPIRES_IN="7d"

# Encryption
ENCRYPTION_ALGORITHM="aes-256-gcm"
ENCRYPTION_KEY="your-32-character-encryption-key"

# CORS
CORS_ORIGIN="http://localhost:3000,http://localhost:3001"
CORS_CREDENTIALS=true
```

### Configuración de Base de Datos

```bash
# PostgreSQL
DATABASE_URL="postgresql://username:password@host:port/database"
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10
DATABASE_SSL=false

# Redis
REDIS_URL="redis://localhost:6379"
REDIS_PASSWORD=""
REDIS_DB=0
```

### Configuración de Providers

```bash
# Jira
JIRA_BASE_URL="https://company.atlassian.net"
JIRA_EMAIL="user@company.com"
JIRA_API_TOKEN="ATATT3xFfGF0..."
JIRA_PROJECT_KEY="PROJ"

# Azure DevOps
AZURE_ORGANIZATION="company"
AZURE_PROJECT="ProjectName"
AZURE_PAT="your-personal-access-token"

# GitHub
GITHUB_TOKEN="ghp_your-token"
GITHUB_OWNER="organization"
GITHUB_REPO="repository"
GITHUB_PROJECT_NUMBER=1
```

### Configuración de Almacenamiento

```bash
# MinIO
MINIO_ENDPOINT="localhost:9000"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin123"
MINIO_BUCKET="iaops-storage"
MINIO_USE_SSL=false

# File Upload
MAX_FILE_SIZE=10485760  # 10MB
ALLOWED_FILE_TYPES="pdf,doc,docx,txt,md"
```

### Configuración de Notificaciones

```bash
# Email
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="noreply@company.com"
SMTP_PASS="your-app-password"
SMTP_FROM="IA-Ops Portal <noreply@company.com>"

# Slack
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
SLACK_CHANNEL="#ia-ops-notifications"

# Teams
TEAMS_WEBHOOK_URL="https://company.webhook.office.com/..."
```
