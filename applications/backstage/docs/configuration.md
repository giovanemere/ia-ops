# Configuration Guide

This guide covers the configuration options for the IA-OPS Developer Portal.

## Application Configuration

The main configuration is in `app-config.yaml`:

### Basic Settings

```yaml
app:
  title: IA-OPS Developer Portal
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
```

### Database Configuration

```yaml
backend:
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
```

### GitHub Integration

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      organization: ${GITHUB_ORG}
```

### Authentication

```yaml
auth:
  providers:
    guest: {}
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
```

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_HOST` | Database host | `localhost` |
| `POSTGRES_PORT` | Database port | `5432` |
| `POSTGRES_USER` | Database user | `backstage_user` |
| `POSTGRES_PASSWORD` | Database password | `secure_password` |
| `POSTGRES_DB` | Database name | `backstage_db` |
| `GITHUB_TOKEN` | GitHub access token | `ghp_...` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AUTH_GITHUB_CLIENT_ID` | GitHub OAuth client ID | - |
| `AUTH_GITHUB_CLIENT_SECRET` | GitHub OAuth secret | - |
| `OPENAI_API_KEY` | OpenAI API key | - |
| `BACKEND_SECRET` | Backend secret key | Generated |

## Plugin Configuration

### TechDocs

```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
```

### Catalog

```yaml
catalog:
  rules:
    - allow: [Component, System, API, Resource, Location]
  locations:
    - type: file
      target: ../../examples/entities.yaml
```

### Search

```yaml
search:
  pg:
    highlightOptions:
      useHighlight: true
      maxWord: 35
      minWord: 15
```

## Security Configuration

### CORS

```yaml
backend:
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
```

### CSP

```yaml
backend:
  csp:
    connect-src: ["'self'", 'http:', 'https:']
```

## Monitoring

### Metrics

Enable metrics collection:

```yaml
backend:
  metrics:
    enabled: true
```

### Logging

Configure log levels:

```yaml
backend:
  log:
    level: info
```

## Customization

### Theme

Customize the appearance in `packages/app/src/App.tsx`:

```typescript
const app = createApp({
  themes: [{
    id: 'ia-ops-theme',
    title: 'IA-OPS Theme',
    variant: 'light',
    Provider: ({ children }) => (
      <UnifiedThemeProvider theme={iaOpsTheme}>
        {children}
      </UnifiedThemeProvider>
    ),
  }],
});
```

### Sidebar

Modify the sidebar in `packages/app/src/components/Root/Root.tsx`:

```typescript
<SidebarItem icon={HomeIcon} to="catalog" text="Home" />
<SidebarItem icon={ExtensionIcon} to="api-docs" text="APIs" />
<SidebarItem icon={LibraryBooks} to="docs" text="Docs" />
```
