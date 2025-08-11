# Deployment Guide

## Overview

This guide covers the deployment options for the IA-Ops Platform.

## Local Development

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Python 3.11+
- Git

### Quick Start
```bash
# Clone repository
git clone https://github.com/giovanemere/ia-ops.git
cd ia-ops

# Start services
docker-compose up -d

# Access applications
# - Backstage: http://localhost:8080
# - OpenAI Service: http://localhost:8080/openai
# - Monitoring: http://localhost:9090
```

## Production Deployment

### Kubernetes
```bash
# Apply manifests
kubectl apply -f iac/kubernetes/

# With Helm
helm install ia-ops iac/helm/ia-ops
```

### GitOps with ArgoCD
```bash
# Apply ArgoCD application
kubectl apply -f gitops/argocd/application.yaml
```

## Environment Configuration

### Required Variables
```bash
# GitHub
GITHUB_TOKEN=your_github_token
AUTH_GITHUB_CLIENT_ID=your_client_id
AUTH_GITHUB_CLIENT_SECRET=your_client_secret

# OpenAI
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-4o-mini

# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=backstage
```

## Monitoring

The platform includes built-in monitoring with:
- Prometheus for metrics collection
- Grafana for visualization
- Health checks for all services

For detailed deployment instructions, see the main README.md file.
