# Deployment Guide

## Prerrequisitos

- Docker
- Kubernetes (opcional)
- Variables de entorno configuradas

## Despliegue Local

```bash
# Clonar repositorio
git clone https://github.com/giovanemere/poc-billpay-front-b.git
cd poc-billpay-front-b

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev
```

## Despliegue en Kubernetes

```bash
# Aplicar manifiestos
kubectl apply -f k8s/
```

## Variables de Entorno

| Variable | Descripción | Requerida |
|----------|-------------|-----------|
| PORT | Puerto del servicio | No |
| NODE_ENV | Entorno de ejecución | Sí |

## Monitoreo

El servicio expone métricas en `/metrics` para Prometheus.
