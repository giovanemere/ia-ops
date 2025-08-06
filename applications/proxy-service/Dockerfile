# =============================================================================
# PROXY SERVICE - DOCKERFILE
# =============================================================================
# Descripción: Gateway y proxy para IA-Ops Platform
# Base: Node.js con Express
# Puerto: 8080

FROM node:18-alpine

# Metadata
LABEL maintainer="DevOps Team"
LABEL version="1.0.0"
LABEL description="IA-Ops Proxy Service - Gateway y proxy"

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S proxy -u 1001

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar código fuente
COPY --chown=proxy:nodejs . .

# Crear directorios necesarios
RUN mkdir -p logs config && \
    chown -R proxy:nodejs /app

# Cambiar a usuario no-root
USER proxy

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Comando por defecto
CMD ["node", "src/server.js"]
