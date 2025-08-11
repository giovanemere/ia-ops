# Getting Started

Esta guía te ayudará a configurar y ejecutar IA-Ops Platform en tu entorno local.

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

### Software Requerido

| Software | Versión Mínima | Instalación |
|----------|----------------|-------------|
| **Docker** | 20.10+ | [Instalar Docker](https://docs.docker.com/get-docker/) |
| **Docker Compose** | 2.0+ | [Instalar Docker Compose](https://docs.docker.com/compose/install/) |
| **Node.js** | 18.0+ | [Instalar Node.js](https://nodejs.org/) |
| **Python** | 3.8+ | [Instalar Python](https://python.org/) |
| **Git** | 2.30+ | [Instalar Git](https://git-scm.com/) |

### Verificar Instalaciones

```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar Node.js
node --version
npm --version

# Verificar Python
python3 --version
pip3 --version

# Verificar Git
git --version
```

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/giovanemere/ia-ops.git
cd ia-ops
```

### 2. Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar configuraciones (usar tu editor preferido)
nano .env
# o
vim .env
# o
code .env
```

### Variables Esenciales

Configura al menos estas variables en tu archivo `.env`:

```bash
# GitHub Configuration (Requerido)
GITHUB_TOKEN=tu-github-token
GITHUB_USER=tu-usuario-github
GITHUB_ORG=tu-organizacion

# GitHub OAuth (Requerido para autenticación)
AUTH_GITHUB_CLIENT_ID=tu-client-id
AUTH_GITHUB_CLIENT_SECRET=tu-client-secret

# OpenAI Configuration (Requerido)
OPENAI_API_KEY=tu-openai-api-key

# Backstage Secret (Generado automáticamente)
BACKEND_SECRET=f6a09f6db3f1bc6241910cbe6402b979bff01ed41b4f4607fac1a6a7569114e1
```

!!! tip "Obtener Tokens"
    - **GitHub Token**: Ve a [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
    - **GitHub OAuth App**: Ve a [GitHub Settings > Developer settings > OAuth Apps](https://github.com/settings/applications/new)
    - **OpenAI API Key**: Ve a [OpenAI Platform > API Keys](https://platform.openai.com/api-keys)

### 3. Configurar GitHub OAuth App

1. Ve a [GitHub OAuth Apps](https://github.com/settings/applications/new)
2. Completa los campos:
   - **Application name**: `IA-Ops Platform`
   - **Homepage URL**: `http://localhost:3000`
   - **Authorization callback URL**: `http://localhost:3000/api/auth/github/handler/frame`
3. Copia el `Client ID` y `Client Secret` a tu archivo `.env`

## 🐳 Despliegue con Docker

### Opción 1: Despliegue Completo

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Verificar estado
docker-compose ps
```

### Opción 2: Despliegue Paso a Paso

```bash
# 1. Iniciar base de datos
docker-compose up -d postgres redis

# 2. Esperar que la base de datos esté lista
./scripts/check-postgres-ready.sh

# 3. Iniciar servicios backend
docker-compose up -d backstage-backend openai-service

# 4. Iniciar frontend
docker-compose up -d backstage-frontend

# 5. Iniciar proxy
docker-compose up -d proxy-service
```

### Opción 3: Desarrollo Local

```bash
# Usar script de desarrollo
./start-with-backstage.sh

# O usar script simplificado
./start-simple.sh
```

## 🔧 Scripts de Configuración

### Script Principal de Configuración

```bash
# Configurar MkDocs con Backstage
./scripts/setup-mkdocs-backstage.sh

# Configurar proveedores de nube
./scripts/setup-cloud-providers.sh

# Configurar repositorios
./scripts/setup-repositories.sh
```

### Scripts de Validación

```bash
# Validar configuración de OpenAI
./scripts/validate-openai-config.sh

# Validar integración con GitHub
./scripts/validate-github-integration.sh

# Validar configuración de nube
./scripts/validate-cloud-config.sh
```

## 🌐 Acceder a los Servicios

Una vez que todos los servicios estén ejecutándose:

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Backstage Portal** | http://localhost:3000 | GitHub OAuth |
| **Documentación** | http://localhost:8000 | - |
| **Grafana** | http://localhost:3001 | admin/grafana123 |
| **Prometheus** | http://localhost:9090 | - |
| **OpenAI Service** | http://localhost:8080/docs | - |

### Primera Configuración en Backstage

1. **Acceder a Backstage**: http://localhost:3000
2. **Autenticarse**: Usar GitHub OAuth
3. **Explorar el Catálogo**: Ver componentes y servicios
4. **Crear tu primer componente**: Usar las plantillas disponibles

## 🔍 Verificar la Instalación

### 1. Verificar Servicios

```bash
# Verificar que todos los contenedores estén ejecutándose
docker-compose ps

# Verificar logs de servicios
docker-compose logs backstage-backend
docker-compose logs openai-service
```

### 2. Verificar Conectividad

```bash
# Verificar Backstage Backend
curl http://localhost:7007/api/catalog/entities

# Verificar OpenAI Service
curl http://localhost:8080/health

# Verificar Proxy Service
curl http://localhost:8080/api/health
```

### 3. Verificar Base de Datos

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U postgres -d backstage

# Verificar tablas
\dt

# Salir
\q
```

## 🛠️ Configuración Avanzada

### Configurar Proveedores de Nube

```bash
# Ejecutar script de configuración
./scripts/configure-cloud-secrets.sh

# Seguir las instrucciones interactivas para:
# - AWS credentials
# - Azure service principal
# - GCP service account
# - OCI configuration
```

### Configurar Monitoreo

```bash
# Verificar Prometheus targets
curl http://localhost:9090/api/v1/targets

# Acceder a Grafana
# URL: http://localhost:3001
# Usuario: admin
# Contraseña: grafana123
```

### Configurar TechDocs

```bash
# Instalar dependencias de documentación
pip3 install -r requirements-docs.txt

# Servir documentación localmente
mkdocs serve

# Construir documentación
mkdocs build
```

## 🐛 Solución de Problemas Comunes

### Error: "Port already in use"

```bash
# Verificar puertos en uso
netstat -tulpn | grep :3000

# Detener servicios conflictivos
sudo systemctl stop apache2  # o nginx
```

### Error: "Database connection failed"

```bash
# Verificar estado de PostgreSQL
docker-compose logs postgres

# Reiniciar base de datos
docker-compose restart postgres

# Verificar conectividad
./scripts/test-postgres-connection.sh
```

### Error: "GitHub authentication failed"

1. Verificar que `GITHUB_TOKEN` tenga los permisos correctos
2. Verificar que `AUTH_GITHUB_CLIENT_ID` y `AUTH_GITHUB_CLIENT_SECRET` sean correctos
3. Verificar que la URL de callback esté configurada correctamente

### Error: "OpenAI API key invalid"

```bash
# Verificar API key
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models

# Verificar configuración
./scripts/validate-openai-config.sh
```

## 📚 Próximos Pasos

Una vez que tengas la plataforma ejecutándose:

1. **Explorar el Catálogo**: Navega por los componentes y servicios disponibles
2. **Crear tu primer servicio**: Usa las plantillas de scaffolding
3. **Configurar documentación**: Agrega documentación a tus componentes
4. **Configurar monitoreo**: Configura alertas y dashboards
5. **Integrar con CI/CD**: Configura pipelines de despliegue

### Recursos Adicionales

- [Architecture Guide](architecture.md) - Arquitectura detallada
- [API Documentation](api/index.md) - Documentación de APIs
- [Deployment Guide](guides/deployment.md) - Despliegue en producción
- [Troubleshooting](guides/troubleshooting.md) - Solución de problemas

## 🤝 Obtener Ayuda

Si encuentras problemas:

1. **Revisa los logs**: `docker-compose logs [servicio]`
2. **Consulta la documentación**: [Troubleshooting Guide](guides/troubleshooting.md)
3. **Busca en Issues**: [GitHub Issues](https://github.com/giovanemere/ia-ops/issues)
4. **Crea un nuevo Issue**: Si no encuentras solución

¡Felicidades! 🎉 Ya tienes IA-Ops Platform ejecutándose en tu entorno local.
