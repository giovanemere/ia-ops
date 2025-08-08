# 🔌 Guía Estándar para Implementación de Plugins en Backstage

**Fecha de Creación**: 8 de Agosto de 2025  
**Versión**: 1.0  
**Aplicable a**: Todos los plugins de Backstage en IA-Ops Platform

---

## 📋 **PROCESO ESTÁNDAR DE IMPLEMENTACIÓN**

### **🎯 Objetivo**
Establecer un proceso consistente y repetible para la implementación de plugins en Backstage, asegurando que cada plugin funcione correctamente en nuestro entorno.

### **📍 Directorio Base**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
```

---

## ✅ **CHECKLIST DE IMPLEMENTACIÓN**

### **Paso 1: Revisar y Actualizar package.json**
- [ ] **Verificar dependencias existentes**
- [ ] **Agregar nuevas dependencias del plugin**
- [ ] **Verificar versiones compatibles**
- [ ] **Actualizar scripts si es necesario**

```bash
# Ejemplo de comandos
yarn add @backstage/plugin-[nombre-plugin]
yarn add @backstage/plugin-[nombre-plugin]-backend  # Si aplica
```

### **Paso 2: Actualizar/Revisar Variables de Entorno**
- [ ] **Revisar archivo**: `/home/giovanemere/ia-ops/ia-ops/.env`
- [ ] **Agregar variables específicas del plugin**
- [ ] **Verificar configuraciones existentes**
- [ ] **Documentar nuevas variables**

```bash
# Ejemplo de variables comunes
GITHUB_TOKEN=your_github_token
AZURE_TOKEN=your_azure_token
PLUGIN_[NAME]_CONFIG=value
```

### **Paso 3: Configurar dotenv-cli para Compilación**
- [ ] **Verificar dotenv-cli instalado**
- [ ] **Configurar scripts con dotenv**
- [ ] **Validar carga de variables**

```bash
# Verificar instalación
yarn list dotenv-cli

# Si no está instalado
yarn add --dev dotenv-cli
```

### **Paso 4: Revisar Dependencias**
- [ ] **Ejecutar yarn install**
- [ ] **Resolver conflictos de dependencias**
- [ ] **Verificar peer dependencies**
- [ ] **Limpiar cache si es necesario**

```bash
# Comandos de verificación
yarn install
yarn list --pattern "@backstage"
yarn why [package-name]  # Para resolver conflictos
```

### **Paso 5: Configurar Scripts de Desarrollo**
- [ ] **Verificar script yarn start**
- [ ] **Probar desarrollo local**
- [ ] **Validar hot reload**
- [ ] **Verificar plugin visible en UI**

```bash
# Script de desarrollo
yarn start

# Con variables de entorno
dotenv -e /home/giovanemere/ia-ops/ia-ops/.env -- yarn start
```

### **Paso 6: Configurar Scripts de Compilación**
- [ ] **Verificar script yarn build**
- [ ] **Probar compilación completa**
- [ ] **Verificar artefactos generados**
- [ ] **Validar optimizaciones**

```bash
# Script de compilación
yarn build

# Con variables de entorno
dotenv -e /home/giovanemere/ia-ops/ia-ops/.env -- yarn build
```

### **Paso 7: Build de Docker**
- [ ] **Verificar Dockerfile actualizado**
- [ ] **Construir imagen Docker**
- [ ] **Probar contenedor**
- [ ] **Validar plugin en contenedor**

```bash
# Build de Docker
docker build -t backstage-app:latest .

# Probar contenedor
docker run -p 3000:3000 --env-file /home/giovanemere/ia-ops/ia-ops/.env backstage-app:latest
```

---

## 🛠️ **CONFIGURACIONES ESPECÍFICAS**

### **package.json - Estructura Recomendada**

```json
{
  "name": "backstage-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "dotenv -e ../.env -- backstage-cli package start",
    "start": "dotenv -e ../.env -- backstage-cli package start",
    "build": "dotenv -e ../.env -- backstage-cli package build",
    "build:backend": "dotenv -e ../.env -- backstage-cli package build --role backend",
    "lint": "backstage-cli package lint",
    "test": "backstage-cli package test",
    "clean": "backstage-cli package clean"
  },
  "dependencies": {
    "@backstage/app-defaults": "^1.4.0",
    "@backstage/catalog-model": "^1.4.0",
    "@backstage/cli": "^0.22.0",
    "@backstage/core-app-api": "^1.8.0",
    "@backstage/core-components": "^0.13.0",
    "@backstage/core-plugin-api": "^1.5.0",
    "@backstage/integration-react": "^1.1.0",
    "@backstage/plugin-api-docs": "^0.9.0",
    "@backstage/plugin-catalog": "^1.11.0",
    "@backstage/plugin-catalog-common": "^1.0.0",
    "@backstage/plugin-catalog-graph": "^0.2.0",
    "@backstage/plugin-catalog-import": "^0.9.0",
    "@backstage/plugin-catalog-react": "^1.7.0",
    "@backstage/plugin-github-actions": "^0.5.0",
    "@backstage/plugin-org": "^0.6.0",
    "@backstage/plugin-permission-react": "^0.4.0",
    "@backstage/plugin-scaffolder": "^1.13.0",
    "@backstage/plugin-search": "^1.3.0",
    "@backstage/plugin-search-react": "^1.6.0",
    "@backstage/plugin-tech-radar": "^0.6.0",
    "@backstage/plugin-techdocs": "^1.6.0",
    "@backstage/plugin-techdocs-module-addons-contrib": "^1.0.0",
    "@backstage/plugin-techdocs-react": "^1.1.0",
    "@backstage/plugin-user-settings": "^0.7.0",
    "@backstage/theme": "^0.4.0"
  },
  "devDependencies": {
    "@backstage/test-utils": "^1.4.0",
    "@testing-library/jest-dom": "^5.10.1",
    "@testing-library/react": "^12.1.3",
    "@testing-library/user-event": "^14.0.0",
    "@types/react-dom": "*",
    "cross-env": "^7.0.0",
    "dotenv-cli": "^7.0.0"
  }
}
```

### **Variables de Entorno (.env)**

```bash
# Configuración Base
NODE_ENV=development
PORT=3000
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=backstage

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_SERVICE_URL=http://localhost:8000

# GitHub Integration
GITHUB_TOKEN=your_github_token
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Azure DevOps Integration
AZURE_TOKEN=your_azure_token
AZURE_ORG=your_azure_org

# Tech Radar Configuration
TECH_RADAR_URL=http://localhost:3000/tech-radar

# Cost Insights Configuration
COST_INSIGHTS_AWS_ACCESS_KEY_ID=your_aws_key
COST_INSIGHTS_AWS_SECRET_ACCESS_KEY=your_aws_secret

# TechDocs Configuration
TECHDOCS_BUILDER=local
TECHDOCS_GENERATOR=mkdocs
TECHDOCS_PUBLISHER_TYPE=local
```

### **Scripts Optimizados**

```json
{
  "scripts": {
    "dev": "dotenv -e ../.env -- concurrently \"yarn start\" \"yarn start:backend\"",
    "start": "dotenv -e ../.env -- backstage-cli package start",
    "start:backend": "dotenv -e ../.env -- backstage-cli package start --role backend",
    "build": "dotenv -e ../.env -- backstage-cli package build --stats",
    "build:backend": "dotenv -e ../.env -- backstage-cli package build --role backend",
    "build:image": "docker build -t backstage-app:latest .",
    "test": "dotenv -e ../.env -- backstage-cli package test",
    "test:watch": "dotenv -e ../.env -- backstage-cli package test --watch",
    "lint": "backstage-cli package lint",
    "lint:fix": "backstage-cli package lint --fix",
    "prettier:check": "prettier --check .",
    "prettier:fix": "prettier --write .",
    "clean": "backstage-cli package clean",
    "postinstall": "husky install"
  }
}
```

---

## 🔍 **VALIDACIÓN Y TESTING**

### **Checklist de Validación**

#### **Desarrollo Local**
- [ ] **Plugin visible en navegación**
- [ ] **Funcionalidades básicas operativas**
- [ ] **No hay errores en consola**
- [ ] **Performance aceptable**

#### **Build de Producción**
- [ ] **Build completa sin errores**
- [ ] **Tamaño de bundle optimizado**
- [ ] **Assets generados correctamente**
- [ ] **Source maps disponibles**

#### **Contenedor Docker**
- [ ] **Imagen construye exitosamente**
- [ ] **Contenedor inicia correctamente**
- [ ] **Plugin funcional en contenedor**
- [ ] **Variables de entorno cargadas**

### **Comandos de Validación**

```bash
# Validar desarrollo
yarn start
# Verificar: http://localhost:3000

# Validar build
yarn build
ls -la dist/

# Validar Docker
docker build -t backstage-app:latest .
docker run -p 3000:3000 --env-file ../.env backstage-app:latest

# Validar dependencias
yarn audit
yarn outdated
```

---

## 🚨 **TROUBLESHOOTING COMÚN**

### **Problemas Frecuentes**

#### **Error: Module not found**
```bash
# Solución
yarn install
yarn clean
yarn build
```

#### **Error: Environment variables not loaded**
```bash
# Verificar archivo .env
cat /home/giovanemere/ia-ops/ia-ops/.env

# Verificar dotenv-cli
yarn list dotenv-cli
```

#### **Error: Plugin not appearing in UI**
```bash
# Verificar configuración en App.tsx
# Verificar rutas en packages/app/src/App.tsx
# Verificar exportaciones en packages/app/src/apis.ts
```

#### **Error: Docker build fails**
```bash
# Limpiar cache Docker
docker system prune -a

# Verificar Dockerfile
# Verificar .dockerignore
```

### **Logs de Debug**

```bash
# Logs detallados de desarrollo
DEBUG=* yarn start

# Logs de build
yarn build --verbose

# Logs de Docker
docker build -t backstage-app:latest . --progress=plain
```

---

## 📚 **DOCUMENTACIÓN POR PLUGIN**

### **Template de Documentación**

Para cada plugin implementado, crear documentación con:

```markdown
# Plugin [Nombre]

## Configuración
- Variables de entorno requeridas
- Dependencias específicas
- Configuración en app-config.yaml

## Funcionalidades
- Lista de características implementadas
- Casos de uso principales
- Limitaciones conocidas

## Troubleshooting
- Problemas comunes
- Soluciones aplicadas
- Contactos de soporte
```

---

## 🔄 **PROCESO DE ACTUALIZACIÓN**

### **Para Actualizaciones de Plugins**

1. **Verificar changelog del plugin**
2. **Actualizar versión en package.json**
3. **Ejecutar yarn install**
4. **Probar en desarrollo**
5. **Ejecutar tests**
6. **Build y validar**
7. **Actualizar documentación**

### **Para Nuevos Plugins**

1. **Seguir checklist completo**
2. **Documentar configuración**
3. **Crear tests específicos**
4. **Actualizar guías de usuario**
5. **Comunicar a equipo**

---

**Creado por**: Equipo IA-Ops Platform  
**Mantenido por**: Backstage Specialist  
**Última actualización**: 8 de Agosto de 2025  
**Próxima revisión**: Con cada nuevo plugin implementado
