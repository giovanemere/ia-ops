# ✅ Checklist Rápido - Implementación de Plugins Backstage

**Uso**: Para cada plugin que implementemos en Backstage  
**Directorio Base**: `/home/giovanemere/ia-ops/ia-ops/applications/backstage`

---

## 🚀 **MÉTODO AUTOMÁTICO (Recomendado)**

```bash
# Usar script automatizado
cd /home/giovanemere/ia-ops/ia-ops
./scripts/implement-plugin.sh <plugin-name>

# Ejemplos:
./scripts/implement-plugin.sh github
./scripts/implement-plugin.sh azure --verbose
./scripts/implement-plugin.sh mkdocs --dev-only
```

---

## 📋 **MÉTODO MANUAL (Paso a Paso)**

### **Paso 1: package.json**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Instalar plugin
yarn add @backstage/plugin-[nombre]
yarn add @backstage/plugin-[nombre]-backend  # Si aplica

# Verificar instalación
yarn list --pattern "@backstage/plugin-[nombre]"
```

### **Paso 2: Variables de Entorno**
```bash
# Editar archivo .env
nano /home/giovanemere/ia-ops/ia-ops/.env

# Agregar variables específicas del plugin
# Ejemplo para GitHub:
GITHUB_TOKEN=your_token_here
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
```

### **Paso 3: dotenv-cli**
```bash
# Verificar instalación
yarn list dotenv-cli

# Si no está instalado
yarn add --dev dotenv-cli

# Verificar scripts en package.json usan dotenv
```

### **Paso 4: Dependencias**
```bash
# Instalar dependencias
yarn install

# Resolver conflictos si existen
yarn why [package-name]

# Limpiar cache si es necesario
yarn cache clean
```

### **Paso 5: Desarrollo (yarn start)**
```bash
# Probar desarrollo con variables de entorno
dotenv -e /home/giovanemere/ia-ops/ia-ops/.env -- yarn start

# Verificar:
# - Plugin visible en UI
# - No errores en consola
# - Funcionalidades básicas operativas
```

### **Paso 6: Compilación (yarn build)**
```bash
# Probar build con variables de entorno
dotenv -e /home/giovanemere/ia-ops/ia-ops/.env -- yarn build

# Verificar:
# - Build completa sin errores
# - Artefactos en dist/
# - Tamaño optimizado
```

### **Paso 7: Docker Build**
```bash
# Construir imagen
docker build -t backstage-app:latest .

# Probar contenedor
docker run -p 3000:3000 --env-file /home/giovanemere/ia-ops/ia-ops/.env backstage-app:latest

# Verificar:
# - Contenedor inicia correctamente
# - Plugin funcional en contenedor
# - Variables de entorno cargadas
```

---

## 🔍 **VALIDACIÓN FINAL**

### **Checklist de Verificación**
- [ ] **Plugin instalado**: Aparece en package.json
- [ ] **Variables configuradas**: Definidas en .env
- [ ] **dotenv-cli funcionando**: Scripts usan dotenv
- [ ] **Dependencias OK**: yarn install sin errores
- [ ] **Desarrollo OK**: yarn start funcional
- [ ] **Build OK**: yarn build exitoso
- [ ] **Docker OK**: Imagen construye y ejecuta
- [ ] **Plugin visible**: Aparece en UI de Backstage
- [ ] **Funcionalidades**: Características básicas operativas
- [ ] **Documentación**: Plugin documentado

### **Comandos de Validación Rápida**
```bash
# Verificar todo de una vez
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# 1. Dependencias
yarn list --pattern "@backstage"

# 2. Variables de entorno
cat /home/giovanemere/ia-ops/ia-ops/.env | grep -i [plugin-name]

# 3. Build rápido
yarn build --stats

# 4. Docker
docker images | grep backstage-app
```

---

## 🛠️ **CONFIGURACIONES ESTÁNDAR**

### **Scripts Requeridos en package.json**
```json
{
  "scripts": {
    "dev": "dotenv -e ../.env -- backstage-cli package start",
    "start": "dotenv -e ../.env -- backstage-cli package start", 
    "build": "dotenv -e ../.env -- backstage-cli package build",
    "test": "dotenv -e ../.env -- backstage-cli package test"
  }
}
```

### **Variables Base en .env**
```bash
# Base Configuration
NODE_ENV=development
PORT=3000
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=backstage

# OpenAI (ya configurado)
OPENAI_API_KEY=your_key
OPENAI_SERVICE_URL=http://localhost:8000
```

---

## 🚨 **TROUBLESHOOTING RÁPIDO**

### **Errores Comunes**

#### **"Module not found"**
```bash
yarn clean
yarn install
yarn build
```

#### **"Environment variables not loaded"**
```bash
# Verificar archivo existe
ls -la /home/giovanemere/ia-ops/ia-ops/.env

# Verificar dotenv-cli
yarn list dotenv-cli
```

#### **"Plugin not appearing"**
```bash
# Verificar configuración en:
# - packages/app/src/App.tsx
# - packages/app/src/apis.ts
# - app-config.yaml
```

#### **"Docker build fails"**
```bash
# Limpiar cache
docker system prune -a

# Verificar Dockerfile y .dockerignore
```

---

## 📚 **PLUGINS ESPECÍFICOS**

### **GitHub Plugin**
```bash
# Instalar
yarn add @backstage/plugin-github-actions

# Variables .env
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret

# Repositorios objetivo
# - poc-billpay-back
# - poc-billpay-front-a
# - poc-billpay-front-b  
# - poc-billpay-front-feature-flags
# - poc-icbs
```

### **Azure Plugin**
```bash
# Instalar
yarn add @backstage/plugin-azure-devops

# Variables .env
AZURE_TOKEN=your_azure_token
AZURE_ORG=your_organization
```

### **MkDocs Plugin (Completar)**
```bash
# Ya instalado, completar configuración
# Variables .env
TECHDOCS_BUILDER=local
TECHDOCS_GENERATOR=mkdocs
TECHDOCS_PUBLISHER_TYPE=local
```

---

## 📊 **ESTADO ACTUAL**

```
✅ OpenAI Plugin:       100% - Funcional
🔄 MkDocs Plugin:       70%  - Completar pipeline automático
⏳ GitHub Plugin:       0%   - Pendiente implementación
⏳ Azure Plugin:        0%   - Pendiente implementación
✅ Tech Radar Plugin:   100% - Funcional
✅ Cost Insight Plugin: 100% - Funcional
```

### **Próximos Pasos**
1. **Completar MkDocs Plugin** (30% restante)
2. **Implementar GitHub Plugin** (acceso a repos)
3. **Implementar Azure Plugin** (pipelines)

---

**Creado**: 8 de Agosto de 2025  
**Mantenido por**: Backstage Specialist  
**Script automatizado**: `/scripts/implement-plugin.sh`
