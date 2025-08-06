# 🚀 IA-Ops Platform

**Plataforma integrada de IA y DevOps con Backstage**

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/tu-organizacion/ia-ops)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

## 📋 Descripción

IA-Ops Platform es una solución completa que integra:
- **🏛️ Backstage**: Portal de desarrolladores
- **🤖 OpenAI Service**: Servicio nativo de IA
- **📚 Documentación Inteligente**: MkDocs + TechDocs
- **☸️ Infraestructura como Código**: Terraform + Kubernetes
- **🔄 CI/CD Pipeline**: GitOps con ArgoCD

## 🏗️ Arquitectura

```
                    ┌─────────────────┐
                    │  Proxy Service  │
                    │   (Gateway)     │
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Backstage Front │    │ Backstage Back  │    │  OpenAI Service │
│   (React)       │    │   (Node.js)     │    │   (FastAPI)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Redis       │    │   Monitoring    │
│   (Database)    │    │    (Cache)      │    │ (Prometheus)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Estructura del Proyecto

```
ia-ops/
├── 📱 applications/          # Aplicaciones principales
│   ├── backstage/           # Portal Backstage
│   ├── openai-service/      # Servicio de IA
│   ├── proxy-service/       # Gateway y proxy
│   ├── monitoring/          # Herramientas de monitoreo
│   └── docs/               # Documentación MkDocs
├── 🏗️ iac/                  # Infraestructura como Código
│   ├── terraform/          # Configuraciones Terraform
│   ├── kubernetes/         # Manifiestos K8s
│   └── helm/              # Charts de Helm
├── 🔄 gitops/               # GitOps y CI/CD
│   ├── argocd/            # Configuraciones ArgoCD
│   └── environments/       # Configuraciones por ambiente
├── ⚙️ config/               # Archivos de configuración
│   ├── backstage/         # Configuración Backstage
│   ├── openai/            # Configuración OpenAI Service
│   ├── proxy/             # Configuración Proxy Service
│   ├── database/          # Configuración BD
│   └── monitoring/        # Configuración monitoreo
├── 📚 docs/                 # Documentación del proyecto
├── 🐳 docker-compose.yml    # Desarrollo local
└── 🔐 .env                  # Variables de entorno
```

## 🚀 Inicio Rápido

### Prerrequisitos
- Docker & Docker Compose
- Node.js 18+
- Python 3.11+
- Git

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-organizacion/ia-ops.git
cd ia-ops
```

### 2. Configurar Variables de Entorno
```bash
# Copiar y editar el archivo .env
cp .env.example .env
# Editar .env con tus configuraciones
```

### 3. Iniciar Servicios
```bash
# Iniciar todos los servicios
docker-compose up -d

# Verificar estado
docker-compose ps
```

### 4. Acceder a las Aplicaciones
- **🌐 Proxy Gateway**: http://localhost:8080 (Punto de entrada principal)
- **🏛️ Backstage**: http://localhost:8080 (via proxy)
- **🤖 OpenAI Service**: http://localhost:8080/openai (via proxy)
- **📊 Prometheus**: http://localhost:9090
- **📈 Grafana**: http://localhost:3001
- **📚 MkDocs**: http://localhost:8080

## 🔧 Configuración

### Variables de Entorno Principales
```bash
# GitHub
GITHUB_TOKEN=tu_github_token
AUTH_GITHUB_CLIENT_ID=tu_client_id
AUTH_GITHUB_CLIENT_SECRET=tu_client_secret

# OpenAI
OPENAI_API_KEY=tu_openai_api_key
OPENAI_MODEL=gpt-4o-mini

# Base de Datos
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=backstage
```

Ver `.env` para configuración completa.

## 📚 Documentación

### Guías Principales
- [📋 Plan de Implementación](docs/plan-implementacion.md)
- [📊 Seguimiento de Progreso](docs/seguimiento-progreso.md)
- [🚨 Plan de Acción Crítico](docs/plan-accion-critico.md)

### Documentación por Componente
- [🏛️ Backstage](applications/backstage/README.md)
- [🤖 OpenAI Service](applications/openai-service/README.md)
- [🏗️ Terraform](iac/terraform/README.md)
- [☸️ Kubernetes](iac/kubernetes/README.md)

## 🛠️ Desarrollo

### Comandos Útiles
```bash
# Desarrollo local
docker-compose up -d

# Logs
docker-compose logs -f [servicio]

# Restart servicios
docker-compose restart [servicio]

# Build imágenes
docker-compose build

# Limpiar
docker-compose down -v
```

### Testing
```bash
# Test via Proxy (Recomendado)
curl http://localhost:8080/health
curl http://localhost:8080/api/catalog/entities
curl -X POST http://localhost:8080/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'

# Test Directo (Desarrollo)
curl http://localhost:8000/health
curl http://localhost:7007/api/catalog/entities
```

## 🚀 Despliegue

### Desarrollo Local
```bash
docker-compose up -d
```

### Kubernetes
```bash
# Aplicar manifiestos
kubectl apply -f iac/kubernetes/

# Con Helm
helm install ia-ops iac/helm/ia-ops
```

### GitOps con ArgoCD
```bash
# Aplicar aplicación ArgoCD
kubectl apply -f gitops/argocd/application.yaml
```

## 📊 Monitoreo

### Métricas Disponibles
- **Backstage**: Métricas de aplicación y uso
- **OpenAI Service**: Requests, latencia, errores
- **PostgreSQL**: Performance y conexiones
- **Redis**: Memoria y operaciones

### Dashboards Grafana
- **Overview**: Vista general del sistema
- **Backstage**: Métricas específicas de Backstage
- **OpenAI**: Métricas del servicio de IA
- **Infrastructure**: Métricas de infraestructura

## 🔒 Seguridad

### Configuraciones de Seguridad
- **Autenticación**: GitHub OAuth
- **Autorización**: RBAC en Kubernetes
- **Secrets**: Gestión con Kubernetes Secrets
- **Network**: Políticas de red definidas
- **CORS**: Configurado para dominios específicos

### Variables Sensibles
Todas las variables sensibles están en `.env` y deben ser gestionadas de forma segura:
- API Keys
- Passwords de BD
- Tokens de GitHub
- Secrets de autenticación

## 🤝 Contribución

### Proceso de Contribución
1. Fork del repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

### Estándares de Código
- **Python**: PEP 8, Black formatter
- **TypeScript**: ESLint, Prettier
- **YAML**: yamllint
- **Commits**: Conventional Commits

## 📞 Soporte

### Contactos
- **Tech Lead**: tech-lead@tu-organizacion.com
- **DevOps Team**: devops@tu-organizacion.com
- **Issues**: [GitHub Issues](https://github.com/tu-organizacion/ia-ops/issues)

### Recursos
- [📖 Wiki](https://github.com/tu-organizacion/ia-ops/wiki)
- [💬 Discussions](https://github.com/tu-organizacion/ia-ops/discussions)
- [🐛 Bug Reports](https://github.com/tu-organizacion/ia-ops/issues/new?template=bug_report.md)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 🏆 Reconocimientos

- [Backstage](https://backstage.io/) - Portal de desarrolladores
- [FastAPI](https://fastapi.tiangolo.com/) - Framework web moderno
- [OpenAI](https://openai.com/) - API de inteligencia artificial
- [Kubernetes](https://kubernetes.io/) - Orquestación de contenedores

---

**🚀 IA-Ops Platform v2.0.0** - Construido con ❤️ por el equipo DevOps
