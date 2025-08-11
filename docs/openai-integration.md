# 🤖 Integración OpenAI con Backstage

## Descripción General

Esta documentación describe la integración completa entre OpenAI y Backstage en la plataforma IA-Ops. La integración permite utilizar capacidades de IA para análisis de código, generación de documentación, asistencia a desarrolladores y automatización de tareas DevOps.

## 📋 Tabla de Contenidos

- [Configuración Básica](#configuración-básica)
- [Variables de Entorno](#variables-de-entorno)
- [Funcionalidades](#funcionalidades)
- [Endpoints de API](#endpoints-de-api)
- [Ejemplos de Uso](#ejemplos-de-uso)
- [Troubleshooting](#troubleshooting)

## 🔧 Configuración Básica

### Requisitos Previos

1. **API Key de OpenAI**: Obtener en [OpenAI Platform](https://platform.openai.com/api-keys)
2. **Backstage funcionando**: Instancia de Backstage operativa
3. **Base de datos**: PostgreSQL para persistencia
4. **Redis**: Para cache y sesiones

### Configuración Mínima

```bash
# Variables esenciales en .env
OPENAI_API_KEY=sk-proj-tu-api-key-aqui
OPENAI_MODEL=gpt-4o-mini
OPENAI_BACKSTAGE_ENABLED=true
OPENAI_SERVICE_URL=http://openai-service:8000
```

## 📊 Variables de Entorno

### 🔑 Autenticación

| Variable | Descripción | Valor por Defecto | Requerida |
|----------|-------------|-------------------|-----------|
| `OPENAI_API_KEY` | Clave de API de OpenAI | - | ✅ |
| `OPENAI_ORG_ID` | ID de organización OpenAI | - | ❌ |
| `OPENAI_PROJECT_ID` | ID de proyecto OpenAI | - | ❌ |

### 🧠 Modelos de IA

| Variable | Descripción | Valor por Defecto | Opciones |
|----------|-------------|-------------------|----------|
| `OPENAI_MODEL` | Modelo principal | `gpt-4o-mini` | `gpt-4o`, `gpt-4o-mini`, `gpt-4-turbo` |
| `OPENAI_EMBEDDINGS_MODEL` | Modelo para embeddings | `text-embedding-3-small` | `text-embedding-3-large`, `text-embedding-ada-002` |
| `OPENAI_CODE_MODEL` | Modelo para análisis de código | `gpt-4o-mini` | Cualquier modelo de chat |

### ⚙️ Parámetros de Generación

| Variable | Descripción | Valor por Defecto | Rango |
|----------|-------------|-------------------|-------|
| `OPENAI_MAX_TOKENS` | Máximo tokens en respuesta | `2000` | 1-8192 |
| `OPENAI_TEMPERATURE` | Creatividad del modelo | `0.7` | 0.0-2.0 |
| `OPENAI_TOP_P` | Nucleus sampling | `1.0` | 0.1-1.0 |

### 🎯 Funcionalidades

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `OPENAI_FUNCTION_CALLING_ENABLED` | Habilitar function calling | `true` |
| `OPENAI_STREAMING_ENABLED` | Respuestas en streaming | `true` |
| `OPENAI_EMBEDDINGS_ENABLED` | Búsqueda semántica | `true` |
| `OPENAI_CODE_ANALYSIS_ENABLED` | Análisis automático de código | `true` |

## 🚀 Funcionalidades

### 1. Asistente de Código

Análisis automático de repositorios con sugerencias de mejora:

```yaml
# Configuración en app-config.yaml
openai:
  codeAnalysis:
    enabled: true
    triggers:
      - push
      - pull_request
    languages:
      - javascript
      - typescript
      - python
      - java
```

### 2. Generación de Documentación

Documentación automática basada en código:

```yaml
openai:
  documentation:
    enabled: true
    formats:
      - markdown
      - openapi
      - readme
    autoUpdate: true
```

### 3. Revisión de Pull Requests

Revisión automática con IA:

```yaml
openai:
  prReview:
    enabled: true
    checks:
      - security
      - performance
      - bestPractices
      - testing
```

### 4. Base de Conocimiento (RAG)

Búsqueda semántica en documentación:

```yaml
openai:
  knowledgeBase:
    enabled: true
    sources:
      - ./docs
      - ./README.md
      - ./wiki
    updateInterval: 300
```

## 🌐 Endpoints de API

### Chat y Completions

```http
POST /api/openai/chat
Content-Type: application/json

{
  "message": "¿Cómo puedo optimizar este componente React?",
  "context": {
    "component": "UserProfile",
    "repository": "frontend-app"
  }
}
```

### Análisis de Código

```http
POST /api/openai/analyze
Content-Type: application/json

{
  "code": "function example() { ... }",
  "language": "javascript",
  "analysisType": "security"
}
```

### Generación de Documentación

```http
POST /api/openai/docs
Content-Type: application/json

{
  "component": "user-service",
  "type": "api-docs",
  "format": "openapi"
}
```

## 💡 Ejemplos de Uso

### 1. Análisis de Componente Backstage

```javascript
// En un plugin de Backstage
import { openaiApi } from '@backstage/plugin-openai';

const analyzeComponent = async (entity) => {
  const analysis = await openaiApi.analyzeComponent({
    name: entity.metadata.name,
    type: entity.kind,
    code: await fetchComponentCode(entity)
  });
  
  return analysis;
};
```

### 2. Generación de README

```javascript
const generateReadme = async (repository) => {
  const readme = await openaiApi.generateDocs({
    repository: repository.name,
    type: 'readme',
    includeApi: true,
    includeExamples: true
  });
  
  return readme;
};
```

### 3. Revisión de PR

```javascript
const reviewPullRequest = async (prData) => {
  const review = await openaiApi.reviewPR({
    changes: prData.diff,
    description: prData.description,
    checks: ['security', 'performance', 'testing']
  });
  
  return review;
};
```

## 🔍 Monitoreo y Métricas

### Métricas Disponibles

- **Requests por minuto**: Número de llamadas a la API
- **Tokens utilizados**: Consumo de tokens por modelo
- **Latencia promedio**: Tiempo de respuesta
- **Errores**: Rate de errores por endpoint
- **Costos**: Estimación de costos por uso

### Dashboard Grafana

```yaml
# Métricas en Prometheus
openai_requests_total{endpoint="/chat"}
openai_tokens_used{model="gpt-4o-mini"}
openai_response_time_seconds
openai_errors_total{type="rate_limit"}
```

## 🛡️ Seguridad

### Filtrado de Información Sensible

```yaml
openai:
  security:
    piiFiltering: true
    sensitivePatterns:
      - "password"
      - "api_key"
      - "secret"
      - "token"
```

### Rate Limiting

```yaml
openai:
  rateLimiting:
    requestsPerMinute: 60
    tokensPerDay: 100000
    costLimitDaily: 10.00
```

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. Error de API Key

```bash
Error: Invalid API key provided
```

**Solución**: Verificar que `OPENAI_API_KEY` esté configurada correctamente.

#### 2. Rate Limit Exceeded

```bash
Error: Rate limit exceeded
```

**Solución**: Ajustar `OPENAI_RATE_LIMIT` o esperar antes de hacer más requests.

#### 3. Timeout en Requests

```bash
Error: Request timeout
```

**Solución**: Aumentar `OPENAI_TIMEOUT` o verificar conectividad.

### Logs de Debug

```bash
# Habilitar logs detallados
OPENAI_DEBUG_LOGGING=true
LOG_LEVEL=debug

# Ver logs del servicio
docker logs openai-service -f
```

### Health Check

```bash
# Verificar estado del servicio
curl http://localhost:8080/api/openai/health

# Respuesta esperada
{
  "status": "healthy",
  "openai": "connected",
  "model": "gpt-4o-mini",
  "timestamp": "2025-08-06T16:00:00Z"
}
```

## 📚 Referencias

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Backstage Plugin Development](https://backstage.io/docs/plugins/)
- [Docker Compose Configuration](../docker-compose.yml)
- [Kubernetes Manifests](../iac/kubernetes/)

## 🤝 Contribución

Para contribuir a la integración:

1. Fork el repositorio
2. Crear una rama feature
3. Implementar cambios
4. Agregar tests
5. Crear Pull Request

## 📞 Soporte

- **Issues**: [GitHub Issues](https://github.com/giovanemere/ia-ops/issues)
- **Documentación**: [Wiki del Proyecto](https://github.com/giovanemere/ia-ops/wiki)
- **Chat**: Slack #ia-ops
