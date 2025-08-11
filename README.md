# 🚀 IA-Ops Platform

**Plataforma integrada de IA y DevOps con Backstage**

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/tu-organizacion/ia-ops)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

## 📋 Descripción

IA-Ops Platform es una solución completa que integra:
- **🏛️ Backstage**: Portal de desarrolladores
- **🤖 OpenAI Service**: Servicio nativo de IA con conocimiento DevOps
- **📚 Documentación Inteligente**: MkDocs + TechDocs
- **🎯 Templates Multi-Cloud**: Catálogo de despliegues para Azure, AWS, OCI y GCP
- **🏗️ Arquitecturas de Referencia**: Framework de patrones y mejores prácticas
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
├── 🎯 templates/            # Templates multi-cloud (submódulo)
│   ├── aws-infrastructure/  # Templates AWS
│   ├── azure-messaging/     # Templates Azure
│   ├── gcp-storage/        # Templates GCP
│   ├── oci-networking/     # Templates OCI
│   └── kubernetes-deployment/ # Templates K8s
├── 🏗️ framework/            # Arquitecturas de referencia (submódulo)
│   ├── docs/               # Documentación de arquitecturas
│   ├── apps/               # Inventario de aplicaciones DevOps
│   └── arquitectura-diagramas.md # Diagramas de referencia
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

## 🆕 Nuevas Funcionalidades v2.1.0

### 🎯 Templates Multi-Cloud
- **AWS Infrastructure**: Templates para EC2, RDS, S3, Lambda
- **Azure Messaging**: Service Bus, Event Hubs, Logic Apps
- **GCP Storage**: Cloud Storage, BigQuery, Pub/Sub
- **OCI Networking**: VCN, Load Balancers, Security Lists
- **Kubernetes**: Deployments, Services, Ingress

### 🤖 OpenAI Service Mejorado
- **Base de Conocimiento DevOps**: Integración con inventario de aplicaciones
- **Recomendaciones Inteligentes**: Basadas en patrones existentes
- **Selección de Templates**: Asistencia para elegir el template apropiado
- **Troubleshooting Contextual**: Soluciones basadas en experiencias previas

### 🏗️ Framework de Arquitecturas
- **Patrones de Referencia**: Arquitecturas probadas y documentadas
- **Mejores Prácticas**: Guías específicas por proveedor cloud
- **Inventario Automatizado**: Catálogo de aplicaciones DevOps existentes

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

# Inicializar submódulos
git submodule update --init --recursive
```

### 2. Configurar Variables de Entorno
```bash
# Copiar y editar el archivo .env
cp .env.example .env
# Editar .env con tus configuraciones
```

### 3. Configurar Integración OpenAI
```bash
# Instalar dependencias Python
pip install pandas openpyxl

# Ejecutar configuración de integración
python scripts/setup-openai-inventory-integration.py
```

### 4. Iniciar Servicios
```bash
# Iniciar todos los servicios
docker-compose up -d

# Verificar estado
docker-compose ps
```

### 5. Acceder a las Aplicaciones
- **🌐 Proxy Gateway**: http://localhost:8080 (Punto de entrada principal)
- **🏛️ Backstage**: http://localhost:8080 (via proxy)
- **🤖 OpenAI Service**: http://localhost:8080/openai (via proxy)
- **🎯 Templates**: http://localhost:8080/templates (via proxy)
- **🏗️ Framework**: http://localhost:8080/framework (via proxy)
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

# Repositorios Externos
TEMPLATES_REPO=https://github.com/giovanemere/templates_backstage.git
FRAMEWORK_REPO=https://github.com/giovanemere/ia-ops-framework.git
```

Ver `.env` para configuración completa.

## 🎯 Uso de Templates Multi-Cloud

### Selección Inteligente de Templates
```bash
# Consultar templates disponibles via OpenAI
curl -X POST http://localhost:8080/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user", 
        "content": "¿Qué template recomiendas para desplegar una aplicación web en AWS?"
      }
    ]
  }'
```

### Templates Disponibles
- **🔶 AWS**: `aws-infrastructure/template.yaml`
- **🔷 Azure**: `azure-messaging/template.yaml`
- **🟡 GCP**: `gcp-storage/template.yaml`
- **🔴 OCI**: `oci-networking/template.yaml`
- **☸️ Kubernetes**: `kubernetes-deployment/template.yaml`

## 🤖 OpenAI Service con Contexto DevOps

### Funcionalidades Mejoradas
```python
# Ejemplo de consulta contextual
{
  "messages": [
    {
      "role": "system",
      "content": "Eres un asistente DevOps con acceso al inventario de aplicaciones"
    },
    {
      "role": "user",
      "content": "Necesito desplegar una aplicación similar a billpay-front-a"
    }
  ]
}
```

### Capacidades del Asistente
- **🎯 Recomendaciones de Arquitectura**: Basadas en patrones exitosos
- **🔍 Análisis de Aplicaciones**: Comparación con inventario existente
- **🛠️ Selección de Templates**: Matching inteligente de requisitos
- **🚨 Troubleshooting**: Soluciones basadas en casos previos

## 📚 Documentación

### Guías Principales
- [📋 Plan de Implementación](docs/plan-implementacion.md)
- [📊 Seguimiento de Progreso](docs/seguimiento-progreso.md)
- [🚨 Plan de Acción Crítico](docs/plan-accion-critico.md)
- [🎯 Guía de Templates](templates/README.md)
- [🏗️ Framework de Arquitecturas](framework/README.md)

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

# Actualizar submódulos
git submodule update --remote

# Logs
docker-compose logs -f [servicio]

# Restart servicios
docker-compose restart [servicio]

# Build imágenes
docker-compose build

# Limpiar
docker-compose down -v
```

### Testing con Nuevas Funcionalidades
```bash
# Test OpenAI con contexto DevOps
curl -X POST http://localhost:8080/openai/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "¿Cuáles son las mejores prácticas para desplegar en Azure?"
      }
    ]
  }'

# Test catálogo de templates
curl http://localhost:8080/api/catalog/entities?filter=kind=template

# Test framework de arquitecturas
curl http://localhost:8080/api/catalog/entities?filter=kind=system,name=ia-ops-framework
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
- **OpenAI Service**: Requests, latencia, errores, contexto DevOps
- **Templates**: Uso y selección de templates
- **PostgreSQL**: Performance y conexiones
- **Redis**: Memoria y operaciones

### Dashboards Grafana
- **Overview**: Vista general del sistema
- **Backstage**: Métricas específicas de Backstage
- **OpenAI**: Métricas del servicio de IA y recomendaciones
- **Templates**: Uso de templates multi-cloud
- **Infrastructure**: Métricas de infraestructura

## 🔒 Seguridad

### Configuraciones de Seguridad
- **Autenticación**: GitHub OAuth
- **Autorización**: RBAC en Kubernetes
- **Secrets**: Gestión con Kubernetes Secrets
- **Network**: Políticas de red definidas
- **CORS**: Configurado para dominios específicos
- **Submódulos**: Acceso controlado a repositorios externos

### Variables Sensibles
Todas las variables sensibles están en `.env` y deben ser gestionadas de forma segura:
- API Keys (OpenAI, GitHub)
- Passwords de BD
- Tokens de autenticación
- URLs de repositorios privados

## 🤝 Contribución

### Repositorios Relacionados
- **Templates**: [templates_backstage](https://github.com/giovanemere/templates_backstage.git)
- **Framework**: [ia-ops-framework](https://github.com/giovanemere/ia-ops-framework.git)

### Proceso de Contribución
1. Fork del repositorio principal
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Actualizar submódulos si es necesario
4. Commit cambios (`git commit -am 'Añadir nueva funcionalidad'`)
5. Push a la rama (`git push origin feature/nueva-funcionalidad`)
6. Crear Pull Request

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

**🚀 IA-Ops Platform v2.1.0** - Construido con ❤️ por el equipo DevOps
