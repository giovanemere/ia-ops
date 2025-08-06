# 🌐 Proxy Service

## Descripción
Gateway y proxy service para IA-Ops Platform que facilita la comunicación entre el frontend, backend de Backstage y servicios externos.

## Arquitectura
```
┌─────────────────┐
│  Proxy Service  │ :8080
│   (Gateway)     │
└─────────┬───────┘
          │
    ┌─────┼─────┐
    │     │     │
    ▼     ▼     ▼
┌─────┐ ┌───┐ ┌─────┐
│Front│ │API│ │OpenAI│
│:3000│ │:7007│ │:8000│
└─────┘ └───┘ └─────┘
```

## Funcionalidades

### 🔀 **Routing**
- **`/`** → Backstage Frontend (React)
- **`/api/*`** → Backstage Backend (Node.js)
- **`/openai/*`** → OpenAI Service (FastAPI)

### 🛡️ **Seguridad**
- **CORS**: Configurado para dominios específicos
- **Helmet**: Headers de seguridad
- **Rate Limiting**: 200 requests/15min por IP
- **Request Validation**: Validación de headers y body

### 📊 **Monitoreo**
- **Health Check**: `/health` endpoint
- **Logging**: Winston con múltiples niveles
- **Metrics**: Request/response logging
- **Error Handling**: Manejo centralizado de errores

## Configuración

### Variables de Entorno
```bash
# Proxy Configuration
PROXY_SERVICE_PORT=8080
PROXY_SERVICE_HOST=0.0.0.0
PROXY_RATE_LIMIT=200
PROXY_TIMEOUT=30

# Target Services
PROXY_BACKSTAGE_FRONTEND_URL=http://backstage-frontend:3000
PROXY_BACKSTAGE_BACKEND_URL=http://backstage-backend:7007
PROXY_OPENAI_SERVICE_URL=http://openai-service:8000

# Features
PROXY_CORS_ENABLED=true
PROXY_LOGGING_ENABLED=true
LOG_LEVEL=info
```

## Estructura
```
proxy-service/
├── src/
│   ├── server.js         # Servidor principal
│   ├── middleware/       # Middleware personalizado
│   ├── routes/          # Rutas específicas
│   └── utils/           # Utilidades
├── logs/                # Archivos de log
├── tests/               # Tests unitarios
├── package.json         # Dependencias Node.js
├── Dockerfile          # Imagen Docker
└── README.md           # Esta documentación
```

## Comandos

### Desarrollo
```bash
# Instalar dependencias
npm install

# Desarrollo con hot reload
npm run dev

# Producción
npm start

# Tests
npm test

# Linting
npm run lint
```

### Docker
```bash
# Build imagen
docker build -t ia-ops-proxy-service .

# Run container
docker run -p 8080:8080 \
  -e PROXY_BACKSTAGE_FRONTEND_URL=http://backstage-frontend:3000 \
  -e PROXY_BACKSTAGE_BACKEND_URL=http://backstage-backend:7007 \
  -e PROXY_OPENAI_SERVICE_URL=http://openai-service:8000 \
  ia-ops-proxy-service
```

## Endpoints

### Health Check
```bash
GET /health
```
**Response:**
```json
{
  "uptime": 123.45,
  "message": "Proxy Service is healthy",
  "timestamp": "2025-08-06T13:00:00.000Z",
  "services": {
    "backstage_frontend": "http://backstage-frontend:3000",
    "backstage_backend": "http://backstage-backend:7007",
    "openai_service": "http://openai-service:8000"
  }
}
```

### Proxy Routes
```bash
# Backstage Frontend
GET /                    → backstage-frontend:3000/
GET /catalog             → backstage-frontend:3000/catalog
GET /docs                → backstage-frontend:3000/docs

# Backstage Backend API
GET /api/catalog/entities → backstage-backend:7007/catalog/entities
POST /api/auth/github     → backstage-backend:7007/auth/github

# OpenAI Service
POST /openai/chat/completions → openai-service:8000/chat/completions
POST /openai/completions      → openai-service:8000/completions
GET /openai/health           → openai-service:8000/health
```

## Características Técnicas

### Performance
- **Compression**: Gzip habilitado
- **Keep-Alive**: Conexiones persistentes
- **Timeout**: 30s configurable
- **Memory**: ~50MB footprint

### Logging
```bash
# Logs disponibles
logs/proxy-error.log      # Solo errores
logs/proxy-combined.log   # Todos los logs
```

### Rate Limiting
- **Window**: 15 minutos
- **Limit**: 200 requests por IP
- **Headers**: `X-RateLimit-*` incluidos
- **Response**: 429 Too Many Requests

### CORS Policy
```javascript
{
  origin: [
    'http://localhost:3000',
    'http://localhost:7007', 
    'http://localhost:8080'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
}
```

## Testing

### Health Check
```bash
curl http://localhost:8080/health
```

### Proxy Functionality
```bash
# Test frontend proxy
curl http://localhost:8080/

# Test API proxy
curl http://localhost:8080/api/catalog/entities

# Test OpenAI proxy
curl -X POST http://localhost:8080/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

## Troubleshooting

### Problemas Comunes

1. **Service Unavailable (502)**
   - Verificar que los servicios target estén running
   - Comprobar URLs de configuración
   - Revisar logs: `docker logs ia-ops-proxy-service`

2. **CORS Errors**
   - Verificar configuración de origins
   - Comprobar headers en requests
   - Revisar configuración de credentials

3. **Rate Limit Exceeded (429)**
   - Esperar 15 minutos o reiniciar servicio
   - Ajustar `PROXY_RATE_LIMIT` si es necesario
   - Verificar IP del cliente

### Debug Commands
```bash
# Ver logs en tiempo real
docker logs -f ia-ops-proxy-service

# Verificar configuración
curl http://localhost:8080/health

# Test conectividad
docker exec ia-ops-proxy-service curl http://backstage-frontend:3000
docker exec ia-ops-proxy-service curl http://backstage-backend:7007
docker exec ia-ops-proxy-service curl http://openai-service:8000
```

## Dependencias

### Principales
- **express**: Framework web
- **http-proxy-middleware**: Proxy functionality
- **cors**: CORS handling
- **helmet**: Security headers
- **express-rate-limit**: Rate limiting
- **winston**: Logging
- **compression**: Response compression

### Desarrollo
- **nodemon**: Hot reload
- **jest**: Testing framework
- **eslint**: Code linting
- **supertest**: HTTP testing

## Métricas y Monitoreo

### Métricas Disponibles
- Request count por ruta
- Response time promedio
- Error rate por servicio
- Rate limit hits
- Memory usage

### Integración con Prometheus
```javascript
// Métricas expuestas en /metrics (futuro)
proxy_requests_total
proxy_request_duration_seconds
proxy_errors_total
proxy_rate_limit_hits_total
```
