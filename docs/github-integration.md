# Integración GitHub con Backstage - IA-Ops Platform

## Descripción General

Esta documentación describe la integración completa entre GitHub y Backstage en la plataforma IA-Ops, incluyendo autenticación, catálogo de servicios, y automatización de workflows.

## Arquitectura de la Integración

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub.com    │    │   Backstage     │    │  GitHub OAuth   │
│   Repositories  │◄──►│   Platform      │◄──►│   App           │
│   Issues/PRs    │    │   Catalog       │    │   Authentication│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub API    │    │   PostgreSQL    │    │   User Sessions │
│   Webhooks      │    │   Database      │    │   JWT Tokens    │
│   Actions       │    │   Entities      │    │   Permissions   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Variables de Configuración

### 🔐 Autenticación GitHub

```bash
# Personal Access Token (PAT) para acceso a la API
GITHUB_TOKEN=ghp_your_personal_access_token_here

# Organización principal de GitHub
GITHUB_ORG=tu-organizacion

# Repositorio principal del proyecto
GITHUB_REPO=ia-ops

# URL base de GitHub (para GitHub Enterprise usar URL personalizada)
GITHUB_BASE_URL=https://github.com

# API URL de GitHub (para GitHub Enterprise usar URL personalizada)
GITHUB_API_URL=https://api.github.com

# URL para raw content (para GitHub Enterprise usar URL personalizada)
GITHUB_RAW_URL=https://raw.githubusercontent.com
```

### 🔑 OAuth App para Backstage

```bash
# Client ID de la GitHub OAuth App
AUTH_GITHUB_CLIENT_ID=Ov23liCF48J5cW1bjMiC

# Client Secret de la GitHub OAuth App
AUTH_GITHUB_CLIENT_SECRET=09f84b4714065574f4e2b42d74d9e67a69df2172

# Callback URL para OAuth (debe coincidir con la configuración en GitHub)
AUTH_GITHUB_CALLBACK_URL=http://localhost:8080/api/auth/github/handler/frame

# Scopes requeridos para la OAuth App
AUTH_GITHUB_SCOPES=read:user,read:org,repo
```

### 📚 Catálogo de Backstage

```bash
# Ubicaciones del catálogo en GitHub
CATALOG_LOCATIONS=https://github.com/tu-organizacion/ia-ops/blob/main/catalog-info.yaml

# Repositorios adicionales para el catálogo
CATALOG_GITHUB_REPOS=tu-organizacion/ia-ops,tu-organizacion/backend-services,tu-organizacion/frontend-apps

# Branch por defecto para el catálogo
CATALOG_GITHUB_BRANCH=main

# Patrón de archivos de catálogo
CATALOG_FILE_PATTERN=catalog-info.yaml

# Auto-discovery de repositorios
GITHUB_AUTODISCOVERY_ENABLED=true
GITHUB_AUTODISCOVERY_ORG=tu-organizacion
GITHUB_AUTODISCOVERY_TOPICS=backstage,service,component
```

### 🔄 Integración con GitHub Actions

```bash
# Webhook secret para GitHub Actions
GITHUB_WEBHOOK_SECRET=your-webhook-secret-here

# URL del webhook para recibir eventos de GitHub
GITHUB_WEBHOOK_URL=http://localhost:8080/api/github/webhook

# Eventos de GitHub a procesar
GITHUB_WEBHOOK_EVENTS=push,pull_request,issues,release

# Token para GitHub Actions (puede ser el mismo que GITHUB_TOKEN)
GITHUB_ACTIONS_TOKEN=ghp_your_actions_token_here
```

### 🏷️ Configuración de Repositorios

```bash
# Repositorios a incluir en el catálogo (separados por coma)
GITHUB_CATALOG_REPOS=ia-ops,backend-api,frontend-web,mobile-app

# Topics/etiquetas para filtrar repositorios
GITHUB_CATALOG_TOPICS=backstage,microservice,frontend,backend

# Visibilidad de repositorios (public, private, all)
GITHUB_REPO_VISIBILITY=all

# Incluir repositorios archivados
GITHUB_INCLUDE_ARCHIVED=false

# Incluir forks
GITHUB_INCLUDE_FORKS=false
```

## Configuración por Ambiente

### Desarrollo Local

```bash
# GitHub Configuration - Development
GITHUB_TOKEN=ghp_dev_token_here
GITHUB_ORG=tu-organizacion-dev
GITHUB_BASE_URL=https://github.com
AUTH_GITHUB_CLIENT_ID=dev_client_id
AUTH_GITHUB_CLIENT_SECRET=dev_client_secret
AUTH_GITHUB_CALLBACK_URL=http://localhost:8080/api/auth/github/handler/frame
GITHUB_AUTODISCOVERY_ENABLED=true
```

### Staging

```bash
# GitHub Configuration - Staging
GITHUB_TOKEN=ghp_staging_token_here
GITHUB_ORG=tu-organizacion
GITHUB_BASE_URL=https://github.com
AUTH_GITHUB_CLIENT_ID=staging_client_id
AUTH_GITHUB_CLIENT_SECRET=staging_client_secret
AUTH_GITHUB_CALLBACK_URL=https://staging.ia-ops.com/api/auth/github/handler/frame
GITHUB_AUTODISCOVERY_ENABLED=true
```

### Producción

```bash
# GitHub Configuration - Production
GITHUB_TOKEN=ghp_production_token_here
GITHUB_ORG=tu-organizacion
GITHUB_BASE_URL=https://github.com
AUTH_GITHUB_CLIENT_ID=production_client_id
AUTH_GITHUB_CLIENT_SECRET=production_client_secret
AUTH_GITHUB_CALLBACK_URL=https://ia-ops.com/api/auth/github/handler/frame
GITHUB_AUTODISCOVERY_ENABLED=false  # Más control en producción
```

## Permisos Requeridos

### Personal Access Token (PAT)

El token de GitHub debe tener los siguientes scopes:

```
✅ repo                    # Acceso completo a repositorios
✅ read:org                # Leer información de la organización
✅ read:user               # Leer información del usuario
✅ user:email              # Acceso al email del usuario
✅ read:packages           # Leer packages (opcional)
✅ write:packages          # Escribir packages (opcional)
✅ admin:repo_hook         # Administrar webhooks (opcional)
```

### OAuth App Permissions

La GitHub OAuth App debe configurarse con:

```
✅ Authorization callback URL: http://localhost:8080/api/auth/github/handler/frame
✅ Request user authorization (OAuth) during installation: Yes
✅ Webhook URL: http://localhost:8080/api/github/webhook
✅ Repository permissions:
   - Contents: Read
   - Issues: Read
   - Metadata: Read
   - Pull requests: Read
✅ Organization permissions:
   - Members: Read
```

## Configuración de Backstage

### app-config.yaml

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      apiBaseUrl: ${GITHUB_API_URL}
      rawBaseUrl: ${GITHUB_RAW_URL}

auth:
  environment: ${NODE_ENV}
  providers:
    github:
      ${NODE_ENV}:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        callbackUrl: ${AUTH_GITHUB_CALLBACK_URL}
        scopes: ${AUTH_GITHUB_SCOPES}

catalog:
  import:
    entityFilename: ${CATALOG_FILE_PATTERN}
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location, User, Group]
  locations:
    - type: file
      target: ../../catalog-info.yaml
    - type: url
      target: ${CATALOG_LOCATIONS}
  providers:
    github:
      providerId:
        organization: ${GITHUB_ORG}
        catalogPath: ${CATALOG_FILE_PATTERN}
        filters:
          branch: ${CATALOG_GITHUB_BRANCH}
          repository: ${GITHUB_CATALOG_REPOS}
          topic: ${GITHUB_CATALOG_TOPICS}
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
```

## Casos de Uso

### 1. Catálogo Automático de Servicios

```yaml
# catalog-info.yaml en cada repositorio
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backend-api
  description: API principal del backend
  annotations:
    github.com/project-slug: tu-organizacion/backend-api
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: backend-team
  system: core-platform
```

### 2. Autenticación con GitHub

```typescript
// En un plugin de Backstage
import { githubAuthApiRef } from '@backstage/core-plugin-api';

const useGitHubAuth = () => {
  const githubAuthApi = useApi(githubAuthApiRef);
  
  const signIn = async () => {
    const authResponse = await githubAuthApi.getAccessToken(['repo', 'read:org']);
    return authResponse;
  };
  
  return { signIn };
};
```

### 3. Integración con GitHub Actions

```yaml
# .github/workflows/backstage-catalog.yml
name: Update Backstage Catalog
on:
  push:
    paths:
      - 'catalog-info.yaml'
      - '.backstage/**'

jobs:
  update-catalog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Trigger Backstage Refresh
        run: |
          curl -X POST "${{ secrets.BACKSTAGE_WEBHOOK_URL }}/refresh" \
            -H "Authorization: Bearer ${{ secrets.BACKSTAGE_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{"repository": "${{ github.repository }}"}'
```

## Monitoreo y Observabilidad

### Health Checks

```bash
# Verificar conectividad con GitHub API
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Verificar acceso a la organización
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$GITHUB_ORG

# Verificar repositorios accesibles
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$GITHUB_ORG/repos
```

### Métricas

```bash
# Rate limit status
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit

# Webhook deliveries
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/hooks
```

## Seguridad

### Mejores Prácticas

1. **Rotación de Tokens**
   ```bash
   # Programar rotación mensual de PAT
   # Usar GitHub Apps en lugar de PAT cuando sea posible
   ```

2. **Principio de Menor Privilegio**
   ```bash
   # Solo otorgar permisos necesarios
   # Usar tokens específicos por función
   ```

3. **Monitoreo de Acceso**
   ```bash
   # Auditar uso de tokens
   # Alertas por uso anómalo
   ```

### Configuración de Webhooks

```json
{
  "name": "web",
  "active": true,
  "events": [
    "push",
    "pull_request",
    "issues",
    "release"
  ],
  "config": {
    "url": "http://localhost:8080/api/github/webhook",
    "content_type": "json",
    "secret": "your-webhook-secret",
    "insecure_ssl": "0"
  }
}
```

## Troubleshooting

### Problemas Comunes

1. **Token inválido o expirado**
   ```bash
   # Verificar token
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   
   # Regenerar token en GitHub Settings > Developer settings > Personal access tokens
   ```

2. **Permisos insuficientes**
   ```bash
   # Verificar scopes del token
   curl -I -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   # Revisar header X-OAuth-Scopes
   ```

3. **Rate limiting**
   ```bash
   # Verificar límites
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
   
   # Implementar retry con backoff
   ```

4. **OAuth callback error**
   ```bash
   # Verificar callback URL en GitHub OAuth App
   # Debe coincidir exactamente con AUTH_GITHUB_CALLBACK_URL
   ```

### Comandos de Diagnóstico

```bash
# Test completo de conectividad GitHub
./scripts/test-github-integration.sh

# Verificar configuración OAuth
curl -X POST https://github.com/login/oauth/access_token \
  -H "Accept: application/json" \
  -d "client_id=$AUTH_GITHUB_CLIENT_ID&client_secret=$AUTH_GITHUB_CLIENT_SECRET&code=test"

# Verificar webhook
curl -X POST http://localhost:8080/api/github/webhook \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: ping" \
  -d '{"zen": "test"}'
```

## Referencias

- [GitHub API Documentation](https://docs.github.com/en/rest)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Backstage GitHub Integration](https://backstage.io/docs/integrations/github/locations)
- [GitHub Webhooks](https://docs.github.com/en/developers/webhooks-and-events/webhooks)

## Changelog

- **v2.0.0**: Integración completa con Backstage
- **v1.9.0**: OAuth App configuration
- **v1.8.0**: Webhook integration
- **v1.7.0**: Auto-discovery de repositorios
