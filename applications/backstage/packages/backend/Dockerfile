# =============================================================================
# BACKSTAGE BACKEND NATIVO - DOCKERFILE
# =============================================================================
# Descripción: Backend nativo de Backstage para IA-Ops Platform
# Base: Node.js con Backstage nativo
# Puerto: 7007

# Stage 1: Build stage
FROM node:18-bullseye-slim as build

# Instalar dependencias del sistema para build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        build-essential \
        curl \
        git \
        postgresql-client \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python para TechDocs
RUN pip3 install mkdocs-techdocs-core==1.*

# Crear usuario no-root
RUN useradd --create-home --shell /bin/bash --uid 1001 backstage

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración del workspace
COPY --chown=backstage:backstage package.json yarn.lock ./
COPY --chown=backstage:backstage .yarnrc.yml ./
COPY --chown=backstage:backstage backstage.json ./

# Copiar .yarn directory
COPY --chown=backstage:backstage .yarn ./.yarn

# Copiar packages
COPY --chown=backstage:backstage packages ./packages

# Copiar archivos de configuración
COPY --chown=backstage:backstage app-config*.yaml ./

# Crear directorio node_modules con permisos correctos antes de cambiar de usuario
RUN mkdir -p /app/node_modules && chown -R backstage:backstage /app

# Cambiar a usuario backstage
USER backstage

# Instalar dependencias
RUN yarn install --immutable

# Construir el backend usando el comando del workspace
RUN yarn workspace backend build

# Stage 2: Runtime stage
FROM node:18-bullseye-slim as runtime

# Instalar dependencias del sistema para runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        postgresql-client \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python para TechDocs
RUN pip3 install mkdocs-techdocs-core==1.*

# Crear usuario no-root
RUN useradd --create-home --shell /bin/bash --uid 1001 backstage

# Directorio de trabajo
WORKDIR /app

# Copiar archivos construidos desde build stage
COPY --from=build --chown=backstage:backstage /app/yarn.lock ./
COPY --from=build --chown=backstage:backstage /app/package.json ./
COPY --from=build --chown=backstage:backstage /app/packages/backend/dist/bundle.tar.gz ./
COPY --from=build --chown=backstage:backstage /app/app-config*.yaml ./

# Extraer el bundle
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Crear directorio para TechDocs
RUN mkdir -p /tmp/techdocs && chown backstage:backstage /tmp/techdocs

# Cambiar a usuario backstage
USER backstage

# Exponer puerto
EXPOSE 7007

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV LOG_LEVEL=info

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7007/health || exit 1

# Comando por defecto
CMD ["node", "packages/backend", "--config", "app-config.yaml"]
