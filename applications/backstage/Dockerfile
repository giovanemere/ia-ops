# Multi-stage build for Backstage Backend
FROM node:18-bullseye-slim AS packages

# Enable Corepack for Yarn version management
RUN corepack enable

WORKDIR /app
COPY package.json yarn.lock ./
COPY packages packages

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 300000

FROM node:18-bullseye-slim AS build

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Enable Corepack for Yarn version management
RUN corepack enable

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY --from=packages /app/node_modules ./node_modules
COPY packages packages

# Build the backend
RUN yarn build:backend --config ../../app-config.yaml

FROM node:18-bullseye-slim

# Install system dependencies for runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd --gid 1001 backstage && \
    useradd --uid 1001 --gid backstage --shell /bin/bash --create-home backstage

WORKDIR /app

# Copy built application
COPY --from=build --chown=backstage:backstage /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copy configuration files
COPY --chown=backstage:backstage app-config*.yaml ./
COPY --chown=backstage:backstage docs ./docs/

# Create logs directory
RUN mkdir -p /app/logs && chown -R backstage:backstage /app/logs

USER backstage

EXPOSE 7007

# Health check
HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:7007/api/catalog/health || exit 1

CMD ["node", "packages/backend", "--config", "app-config.yaml"]
