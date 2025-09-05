# Despliegue con Docker

## 🐳 Containerización

### Dockerfile Backend

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3002
CMD ["npm", "start"]
```

### Dockerfile Frontend

```dockerfile
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
```

### Docker Compose Completo

```yaml
version: '3.8'
services:
  postgresql:
    image: postgres:15
    environment:
      POSTGRES_DB: iaops
      POSTGRES_USER: iaops
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:7-alpine
    
  backend:
    build: ./portal/backend
    depends_on:
      - postgresql
      - redis
    environment:
      - DATABASE_URL=postgresql://iaops:password@postgresql:5432/iaops
      - REDIS_URL=redis://redis:6379
      
  frontend:
    build: ./portal/frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Scripts de Build

```bash
# Build todas las imágenes
docker-compose build

# Deploy completo
docker-compose up -d

# Logs
docker-compose logs -f backend
```
