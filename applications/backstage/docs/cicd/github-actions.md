# GitHub Actions Integration

## Descripción

La integración con GitHub Actions permite visualizar y gestionar pipelines de CI/CD directamente desde Backstage.

## Características

- **Visualización de Workflows**: Ver todos los workflows de GitHub Actions
- **Estado en Tiempo Real**: Estado actual de builds y deployments
- **Historial de Ejecuciones**: Historial completo de ejecuciones
- **Logs Integrados**: Acceso directo a logs de ejecución
- **Triggers Manuales**: Ejecutar workflows manualmente desde Backstage

## Configuración Automática

Los workflows se detectan automáticamente en los siguientes repositorios:

- `giovanemere/ia-ops`
- `giovanemere/poc-billpay-back`
- `giovanemere/poc-billpay-front-a`
- `giovanemere/poc-billpay-front-b`
- `giovanemere/poc-billpay-front-feature-flags`
- `giovanemere/poc-icbs`

## Workflows Típicos

### CI Pipeline
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
```

### Deploy Pipeline
```yaml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: ./deploy.sh
```

## Métricas

- **Success Rate**: Porcentaje de builds exitosos
- **Build Time**: Tiempo promedio de build
- **Deployment Frequency**: Frecuencia de deployments
- **Lead Time**: Tiempo desde commit hasta producción

## Troubleshooting

### Workflows no aparecen
1. Verificar token de GitHub en configuración
2. Confirmar permisos del token
3. Revisar logs del backend

### Builds fallan
1. Revisar logs en GitHub Actions
2. Verificar configuración de secrets
3. Confirmar dependencias
