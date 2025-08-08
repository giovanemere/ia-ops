# 🚀 Guía de Inicio Rápido - Backstage IA-OPS

## ⚡ Configuración en 5 Minutos

### Paso 1: Configurar Variables de Entorno (2 min)

```bash
# Navegar al directorio raíz de IA-OPS
cd /home/giovanemere/ia-ops/ia-ops

# Crear archivo .env con configuración básica
cat > .env << 'EOF'
# GitHub Integration
GITHUB_TOKEN=ghp_your_github_token_here

# Backend Security
BACKEND_SECRET=$(openssl rand -base64 32)

# Optional: Database URL for production
# DATABASE_URL=postgresql://user:password@localhost:5432/backstage
EOF

# Hacer el archivo .env accesible para Backstage
cp .env applications/backstage/.env
```

**🔑 Obtener GitHub Token:**
1. Ve a GitHub → Settings → Developer settings → Personal access tokens
2. Genera un nuevo token con permisos: `repo`, `read:user`, `read:org`
3. Reemplaza `ghp_your_github_token_here` con tu token real

### Paso 2: Personalizar para IA-OPS (2 min)

```bash
cd applications/backstage

# Personalizar configuración básica
sed -i 's/My Company/IA-OPS/g' app-config.yaml
sed -i 's/Scaffolded Backstage App/IA-OPS Developer Portal/g' app-config.yaml
```

### Paso 3: Iniciar la Aplicación (1 min)

```bash
# Instalar dependencias (si no se ha hecho)
yarn install

# Iniciar Backstage
yarn start
```

**✅ Verificación:**
- Frontend: http://localhost:3000
- Backend: http://localhost:7007

---

## 🎯 Verificación Rápida de Funcionalidad

### Checklist de 2 Minutos
- [ ] ✅ Frontend carga sin errores
- [ ] ✅ Puedes ver el catálogo con entidades de ejemplo
- [ ] ✅ TechDocs muestra documentación de "sample-service"
- [ ] ✅ Búsqueda funciona (busca "example")
- [ ] ✅ Scaffolder muestra templates disponibles

### Si algo no funciona:
```bash
# Verificar logs
yarn start --verbose

# Limpiar y reinstalar
yarn clean
yarn install
yarn start
```

---

## 🔧 Configuración Inmediata Post-Inicio

### 1. Añadir Tu Primer Servicio (5 min)

```bash
# Crear directorio para tu servicio
mkdir -p examples/my-first-service/docs

# Crear catalog-info.yaml
cat > examples/my-first-service/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-first-service
  description: Mi primer servicio en Backstage
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: experimental
  owner: team-ia-ops
  system: ia-ops-platform
EOF

# Crear documentación básica
cat > examples/my-first-service/mkdocs.yml << 'EOF'
site_name: My First Service
site_description: Documentación de mi primer servicio

nav:
  - Home: index.md

plugins:
  - techdocs-core

theme:
  name: material
EOF

cat > examples/my-first-service/docs/index.md << 'EOF'
# Mi Primer Servicio

¡Bienvenido a mi primer servicio en Backstage!

## Descripción
Este es un servicio de ejemplo para demostrar las capacidades de Backstage.

## Características
- ✅ Documentación automática
- ✅ Integración con catálogo
- ✅ Búsqueda integrada

## Próximos Pasos
1. Personalizar esta documentación
2. Añadir más páginas
3. Configurar integraciones
EOF

# Registrar en el catálogo
echo "    - type: file" >> app-config.yaml
echo "      target: ../../examples/my-first-service/catalog-info.yaml" >> app-config.yaml
```

### 2. Crear Sistema y Equipo IA-OPS (3 min)

```bash
# Actualizar entities.yaml con estructura IA-OPS
cat > examples/entities.yaml << 'EOF'
---
# Sistema Principal IA-OPS
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: ia-ops-platform
  description: Plataforma de IA y Operaciones
spec:
  owner: team-ia-ops
---
# Subsistema de Machine Learning
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: ml-platform
  description: Plataforma de Machine Learning
spec:
  owner: team-ml
  parent: ia-ops-platform
---
# Subsistema de Data
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: data-platform
  description: Plataforma de Datos
spec:
  owner: team-data
  parent: ia-ops-platform
---
# Ejemplo de Servicio ML
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ml-model-service
  description: Servicio de modelos de ML
spec:
  type: service
  lifecycle: production
  owner: team-ml
  system: ml-platform
---
# Ejemplo de API de Datos
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: data-api
  description: API para acceso a datos
spec:
  type: openapi
  lifecycle: production
  owner: team-data
  system: data-platform
  definition: |
    openapi: 3.0.0
    info:
      title: Data API
      version: 1.0.0
    paths:
      /data:
        get:
          summary: Obtener datos
          responses:
            '200':
              description: Datos obtenidos exitosamente
EOF

# Actualizar org.yaml con equipos IA-OPS
cat > examples/org.yaml << 'EOF'
---
# Usuarios
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: admin-ia-ops
spec:
  memberOf: [team-ia-ops, admins]
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: ml-engineer
spec:
  memberOf: [team-ml]
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: data-engineer
spec:
  memberOf: [team-data]
---
# Grupos/Equipos
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-ia-ops
  description: Equipo principal de IA-OPS
spec:
  type: team
  children: [team-ml, team-data]
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-ml
  description: Equipo de Machine Learning
spec:
  type: team
  parent: team-ia-ops
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-data
  description: Equipo de Datos
spec:
  type: team
  parent: team-ia-ops
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: admins
  description: Administradores del sistema
spec:
  type: team
EOF
```

### 3. Reiniciar para Ver Cambios

```bash
# Detener Backstage (Ctrl+C)
# Reiniciar
yarn start
```

---

## 🎨 Personalización Visual Rápida

### Cambiar Colores y Logo (5 min)

```bash
# Personalizar tema en el frontend
cat > packages/app/src/theme.ts << 'EOF'
import { createTheme } from '@material-ui/core/styles';

export const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2', // Azul IA-OPS
    },
    secondary: {
      main: '#dc004e', // Rojo de acento
    },
  },
});
EOF

# Actualizar App.tsx para usar el tema personalizado
# (Esto requiere edición manual del archivo packages/app/src/App.tsx)
```

---

## 📚 Próximos Pasos Recomendados

### Inmediatos (Hoy)
1. **Explorar la Interfaz**
   - Navegar por el catálogo
   - Probar la búsqueda
   - Ver documentación de sample-service

2. **Añadir Servicios Reales**
   - Identificar servicios existentes en IA-OPS
   - Crear catalog-info.yaml para cada uno
   - Añadir documentación básica

### Esta Semana
1. **Configurar Integraciones**
   - GitHub Actions (si se usa)
   - Kubernetes (si aplica)
   - Herramientas de monitoreo

2. **Crear Templates**
   - Template para nuevos servicios ML
   - Template para APIs de datos
   - Template para documentación

### Próximas Semanas
1. **Desarrollar Plugins Personalizados**
   - Plugin para modelos ML
   - Plugin para pipelines de datos
   - Dashboard de métricas

---

## 🆘 Solución de Problemas Comunes

### Error: "GITHUB_TOKEN not found"
```bash
# Verificar que el token está configurado
echo $GITHUB_TOKEN

# Si está vacío, configurar:
export GITHUB_TOKEN=ghp_your_token_here
```

### Error: "Port 3000 already in use"
```bash
# Encontrar proceso usando el puerto
lsof -i :3000

# Matar proceso si es necesario
kill -9 <PID>

# O usar puerto diferente
PORT=3001 yarn start
```

### Error: "Database connection failed"
```bash
# Para desarrollo, usar SQLite (por defecto)
# Verificar que no hay configuración de PostgreSQL activa
grep -n "client: pg" app-config.yaml

# Si existe, comentar o cambiar a:
# client: better-sqlite3
# connection: ':memory:'
```

### Documentación no se genera
```bash
# Verificar Docker está corriendo
docker --version

# Verificar configuración TechDocs
grep -A 10 "techdocs:" app-config.yaml

# Limpiar cache de TechDocs
rm -rf node_modules/.cache/
```

---

## 📞 Ayuda y Recursos

### Documentación Completa
- `IMPLEMENTATION_STATUS.md` - Estado completo de la implementación
- `TODO_ROADMAP.md` - Tareas pendientes y roadmap
- `MKDOCS_SETUP.md` - Configuración avanzada de documentación

### Comandos Útiles
```bash
# Ver logs detallados
yarn start --verbose

# Limpiar todo y empezar de nuevo
yarn clean && yarn install

# Verificar configuración
yarn backstage-cli config:check

# Crear nuevo plugin
yarn new

# Ejecutar tests
yarn test
```

### Enlaces Útiles
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:7007/api
- **Documentación Oficial:** https://backstage.io/docs/
- **Plugins Disponibles:** https://backstage.io/plugins

---

## ✅ Checklist de Configuración Completa

- [ ] Variables de entorno configuradas
- [ ] GitHub token funcionando
- [ ] Aplicación inicia sin errores
- [ ] Catálogo muestra entidades IA-OPS
- [ ] TechDocs genera documentación
- [ ] Primer servicio añadido
- [ ] Equipos y usuarios configurados
- [ ] Búsqueda funciona correctamente

**🎉 ¡Felicidades! Tu Backstage está listo para IA-OPS**

---

**Tiempo Total de Configuración:** ~15-20 minutos  
**Próximo Paso:** Explorar y añadir tus servicios reales  
**Soporte:** Ver documentación completa en los archivos MD del proyecto
