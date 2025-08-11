# 🔗 Guía de Links en Backstage

## 📋 Problema Resuelto

**Antes**: "No links defined for this entity"  
**Después**: Links organizados y funcionales ✅

## 🎯 Cómo se Ven los Links en Backstage

### Vista en la Interfaz
```
┌─────────────────────────────────────────────────────────────┐
│ 📱 IA-Ops Platform                                          │
├─────────────────────────────────────────────────────────────┤
│ 🔗 Links                                                    │
│                                                             │
│ 🐙 Main Repository          📊 Prometheus Metrics          │
│ 🌐 Backstage Portal         📈 Grafana Dashboards          │
│ 💬 OpenAI Service           📚 Documentation Wiki          │
│ 🐛 Issue Tracker                                           │
└─────────────────────────────────────────────────────────────┘
```

## 📝 Estructura YAML de Links

### Sintaxis Básica
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: mi-componente
spec:
  # ... otras propiedades
  links:  # 👈 Esta es la sección clave
    - url: https://github.com/mi-org/mi-repo
      title: Repository
      icon: github
    - url: https://docs.mi-app.com
      title: Documentation
      icon: docs
```

### Iconos Disponibles
| Icono | Uso Recomendado | Ejemplo |
|-------|----------------|---------|
| `github` | Repositorios GitHub | Source code, PRs, Issues |
| `gitlab` | Repositorios GitLab | Source code, CI/CD |
| `web` | Sitios web/Apps | Aplicaciones, dashboards |
| `docs` | Documentación | APIs, wikis, guías |
| `dashboard` | Métricas/Monitoreo | Prometheus, métricas |
| `grafana` | Dashboards Grafana | Visualizaciones |
| `chat` | Comunicación | Slack, Teams, chat |
| `email` | Email | Contactos del equipo |
| `cloud` | Servicios cloud | AWS, Azure, GCP |
| `bug` | Issues/Bugs | Trackers de problemas |
| `alert` | Alertas | PagerDuty, alerting |
| `catalog` | Catálogos | Inventarios, listas |
| `diagram` | Diagramas | Arquitecturas, flujos |
| `help` | Ayuda/Soporte | Documentación de ayuda |

## 🏗️ Links Implementados en IA-Ops

### 1. Sistema Principal (catalog-info.yaml)
```yaml
links:
  - url: https://github.com/giovanemere/ia-ops
    title: Main Repository
    icon: github
  - url: http://localhost:8080
    title: Backstage Portal
    icon: web
  - url: http://localhost:8080/openai
    title: OpenAI Service
    icon: chat
  - url: http://localhost:9090
    title: Prometheus Metrics
    icon: dashboard
  - url: http://localhost:3001
    title: Grafana Dashboards
    icon: grafana
  - url: https://github.com/giovanemere/ia-ops/wiki
    title: Documentation Wiki
    icon: docs
  - url: https://github.com/giovanemere/ia-ops/issues
    title: Issue Tracker
    icon: bug
```

### 2. Templates Multi-Cloud
```yaml
# Para cada template
links:
  - url: https://github.com/giovanemere/templates_backstage/tree/trunk/aws-infrastructure
    title: Template Source
    icon: github
  - url: https://aws.amazon.com/getting-started/
    title: AWS Getting Started
    icon: cloud
  - url: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    title: Terraform AWS Provider
    icon: docs
```

### 3. Framework de Arquitecturas
```yaml
links:
  - url: https://github.com/giovanemere/ia-ops-framework
    title: Framework Repository
    icon: github
  - url: http://localhost:8080/framework
    title: Architecture Documentation
    icon: docs
  - url: https://github.com/giovanemere/ia-ops-framework/blob/trunk/arquitectura-diagramas.md
    title: Architecture Diagrams
    icon: diagram
```

## 🎨 Mejores Prácticas

### ✅ Hacer
- **Títulos descriptivos**: "API Documentation" mejor que "Docs"
- **Iconos apropiados**: Usar el icono que mejor represente el recurso
- **URLs funcionales**: Verificar que todos los links funcionen
- **Organización lógica**: Agrupar links relacionados
- **Contexto relevante**: Solo links útiles para el componente

### ❌ Evitar
- Títulos genéricos: "Link 1", "URL"
- Iconos incorrectos: `github` para documentación
- Links rotos o temporales
- Demasiados links (máximo 8-10 por entidad)
- URLs internas sin contexto

## 🔧 Tipos de Links por Categoría

### 🏗️ Desarrollo
```yaml
links:
  - url: https://github.com/org/repo
    title: Source Code
    icon: github
  - url: https://github.com/org/repo/pulls
    title: Pull Requests
    icon: github
  - url: https://jenkins.company.com/job/service
    title: CI/CD Pipeline
    icon: web
```

### 📚 Documentación
```yaml
links:
  - url: https://docs.service.com
    title: API Documentation
    icon: docs
  - url: https://wiki.company.com/service
    title: Architecture Guide
    icon: docs
  - url: https://confluence.company.com/service
    title: Runbooks
    icon: docs
```

### 📊 Monitoreo
```yaml
links:
  - url: https://grafana.company.com/d/service
    title: Service Dashboard
    icon: grafana
  - url: https://prometheus.company.com/targets
    title: Metrics & Alerts
    icon: dashboard
  - url: https://logs.company.com/service
    title: Application Logs
    icon: dashboard
```

### 🌐 Aplicaciones
```yaml
links:
  - url: https://service.company.com
    title: Production Environment
    icon: web
  - url: https://staging.service.company.com
    title: Staging Environment
    icon: web
  - url: https://service.company.com/health
    title: Health Check
    icon: web
```

## 🚀 Resultado Final

### Antes
```
Links
No links defined for this entity.
```

### Después
```
Links
🐙 Main Repository        📊 Prometheus Metrics
🌐 Backstage Portal      📈 Grafana Dashboards  
💬 OpenAI Service        📚 Documentation Wiki
🐛 Issue Tracker
```

## 🎯 Próximos Pasos

1. **Verificar links**: Ejecutar `./scripts/validate-links.sh`
2. **Iniciar servicios**: `docker-compose up -d`
3. **Acceder a Backstage**: http://localhost:8080
4. **Navegar entidades**: Verificar que los links aparezcan
5. **Probar funcionalidad**: Hacer clic en cada link

## 📊 Beneficios

- ✅ **Navegación mejorada**: Acceso rápido a recursos
- ✅ **Contexto completo**: Toda la información en un lugar
- ✅ **Experiencia de usuario**: Interfaz más rica y útil
- ✅ **Productividad**: Menos tiempo buscando recursos
- ✅ **Estandarización**: Consistencia en toda la plataforma

---

**🎉 ¡Links implementados exitosamente en IA-Ops Platform!**
