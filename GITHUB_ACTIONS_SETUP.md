# 🚀 GitHub Actions Workflows Setup Guide

Este documento proporciona una guía completa para configurar los workflows de GitHub Actions para todos los repositorios del proyecto.

## 📋 Repositorios Configurados

### 1. **poc-billpay-back** - Spring Boot Backend
- **Tecnología**: Java 17 + Spring Boot + Gradle
- **Workflow**: `ci-cd.yml`
- **Características**:
  - ✅ Tests unitarios con JaCoCo
  - ✅ Análisis de calidad con SonarQube
  - ✅ Build multi-arquitectura (AMD64/ARM64)
  - ✅ Escaneo de seguridad con Trivy
  - ✅ Despliegue automático por ambiente

### 2. **poc-billpay-front-a** - Angular Frontend A
- **Tecnología**: Angular + Node.js 18
- **Workflow**: `ci-cd.yml`
- **Características**:
  - ✅ Tests unitarios y E2E con Playwright
  - ✅ Auditoría de performance con Lighthouse
  - ✅ Build para múltiples ambientes
  - ✅ Escaneo de seguridad con Snyk
  - ✅ Análisis de dependencias

### 3. **poc-billpay-front-b** - Angular Frontend B
- **Tecnología**: Angular + Node.js 18
- **Workflow**: `ci-cd.yml`
- **Características**:
  - ✅ A/B Testing automatizado
  - ✅ Canary Deployment
  - ✅ Comparación de performance
  - ✅ Tests de integración
  - ✅ Monitoreo de métricas

### 4. **poc-billpay-front-feature-flags** - Frontend con Feature Flags
- **Tecnología**: Angular + Feature Flags
- **Workflow**: `ci-cd.yml`
- **Características**:
  - ✅ Validación de feature flags
  - ✅ Testing de combinaciones de flags
  - ✅ Rollout progresivo de features
  - ✅ Monitoreo de uso de features
  - ✅ Build por conjunto de features

### 5. **poc-icbs** - Oracle WebLogic Platform
- **Tecnología**: Docker + WebLogic + Oracle DB
- **Workflow**: `ci-cd.yml`
- **Características**:
  - ✅ Build de múltiples imágenes Docker
  - ✅ Tests de integración completos
  - ✅ Gestión de feature flags
  - ✅ Despliegue canary
  - ✅ Monitoreo de infraestructura

## 🔧 Configuración Requerida

### 1. Secrets de GitHub

Cada repositorio necesita los siguientes secrets configurados en GitHub:

#### **Secrets Comunes (Todos los Repositorios)**
```bash
# Docker Registry
DOCKER_REGISTRY=your-registry.com
DOCKER_USERNAME=your-username
DOCKER_PASSWORD=your-password

# GitHub Token (para SonarQube y otros)
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
```

#### **Secrets Específicos por Repositorio**

**poc-billpay-back:**
```bash
SONAR_TOKEN=your-sonar-token
CODECOV_TOKEN=your-codecov-token
```

**Frontends (A, B, Feature Flags):**
```bash
SNYK_TOKEN=your-snyk-token
CODECOV_TOKEN=your-codecov-token
```

**poc-icbs:**
```bash
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-token
```

### 2. Environments de GitHub

Configura los siguientes environments en cada repositorio:

- **development**: Para despliegues automáticos desde `develop`
- **production**: Para despliegues desde `main` (con aprobación manual)

### 3. Branch Protection Rules

Configura las siguientes reglas para la rama `main`:

```yaml
- Require pull request reviews before merging
- Require status checks to pass before merging:
  - test
  - build
  - security-scan
- Require branches to be up to date before merging
- Restrict pushes that create files larger than 100MB
```

## 📦 Archivos de Configuración Incluidos

### **Lighthouse Configuration** (Frontends)
```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["warn", {"minScore": 0.8}],
        "categories:accessibility": ["error", {"minScore": 0.9}]
      }
    }
  }
}
```

### **Playwright Configuration** (Frontends)
```typescript
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:4200',
    trace: 'on-first-retry'
  }
});
```

### **Dependabot Configuration** (Todos)
```yaml
version: 2
updates:
  - package-ecosystem: "npm" # o "gradle", "docker", etc.
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

## 🚀 Instrucciones de Despliegue

### 1. Copiar Workflows

```bash
# Para cada repositorio, copia los archivos correspondientes:
cp .github/workflows/ci-cd.yml /path/to/your/repo/.github/workflows/
cp .github/dependabot.yml /path/to/your/repo/.github/
cp .lighthouserc.json /path/to/your/repo/ # Solo frontends
cp playwright.config.ts /path/to/your/repo/ # Solo frontends
```

### 2. Configurar Secrets

1. Ve a **Settings > Secrets and variables > Actions**
2. Añade todos los secrets requeridos
3. Configura los environments necesarios

### 3. Activar Workflows

1. Haz push de los archivos al repositorio
2. Ve a la pestaña **Actions**
3. Los workflows se ejecutarán automáticamente

## 🔍 Monitoreo y Métricas

### **Métricas Recopiladas**

#### **Backend (Spring Boot)**
- ✅ Cobertura de código (JaCoCo)
- ✅ Calidad de código (SonarQube)
- ✅ Vulnerabilidades de seguridad
- ✅ Performance de build
- ✅ Tamaño de artefactos

#### **Frontends (Angular)**
- ✅ Performance (Lighthouse)
- ✅ Accesibilidad
- ✅ SEO Score
- ✅ Bundle size
- ✅ Test coverage
- ✅ E2E test results

#### **Feature Flags**
- ✅ Cobertura de feature flags
- ✅ Uso de features por ambiente
- ✅ Performance por conjunto de features
- ✅ Rollout success rate

#### **Infrastructure (ICBS)**
- ✅ Build time de imágenes Docker
- ✅ Vulnerabilidades en imágenes
- ✅ Health checks de servicios
- ✅ Integration test results

## 🛠️ Personalización

### **Modificar Triggers**

```yaml
on:
  push:
    branches: [ main, develop, 'feature/*' ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * 1' # Lunes a las 2 AM
  workflow_dispatch: # Manual trigger
```

### **Añadir Nuevos Jobs**

```yaml
custom-job:
  name: 🔧 Custom Job
  runs-on: ubuntu-latest
  needs: test
  steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
    - name: 🔧 Custom Step
      run: echo "Custom logic here"
```

### **Configurar Notificaciones**

```yaml
- name: 📢 Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🔒 Mejores Prácticas de Seguridad

### **1. Gestión de Secrets**
- ✅ Nunca hardcodear secrets en workflows
- ✅ Usar GitHub Secrets para información sensible
- ✅ Rotar secrets regularmente
- ✅ Usar least privilege principle

### **2. Escaneo de Seguridad**
- ✅ Trivy para vulnerabilidades en contenedores
- ✅ Snyk para dependencias de Node.js
- ✅ TruffleHog para detección de secrets
- ✅ CodeQL para análisis de código

### **3. Validación de Inputs**
- ✅ Validar todos los inputs externos
- ✅ Usar actions oficiales cuando sea posible
- ✅ Pin versions de actions con SHA

## 📊 Dashboard y Reportes

### **GitHub Actions Dashboard**
- Ve a la pestaña **Actions** para ver el estado de todos los workflows
- Usa **Insights > Dependency graph** para monitorear dependencias
- Revisa **Security > Code scanning** para alertas de seguridad

### **Métricas Externas**
- **SonarQube**: Calidad de código
- **Codecov**: Cobertura de tests
- **Lighthouse CI**: Performance web
- **Snyk**: Vulnerabilidades de seguridad

## 🆘 Troubleshooting

### **Problemas Comunes**

#### **1. Workflow no se ejecuta**
```bash
# Verificar sintaxis YAML
yamllint .github/workflows/ci-cd.yml

# Verificar permisos
# Settings > Actions > General > Workflow permissions
```

#### **2. Tests fallan en CI pero pasan localmente**
```bash
# Verificar variables de entorno
# Añadir debug logging
- name: 🐛 Debug Environment
  run: |
    echo "Node version: $(node --version)"
    echo "NPM version: $(npm --version)"
    printenv | sort
```

#### **3. Docker build falla**
```bash
# Verificar Dockerfile
docker build -t test-image .

# Verificar secrets de Docker registry
# Settings > Secrets > DOCKER_USERNAME, DOCKER_PASSWORD
```

## 📞 Soporte

Para problemas con los workflows:

1. **Revisa los logs** en la pestaña Actions
2. **Consulta la documentación** de GitHub Actions
3. **Abre un issue** en el repositorio correspondiente
4. **Contacta al equipo DevOps** para problemas de infraestructura

---

**🚀 ¡Los workflows están listos para usar!** 

Simplemente copia los archivos, configura los secrets y haz push para activar la automatización completa de CI/CD.
