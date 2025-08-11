# 🐳 Docker Hub Setup - IA-Ops Backstage

## 📋 Resumen

Esta guía te ayudará a configurar el push automático de la imagen de Backstage a Docker Hub usando GitHub Actions.

## 🚀 Configuración Rápida

### 1. **Configurar Secrets de GitHub**

Ejecuta el script de configuración automática:

```bash
./scripts/setup-docker-hub-secrets.sh
```

O configura manualmente:

1. Ve a tu repositorio en GitHub
2. Settings > Secrets and variables > Actions
3. Añade estos secrets:
   - `DOCKER_HUB_USERNAME`: Tu username de Docker Hub
   - `DOCKER_HUB_TOKEN`: Tu access token de Docker Hub (NO password)

### 2. **Crear Access Token en Docker Hub**

1. Ve a [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Click en "New Access Token"
3. Nombre: `github-actions-ia-ops`
4. Permisos: `Read, Write, Delete`
5. Copia el token generado

### 3. **Activar el Workflow**

El workflow se activa automáticamente cuando:
- Haces push a `trunk`
- Modificas archivos en `applications/backstage/`
- Ejecutas manualmente desde GitHub Actions

## 🏗️ Workflows Disponibles

### GitHub Actions Workflow
```yaml
# .github/workflows/docker-hub-push.yml
name: 🐳 Push to Docker Hub
on:
  push:
    branches: [trunk]
    paths: ['applications/backstage/**']
```

### Push Manual Local
```bash
# Desde applications/backstage/
./push-to-docker-hub.sh
```

## 🏷️ Tags Generados

La imagen se publica con múltiples tags:

- `giovanemere/ia-ops-backstage:latest` - Última versión de trunk
- `giovanemere/ia-ops-backstage:stable` - Versión estable (solo trunk)
- `giovanemere/ia-ops-backstage:trunk` - Branch trunk
- `giovanemere/ia-ops-backstage:2024.08.11-abc1234` - Fecha + SHA
- `giovanemere/ia-ops-backstage:abc1234` - Solo SHA

## 🧪 Uso de la Imagen

### Pull de la Imagen
```bash
docker pull giovanemere/ia-ops-backstage:latest
```

### Ejecutar Localmente
```bash
# Básico
docker run -p 7007:7007 giovanemere/ia-ops-backstage:latest

# Con variables de entorno
docker run -p 7007:7007 \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  giovanemere/ia-ops-backstage:latest

# Con volumen para configuración
docker run -p 7007:7007 \
  -v $(pwd)/app-config.local.yaml:/app/app-config.local.yaml \
  giovanemere/ia-ops-backstage:latest
```

### Docker Compose
```yaml
version: '3.8'
services:
  backstage:
    image: giovanemere/ia-ops-backstage:latest
    ports:
      - "7007:7007"
    environment:
      - POSTGRES_HOST=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres123
    depends_on:
      - postgres
  
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres123
      - POSTGRES_DB=backstage
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## 🔧 Scripts Disponibles

### Configuración
```bash
# Configurar secrets de Docker Hub
./scripts/setup-docker-hub-secrets.sh

# Verificar imagen en Docker Hub
./scripts/verify-docker-hub.sh
```

### Build y Push
```bash
# Push manual a Docker Hub
./applications/backstage/push-to-docker-hub.sh

# Diagnóstico de build
./applications/backstage/diagnose-github-build.sh

# Simulación local
./applications/backstage/simulate-github-actions-build.sh
```

## 📊 Información de la Imagen

### Características
- **Base**: Node.js 20 on Debian Bullseye Slim
- **Arquitecturas**: linux/amd64, linux/arm64
- **Usuario**: backstage (non-root)
- **Puerto**: 7007
- **Health Check**: Incluido
- **Tamaño**: ~500MB (optimizado)

### Labels OCI
```
org.opencontainers.image.title=IA-Ops Backstage
org.opencontainers.image.description=Backstage Developer Portal for IA-Ops Platform
org.opencontainers.image.vendor=IA-Ops Team
org.opencontainers.image.source=https://github.com/giovanemere/ia-ops
```

## 🔍 Verificación

### Verificar que la Imagen Existe
```bash
# Usando Docker
docker manifest inspect giovanemere/ia-ops-backstage:latest

# Usando script
./scripts/verify-docker-hub.sh
```

### Inspeccionar la Imagen
```bash
# Información general
docker inspect giovanemere/ia-ops-backstage:latest

# Solo labels
docker inspect giovanemere/ia-ops-backstage:latest | jq '.[0].Config.Labels'

# Historia de layers
docker history giovanemere/ia-ops-backstage:latest
```

## 🔗 Enlaces Útiles

- **Docker Hub Repository**: https://hub.docker.com/r/giovanemere/ia-ops-backstage
- **GitHub Actions**: https://github.com/giovanemere/ia-ops/actions/workflows/docker-hub-push.yml
- **GitHub Repository**: https://github.com/giovanemere/ia-ops
- **Docker Hub Security**: https://hub.docker.com/settings/security

## 🚨 Troubleshooting

### Error: "unauthorized: authentication required"
```bash
# Verificar autenticación
docker login

# O usar token específico
echo $DOCKER_HUB_TOKEN | docker login --username $DOCKER_HUB_USERNAME --password-stdin
```

### Error: "denied: requested access to the resource is denied"
- Verifica que el access token tenga permisos `Read, Write, Delete`
- Confirma que el username sea correcto
- Asegúrate de usar access token, no password

### Build Falla en GitHub Actions
```bash
# Verificar secrets
gh secret list

# Ver logs del workflow
gh run list --workflow=docker-hub-push.yml
gh run view [RUN_ID] --log
```

### Imagen No Aparece en Docker Hub
- Verifica que el workflow haya completado exitosamente
- Confirma que los secrets estén configurados
- Revisa los logs de GitHub Actions
- Verifica que el repositorio en Docker Hub exista

## 📈 Monitoreo

### GitHub Actions
```bash
# Ver workflows
gh workflow list

# Ver runs del workflow de Docker Hub
gh run list --workflow=docker-hub-push.yml

# Ver logs de un run específico
gh run view [RUN_ID] --log
```

### Docker Hub
- Ve a https://hub.docker.com/r/giovanemere/ia-ops-backstage
- Revisa la pestaña "Tags" para ver todas las versiones
- Verifica la fecha de "Last pushed"

## ✅ Checklist de Configuración

- [ ] Access token creado en Docker Hub
- [ ] Secrets configurados en GitHub (`DOCKER_HUB_USERNAME`, `DOCKER_HUB_TOKEN`)
- [ ] Workflow file creado (`.github/workflows/docker-hub-push.yml`)
- [ ] Push realizado para activar el workflow
- [ ] Workflow ejecutado exitosamente
- [ ] Imagen visible en Docker Hub
- [ ] Pull de la imagen funciona localmente

## 🎉 ¡Listo!

Una vez configurado, cada push a `trunk` que modifique archivos de Backstage automáticamente:

1. 🏗️ Construirá la imagen Docker
2. 🏷️ Generará tags apropiados
3. 📤 Subirá la imagen a Docker Hub
4. ✅ Estará disponible para uso

**¡Tu imagen de Backstage estará disponible en Docker Hub!** 🐳
