# Despliegue en Producción

## 🚀 Configuración de Producción

### Prerrequisitos

- Kubernetes cluster o Docker Swarm
- PostgreSQL 15+ (managed)
- Redis cluster
- Load balancer (nginx/traefik)
- SSL certificates

### Variables de Entorno

```bash
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL="postgresql://user:pass@prod-db:5432/iaops"
REDIS_URL="redis://prod-redis:6379"
JWT_SECRET="production-secret-256-bits"
```

### Docker Compose Producción

```yaml
version: '3.8'
services:
  portal-backend:
    image: iaops/portal-backend:latest
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
      
  portal-frontend:
    image: iaops/portal-frontend:latest
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
```

### Monitoreo

- Prometheus + Grafana
- ELK Stack para logs
- Health checks automáticos
- Alertas por Slack/Teams
