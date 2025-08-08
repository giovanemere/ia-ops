# Deployment Guide

This guide covers deploying the Sample Service to various environments.

## Deployment Options

The Sample Service supports multiple deployment strategies:

- **Docker Compose** - Local development and testing
- **Kubernetes** - Production container orchestration
- **AWS ECS** - Managed container service
- **Heroku** - Platform as a Service
- **Traditional VMs** - Virtual machine deployment

## Prerequisites

Before deploying, ensure you have:

- [ ] Docker installed (for containerized deployments)
- [ ] Access to a PostgreSQL database
- [ ] Redis instance for caching
- [ ] SSL certificates (for production)
- [ ] Environment variables configured

## Docker Deployment

### Docker Compose (Recommended for Development)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/sampledb
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=sampledb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

Deploy with:

```bash
# Set environment variables
export JWT_SECRET="your-super-secret-jwt-key"

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f app
```

### Single Container Deployment

```bash
# Build the image
docker build -t sample-service:latest .

# Run the container
docker run -d \
  --name sample-service \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgresql://user:password@host:5432/db \
  -e REDIS_URL=redis://host:6379 \
  -e JWT_SECRET=your-secret \
  sample-service:latest
```

## Kubernetes Deployment

### Namespace and ConfigMap

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sample-service

---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-service-config
  namespace: sample-service
data:
  NODE_ENV: "production"
  API_PORT: "3000"
  LOG_LEVEL: "info"
```

### Secrets

```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: sample-service-secrets
  namespace: sample-service
type: Opaque
data:
  DATABASE_URL: <base64-encoded-database-url>
  REDIS_URL: <base64-encoded-redis-url>
  JWT_SECRET: <base64-encoded-jwt-secret>
```

Create secrets:

```bash
kubectl create secret generic sample-service-secrets \
  --from-literal=DATABASE_URL="postgresql://user:password@host:5432/db" \
  --from-literal=REDIS_URL="redis://host:6379" \
  --from-literal=JWT_SECRET="your-secret" \
  -n sample-service
```

### Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-service
  namespace: sample-service
  labels:
    app: sample-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-service
  template:
    metadata:
      labels:
        app: sample-service
    spec:
      containers:
      - name: sample-service
        image: sample-service:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: sample-service-config
        - secretRef:
            name: sample-service-secrets
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Service and Ingress

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-service
  namespace: sample-service
spec:
  selector:
    app: sample-service
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP

---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-service-ingress
  namespace: sample-service
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - api.sample-service.com
    secretName: sample-service-tls
  rules:
  - host: api.sample-service.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-service
            port:
              number: 80
```

Deploy to Kubernetes:

```bash
# Apply all configurations
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Check deployment status
kubectl get pods -n sample-service
kubectl get services -n sample-service
kubectl get ingress -n sample-service

# View logs
kubectl logs -f deployment/sample-service -n sample-service
```

## AWS ECS Deployment

### Task Definition

```json
{
  "family": "sample-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "sample-service",
      "image": "your-account.dkr.ecr.region.amazonaws.com/sample-service:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:sample-service/database-url"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:sample-service/jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/sample-service",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

### ECS Service

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name sample-service-cluster

# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create service
aws ecs create-service \
  --cluster sample-service-cluster \
  --service-name sample-service \
  --task-definition sample-service:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-abcdef],assignPublicIp=ENABLED}"
```

## Environment Configuration

### Production Environment Variables

```bash
# Application
NODE_ENV=production
API_PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:password@host:5432/database
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=20

# Cache
REDIS_URL=redis://host:6379
CACHE_TTL=3600

# Security
JWT_SECRET=your-super-secret-key-min-32-chars
JWT_EXPIRES_IN=1h

# External Services
EXTERNAL_API_URL=https://api.external-service.com
EXTERNAL_API_KEY=your-api-key

# Monitoring
SENTRY_DSN=https://your-sentry-dsn
NEW_RELIC_LICENSE_KEY=your-new-relic-key
```

### Health Checks

Configure health check endpoints:

```javascript
// Health check configuration
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version,
    uptime: process.uptime()
  });
});

app.get('/health/detailed', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    checks: {
      database: await checkDatabase(),
      redis: await checkRedis(),
      external_api: await checkExternalAPI()
    }
  };
  
  const isHealthy = Object.values(health.checks).every(check => check.status === 'ok');
  res.status(isHealthy ? 200 : 503).json(health);
});
```

## Monitoring and Logging

### Application Metrics

```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'sample-service'
      static_configs:
      - targets: ['sample-service:3000']
      metrics_path: '/metrics'
```

### Log Aggregation

```yaml
# fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*sample-service*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
    </source>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name sample-service
    </match>
```

## Rollback Strategy

### Blue-Green Deployment

```bash
# Deploy new version (green)
kubectl set image deployment/sample-service sample-service=sample-service:v2.0.0

# Monitor deployment
kubectl rollout status deployment/sample-service

# Rollback if needed
kubectl rollout undo deployment/sample-service
```

### Canary Deployment

```yaml
# canary-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: sample-service-rollout
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 10m}
      - setWeight: 40
      - pause: {duration: 10m}
      - setWeight: 60
      - pause: {duration: 10m}
      - setWeight: 80
      - pause: {duration: 10m}
  selector:
    matchLabels:
      app: sample-service
  template:
    metadata:
      labels:
        app: sample-service
    spec:
      containers:
      - name: sample-service
        image: sample-service:latest
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   # Check database connectivity
   kubectl exec -it pod/sample-service-xxx -- nc -zv db-host 5432
   ```

2. **Memory Issues**
   ```bash
   # Check memory usage
   kubectl top pods -n sample-service
   
   # Increase memory limits
   kubectl patch deployment sample-service -p '{"spec":{"template":{"spec":{"containers":[{"name":"sample-service","resources":{"limits":{"memory":"1Gi"}}}]}}}}'
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check certificate status
   kubectl describe certificate sample-service-tls
   
   # Renew certificate
   kubectl delete certificate sample-service-tls
   kubectl apply -f ingress.yaml
   ```

### Debugging Commands

```bash
# View application logs
kubectl logs -f deployment/sample-service -n sample-service

# Execute commands in container
kubectl exec -it deployment/sample-service -n sample-service -- /bin/sh

# Port forward for local debugging
kubectl port-forward service/sample-service 3000:80 -n sample-service

# Check resource usage
kubectl top pods -n sample-service
kubectl describe pod sample-service-xxx -n sample-service
```

!!! warning "Production Checklist"
    Before deploying to production:
    
    - [ ] SSL certificates configured
    - [ ] Database backups scheduled
    - [ ] Monitoring and alerting set up
    - [ ] Security scanning completed
    - [ ] Load testing performed
    - [ ] Rollback plan documented
    - [ ] Team trained on deployment process
