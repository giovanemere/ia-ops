# Guía Rápida - Integración OpenAI con Backstage

## 🚀 Inicio Rápido

### 1. Validar Configuración

```bash
# Validar todas las variables de entorno
./scripts/validate-openai-backstage-env.sh

# Si hay errores, revisar el archivo .env
nano .env
```

### 2. Iniciar Servicios

```bash
# Opción 1: Iniciar todo el stack
docker-compose up -d

# Opción 2: Solo servicios esenciales
docker-compose up -d postgres openai-service backstage-backend

# Opción 3: Usar script personalizado
./start-with-backstage.sh
```

### 3. Verificar Integración

```bash
# Ejecutar tests completos
./scripts/test-openai-backstage-integration.sh

# Test rápido manual
curl http://localhost:8000/health
curl http://localhost:7007/api/proxy/openai/health
```

## 📋 Checklist de Configuración

### Variables Críticas en `.env`

- [ ] `OPENAI_API_KEY` - Tu API key de OpenAI
- [ ] `OPENAI_MODEL=gpt-4o-mini` - Modelo a usar
- [ ] `BACKSTAGE_BASE_URL=http://localhost:8080` - URL base de Backstage
- [ ] `OPENAI_SERVICE_URL=http://openai-service:8000` - URL del servicio OpenAI
- [ ] `POSTGRES_PASSWORD` - Password de PostgreSQL

### Servicios Requeridos

- [ ] PostgreSQL (`ia-ops-postgres`)
- [ ] OpenAI Service (`ia-ops-openai-service`)
- [ ] Backstage Backend (`ia-ops-backstage-backend`)

## 🔗 URLs de Acceso

| Servicio | URL | Descripción |
|----------|-----|-------------|
| OpenAI Service | http://localhost:8000 | Servicio directo |
| OpenAI Docs | http://localhost:8000/docs | Documentación API |
| Backstage | http://localhost:8080 | Portal principal |
| Backstage API | http://localhost:7007 | API backend |
| OpenAI via Proxy | http://localhost:7007/api/proxy/openai | OpenAI via Backstage |

## 🧪 Pruebas Rápidas

### Test Directo OpenAI Service

```bash
# Health check
curl http://localhost:8000/health

# Listar modelos
curl http://localhost:8000/models

# Chat completion
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "model": "gpt-4o-mini",
    "max_tokens": 100
  }'
```

### Test via Backstage Proxy

```bash
# Health check via proxy
curl http://localhost:7007/api/proxy/openai/health

# Chat completion via proxy
curl -X POST http://localhost:7007/api/proxy/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello via Backstage!"}],
    "model": "gpt-4o-mini",
    "max_tokens": 100
  }'
```

## 🔧 Troubleshooting Rápido

### Problema: Servicio OpenAI no responde

```bash
# Verificar contenedor
docker ps | grep openai-service

# Ver logs
docker logs ia-ops-openai-service

# Reiniciar servicio
docker-compose restart openai-service
```

### Problema: Error de CORS

```bash
# Verificar configuración CORS en .env
echo $CORS_ORIGIN

# Agregar origen faltante
export CORS_ORIGIN="$CORS_ORIGIN,http://nuevo-origen:puerto"
```

### Problema: API Key inválida

```bash
# Activar modo demo temporalmente
export OPENAI_DEMO_MODE=true
docker-compose restart openai-service

# Verificar API key
echo $OPENAI_API_KEY | head -c 20
```

### Problema: Backstage no puede conectar a OpenAI

```bash
# Verificar proxy configuration
curl http://localhost:7007/api/proxy/openai/health

# Verificar variables de red
echo $OPENAI_SERVICE_URL
echo $BACKSTAGE_BASE_URL
```

## 📝 Uso en Código

### Frontend React (Backstage Plugin)

```typescript
import { useApi, configApiRef } from '@backstage/core-plugin-api';

const useOpenAI = () => {
  const config = useApi(configApiRef);
  const backendUrl = config.getString('backend.baseUrl');

  const chatCompletion = async (message: string) => {
    const response = await fetch(`${backendUrl}/proxy/openai/chat/completions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        messages: [{ role: 'user', content: message }],
        model: 'gpt-4o-mini',
        max_tokens: 1000
      })
    });
    return response.json();
  };

  return { chatCompletion };
};
```

### Backend Node.js (Backstage Plugin)

```typescript
import { Config } from '@backstage/config';

export class OpenAIService {
  constructor(private config: Config) {}

  async chat(messages: any[]) {
    const openaiUrl = this.config.getString('openai.serviceUrl');
    
    const response = await fetch(`${openaiUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.config.getString('openai.apiKey')}`
      },
      body: JSON.stringify({ messages, model: 'gpt-4o-mini' })
    });

    return response.json();
  }
}
```

## 🎯 Casos de Uso Comunes

### 1. Asistente de Documentación

```bash
# Generar documentación para un componente
curl -X POST http://localhost:7007/api/proxy/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Generate documentation for a React component that displays user profiles"
    }],
    "model": "gpt-4o-mini",
    "max_tokens": 500
  }'
```

### 2. Análisis de Código

```bash
# Revisar código para mejores prácticas
curl -X POST http://localhost:7007/api/proxy/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Review this code for security issues: function login(user, pass) { return user === admin && pass === 123; }"
    }],
    "model": "gpt-4o-mini",
    "max_tokens": 300
  }'
```

### 3. Generación de Tests

```bash
# Generar tests unitarios
curl -X POST http://localhost:7007/api/proxy/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Generate Jest unit tests for a function that calculates the sum of an array"
    }],
    "model": "gpt-4o-mini",
    "max_tokens": 400
  }'
```

## 📊 Monitoreo

### Logs Importantes

```bash
# Logs del servicio OpenAI
docker logs -f ia-ops-openai-service

# Logs de Backstage
docker logs -f ia-ops-backstage-backend

# Logs de PostgreSQL
docker logs -f ia-ops-postgres
```

### Métricas Básicas

```bash
# Verificar uso de recursos
docker stats ia-ops-openai-service ia-ops-backstage-backend

# Verificar conectividad de red
docker network inspect ia-ops_ia-ops-network
```

## 🔄 Comandos de Mantenimiento

```bash
# Reiniciar solo la integración OpenAI-Backstage
docker-compose restart openai-service backstage-backend

# Limpiar y reiniciar
docker-compose down
docker-compose up -d postgres openai-service backstage-backend

# Backup de configuración
cp .env .env.backup.$(date +%Y%m%d)

# Actualizar servicios
docker-compose pull
docker-compose up -d --force-recreate
```

## 📚 Referencias Rápidas

- [Documentación completa](./openai-backstage-integration.md)
- [Variables de entorno](./openai-backstage-env-vars.md)
- [OpenAI API Docs](https://platform.openai.com/docs)
- [Backstage Docs](https://backstage.io/docs)

## 🆘 Soporte

Si encuentras problemas:

1. Ejecuta `./scripts/validate-openai-backstage-env.sh`
2. Ejecuta `./scripts/test-openai-backstage-integration.sh`
3. Revisa los logs con `docker logs <container-name>`
4. Verifica la conectividad de red entre servicios
