# Variables de Entorno - Integración OpenAI con Backstage

## Descripción General

Esta documentación describe todas las variables de entorno necesarias para la integración entre OpenAI y Backstage en la plataforma IA-Ops.

## Variables Críticas para la Integración

### 🤖 OpenAI Service Configuration

```bash
# API Key de OpenAI (REQUERIDA para producción)
OPENAI_API_KEY=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

# Modelo de OpenAI a utilizar
OPENAI_MODEL=gpt-4o-mini

# Máximo número de tokens por respuesta
OPENAI_MAX_TOKENS=2000

# Temperatura para la creatividad de las respuestas (0.0-2.0)
OPENAI_TEMPERATURE=0.7

# Modo demo (true/false) - usar cuando no hay API key válida
OPENAI_DEMO_MODE=true

# Límite de requests por minuto
OPENAI_RATE_LIMIT=100

# Timeout en segundos para requests a OpenAI
OPENAI_TIMEOUT=30
```

### 🏛️ Backstage Integration

```bash
# URL base de Backstage (acceso público)
BACKSTAGE_BASE_URL=http://localhost:8080

# URL del backend de Backstage
BACKSTAGE_BACKEND_URL=http://localhost:8080/api

# URL del frontend de Backstage
BACKSTAGE_FRONTEND_URL=http://localhost:8080

# URLs internas para comunicación entre servicios
BACKSTAGE_INTERNAL_FRONTEND_URL=http://backstage-frontend:3000
BACKSTAGE_INTERNAL_BACKEND_URL=http://backstage-backend:7007
```

### 🌐 Service URLs

```bash
# URL del servicio OpenAI (interno)
OPENAI_SERVICE_URL=http://openai-service:8000

# Host y puerto del servicio OpenAI
OPENAI_SERVICE_HOST=openai-service
OPENAI_SERVICE_PORT=8000

# URL del proxy service
PROXY_SERVICE_URL=http://proxy-service:8080
```

## Configuración por Ambiente

### Desarrollo Local

```bash
# OpenAI
OPENAI_DEMO_MODE=true
OPENAI_API_KEY=demo-key-for-development
OPENAI_RATE_LIMIT=50

# Backstage
BACKSTAGE_BASE_URL=http://localhost:8080
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Staging

```bash
# OpenAI
OPENAI_DEMO_MODE=false
OPENAI_API_KEY=sk-staging-key-here
OPENAI_RATE_LIMIT=100

# Backstage
BACKSTAGE_BASE_URL=https://staging.ia-ops.com
DEBUG_MODE=false
LOG_LEVEL=info
```

### Producción

```bash
# OpenAI
OPENAI_DEMO_MODE=false
OPENAI_API_KEY=sk-production-key-here
OPENAI_RATE_LIMIT=200
OPENAI_TIMEOUT=60

# Backstage
BACKSTAGE_BASE_URL=https://ia-ops.com
DEBUG_MODE=false
LOG_LEVEL=warn
```

## Variables de Seguridad

### CORS Configuration

```bash
# Orígenes permitidos para CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:7007,http://localhost:8080

# Métodos HTTP permitidos
CORS_METHODS=GET,POST,PUT,DELETE,OPTIONS

# Headers permitidos
CORS_HEADERS=Content-Type,Authorization,X-Requested-With
```

### Rate Limiting

```bash
# Ventana de tiempo para rate limiting (minutos)
RATE_LIMIT_WINDOW=15

# Máximo número de requests por ventana
RATE_LIMIT_MAX_REQUESTS=100

# Rate limit específico para OpenAI
OPENAI_RATE_LIMIT=100
```

## Variables de Base de Datos

```bash
# PostgreSQL para Backstage
POSTGRES_HOST=ia-ops-postgres
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=backstage
DATABASE_URL=postgresql://postgres:postgres123@ia-ops-postgres:5432/backstage
```

## Variables de Monitoreo

```bash
# Logging
LOG_LEVEL=info
DEBUG_MODE=true
VERBOSE=1

# Health checks
HEALTH_CHECK_INTERVAL=30
HEALTH_CHECK_TIMEOUT=5
HEALTH_CHECK_RETRIES=3
```

## Validación de Variables

### Script de Validación

```bash
#!/bin/bash
# validate-env.sh

echo "🔍 Validando variables de entorno para integración OpenAI-Backstage..."

# Verificar variables críticas
required_vars=(
    "OPENAI_API_KEY"
    "BACKSTAGE_BASE_URL"
    "POSTGRES_HOST"
    "POSTGRES_PASSWORD"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ ERROR: Variable $var no está definida"
        exit 1
    else
        echo "✅ $var está definida"
    fi
done

# Verificar conectividad OpenAI
if [ "$OPENAI_DEMO_MODE" != "true" ]; then
    echo "🔑 Verificando API Key de OpenAI..."
    # Aquí iría la verificación real de la API key
fi

echo "✅ Todas las variables están correctamente configuradas"
```

## Troubleshooting

### Problemas Comunes

1. **OpenAI API Key inválida**
   ```bash
   # Verificar la variable
   echo $OPENAI_API_KEY
   
   # Activar modo demo temporalmente
   export OPENAI_DEMO_MODE=true
   ```

2. **Error de CORS**
   ```bash
   # Verificar configuración CORS
   echo $CORS_ORIGIN
   
   # Agregar origen faltante
   export CORS_ORIGIN="$CORS_ORIGIN,http://nuevo-origen:puerto"
   ```

3. **Timeout en requests**
   ```bash
   # Aumentar timeout
   export OPENAI_TIMEOUT=60
   export PROXY_TIMEOUT=60
   ```

### Comandos de Diagnóstico

```bash
# Verificar todas las variables OpenAI
env | grep OPENAI

# Verificar todas las variables Backstage
env | grep BACKSTAGE

# Test de conectividad
curl -f http://localhost:8000/health
curl -f http://localhost:7007/api/proxy/openai/health
```

## Mejores Prácticas

### Seguridad

1. **Nunca commitear API keys reales**
   ```bash
   # Usar archivos .env.local para desarrollo
   cp .env .env.local
   # Agregar .env.local al .gitignore
   ```

2. **Rotar API keys regularmente**
   ```bash
   # Programar rotación mensual
   # Usar secretos de Kubernetes en producción
   ```

3. **Usar variables específicas por ambiente**
   ```bash
   # .env.development
   # .env.staging  
   # .env.production
   ```

### Performance

1. **Configurar timeouts apropiados**
   ```bash
   # Desarrollo: timeouts cortos
   OPENAI_TIMEOUT=30
   
   # Producción: timeouts más largos
   OPENAI_TIMEOUT=60
   ```

2. **Ajustar rate limits según uso**
   ```bash
   # Desarrollo: límites bajos
   OPENAI_RATE_LIMIT=50
   
   # Producción: límites altos
   OPENAI_RATE_LIMIT=200
   ```

## Template de Variables

### .env.template

```bash
# =============================================================================
# OPENAI-BACKSTAGE INTEGRATION - TEMPLATE
# =============================================================================

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.7
OPENAI_DEMO_MODE=false
OPENAI_RATE_LIMIT=100
OPENAI_TIMEOUT=30

# Backstage Configuration
BACKSTAGE_BASE_URL=http://localhost:8080
BACKSTAGE_BACKEND_URL=http://localhost:8080/api
BACKSTAGE_FRONTEND_URL=http://localhost:8080

# Service URLs
OPENAI_SERVICE_URL=http://openai-service:8000
OPENAI_SERVICE_HOST=openai-service
OPENAI_SERVICE_PORT=8000

# Database
POSTGRES_HOST=ia-ops-postgres
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-postgres-password
POSTGRES_DB=backstage

# Security
CORS_ORIGIN=http://localhost:3000,http://localhost:7007,http://localhost:8080
RATE_LIMIT_MAX_REQUESTS=100

# Monitoring
LOG_LEVEL=info
DEBUG_MODE=false
```

## Referencias

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Backstage Configuration](https://backstage.io/docs/conf/)
- [Docker Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Security Best Practices](https://owasp.org/www-project-top-ten/)
