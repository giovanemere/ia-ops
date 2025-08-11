# 🔒 Docker Hub Private Repository Setup - IA-Ops Backstage

## 📋 Resumen

Esta guía te ayudará a configurar un **repositorio privado** en Docker Hub para la imagen de Backstage, proporcionando mayor seguridad y control de acceso.

## 🔒 ¿Por qué un Repositorio Privado?

### Ventajas
- ✅ **Seguridad**: Solo usuarios autorizados pueden acceder
- ✅ **Control de acceso**: Gestión granular de permisos
- ✅ **Código propietario**: Protección de IP y configuraciones sensibles
- ✅ **Compliance**: Cumplimiento de políticas de seguridad empresarial
- ✅ **Auditoría**: Mejor trazabilidad de accesos

### Diferencias con Repositorio Público
| Aspecto | Público | Privado |
|---------|---------|---------|
| **Visibilidad** | Cualquiera puede ver | Solo usuarios autorizados |
| **Pull** | `docker pull imagen` | `docker login && docker pull imagen` |
| **Búsquedas** | Aparece en búsquedas | No aparece públicamente |
| **Costo** | Gratis | Puede requerir plan de pago |
| **Seguridad** | Básica | Alta |

## 🚀 Configuración Paso a Paso

### 1. **Crear Repositorio Privado en Docker Hub**

#### Opción A: Interfaz Web
1. Ve a: https://hub.docker.com/repository/create
2. **Repository Name**: `ia-ops-backstage-private`
3. **Visibility**: Selecciona **Private** 🔒
4. **Description**: `Private Backstage Developer Portal for IA-Ops Platform`
5. Click **Create**

#### Opción B: Automático (se crea al hacer push)
El repositorio se creará automáticamente como privado al hacer el primer push.

### 2. **Verificar Secrets de GitHub**

Los secrets ya están configurados, pero verifica que sean correctos:

```bash
# Verificar que los secrets existen (los configuramos anteriormente)
# DOCKER_HUB_USERNAME = giovanemere
# DOCKER_HUB_TOKEN = [tu access token con permisos Read, Write, Delete]
```

### 3. **Workflow Configurado**

El workflow ya está creado en `.github/workflows/docker-hub-push-private.yml`:

```yaml
env:
  DOCKER_HUB_REPOSITORY: giovanemere/ia-ops-backstage-private
```

## 🏗️ Arquitectura del Repositorio Privado

### Imagen de Docker Hub
- **Repository**: `giovanemere/ia-ops-backstage-private` 🔒
- **Visibilidad**: Private
- **Arquitecturas**: linux/amd64, linux/arm64
- **Tags automáticos**:
  - `latest` - Última versión de trunk
  - `stable` - Versión estable (solo trunk)
  - `trunk` - Branch trunk
  - `2024.08.11-abc1234` - Fecha + SHA
  - `abc1234` - Solo SHA del commit

### Labels OCI Específicos
```yaml
org.opencontainers.image.title: "IA-Ops Backstage (Private)"
org.opencontainers.image.description: "Private Backstage Developer Portal for IA-Ops Platform"
org.opencontainers.image.visibility: "private"
```

## 🔧 Scripts Disponibles

### Para Repositorio Privado
```bash
# Push manual al repositorio privado
./applications/backstage/push-to-docker-hub-private.sh

# Verificar imagen privada
./scripts/verify-docker-hub-private.sh

# Monitorear workflow privado
./monitor-docker-hub-private.sh
```

### Scripts Originales (Repositorio Público)
```bash
# Push manual al repositorio público
./applications/backstage/push-to-docker-hub.sh

# Verificar imagen pública
./scripts/verify-docker-hub.sh

# Monitorear workflow público
./monitor-docker-hub-workflow.sh
```

## 🧪 Uso del Repositorio Privado

### Pull de la Imagen Privada
```bash
# 1. Autenticarse (REQUERIDO)
docker login

# 2. Pull de la imagen privada
docker pull giovanemere/ia-ops-backstage-private:latest

# 3. Ejecutar localmente
docker run -p 7007:7007 giovanemere/ia-ops-backstage-private:latest
```

### Docker Compose con Repositorio Privado
```yaml
version: '3.8'
services:
  backstage:
    image: giovanemere/ia-ops-backstage-private:latest
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
```

**Nota**: Asegúrate de hacer `docker login` antes de ejecutar `docker-compose up`.

## 🔍 Verificación y Testing

### Verificar que el Repositorio es Privado
```bash
# 1. Verificar imagen privada
./scripts/verify-docker-hub-private.sh

# 2. Intentar pull sin autenticación (debería fallar)
docker logout
docker pull giovanemere/ia-ops-backstage-private:latest
# Resultado esperado: Error de autenticación

# 3. Pull con autenticación (debería funcionar)
docker login
docker pull giovanemere/ia-ops-backstage-private:latest
# Resultado esperado: Pull exitoso
```

### Verificar Labels de Privacidad
```bash
# Inspeccionar labels de la imagen
docker inspect giovanemere/ia-ops-backstage-private:latest | \
  jq -r '.[0].Config.Labels."org.opencontainers.image.visibility"'
# Resultado esperado: "private"
```

## 🔗 Enlaces Importantes

### GitHub
- **Workflow Privado**: https://github.com/giovanemere/ia-ops/actions/workflows/docker-hub-push-private.yml
- **Todos los Actions**: https://github.com/giovanemere/ia-ops/actions
- **Secrets**: https://github.com/giovanemere/ia-ops/settings/secrets/actions

### Docker Hub
- **Repositorio Privado**: https://hub.docker.com/r/giovanemere/ia-ops-backstage-private
- **Tags Privados**: https://hub.docker.com/r/giovanemere/ia-ops-backstage-private/tags
- **Configuración**: https://hub.docker.com/settings/security

## 🚨 Troubleshooting

### Error: "Repository not found"
```bash
Error: pull access denied for giovanemere/ia-ops-backstage-private
```
**Causas**:
- No estás autenticado: `docker login`
- No tienes permisos para el repositorio privado
- El repositorio no existe aún

**Soluciones**:
```bash
# Autenticarse
docker login

# Verificar que el repositorio existe
./scripts/verify-docker-hub-private.sh

# Crear repositorio manualmente si no existe
# Ve a: https://hub.docker.com/repository/create
```

### Error: "Access denied"
```bash
Error: unauthorized: access denied
```
**Causas**:
- Token de Docker Hub sin permisos suficientes
- Usuario no autorizado para el repositorio privado

**Soluciones**:
```bash
# Verificar token en GitHub Secrets
# Ve a: https://github.com/giovanemere/ia-ops/settings/secrets/actions

# Crear nuevo token con permisos completos
# Ve a: https://hub.docker.com/settings/security
```

### Workflow Falla en "Build and push"
```bash
Error: failed to push to registry
```
**Soluciones**:
```bash
# Verificar que el repositorio privado existe
# Ejecutar diagnóstico
./applications/backstage/diagnose-github-build.sh

# Probar build local
./applications/backstage/push-to-docker-hub-private.sh
```

## 💰 Consideraciones de Costo

### Docker Hub Pricing (Repositorios Privados)
- **Free Plan**: 1 repositorio privado
- **Pro Plan**: Repositorios privados ilimitados
- **Team Plan**: Para equipos con múltiples usuarios

### Recomendaciones
- Si es tu primer repositorio privado: **Free Plan** es suficiente
- Para múltiples proyectos: Considera **Pro Plan**
- Para equipos: **Team Plan** con gestión de accesos

## 🔐 Gestión de Accesos

### Compartir Acceso al Repositorio Privado
1. Ve a: https://hub.docker.com/r/giovanemere/ia-ops-backstage-private/settings
2. Tab **Collaborators**
3. Añadir usuarios por username o email
4. Asignar permisos (Read, Write, Admin)

### Mejores Prácticas de Seguridad
- ✅ Usar tokens de acceso en lugar de passwords
- ✅ Rotar tokens regularmente
- ✅ Principio de menor privilegio
- ✅ Auditar accesos regularmente
- ✅ Usar equipos para gestión de permisos

## 📊 Monitoreo y Métricas

### Métricas Disponibles
- **Pulls**: Número de descargas (solo usuarios autorizados)
- **Pushes**: Número de subidas
- **Storage**: Espacio utilizado
- **Bandwidth**: Transferencia de datos

### Comandos de Monitoreo
```bash
# Monitorear workflow privado
./monitor-docker-hub-private.sh

# Verificar estado de imagen privada
./scripts/verify-docker-hub-private.sh

# Ver información de imagen local
docker images giovanemere/ia-ops-backstage-private
```

## 🎯 Próximos Pasos

### Inmediatos
1. **Crear repositorio privado** en Docker Hub (si no existe)
2. **Ejecutar workflow** para subir primera imagen
3. **Verificar acceso** con `docker login && docker pull`

### Configuración Avanzada
1. **Configurar colaboradores** si trabajas en equipo
2. **Configurar webhooks** para notificaciones
3. **Implementar scanning de vulnerabilidades**
4. **Configurar políticas de retención**

## ✅ Checklist de Configuración

- [ ] Repositorio privado creado en Docker Hub
- [ ] Secrets configurados en GitHub (DOCKER_HUB_USERNAME, DOCKER_HUB_TOKEN)
- [ ] Workflow `docker-hub-push-private.yml` configurado
- [ ] Primera imagen subida exitosamente
- [ ] Pull de imagen privada funciona con autenticación
- [ ] Scripts de verificación funcionan
- [ ] Colaboradores añadidos (si aplica)
- [ ] Documentación actualizada

## 🎉 Estado Final

### ✅ Completado
- [x] Workflow para repositorio privado creado
- [x] Scripts específicos para repositorio privado
- [x] Documentación completa generada
- [x] Sistema de monitoreo implementado
- [x] Verificación de seguridad incluida

### 🚀 Resultado
**REPOSITORIO PRIVADO DE DOCKER HUB CONFIGURADO**

Tu imagen de Backstage estará disponible en un repositorio privado seguro:
- 🔒 **Solo usuarios autorizados** pueden acceder
- 🛡️ **Mayor seguridad** para código propietario
- 🎯 **Control total** sobre quién puede usar la imagen
- 📊 **Métricas detalladas** de uso

---

## 📞 Soporte

Si encuentras problemas:
1. **Ejecuta**: `./monitor-docker-hub-private.sh`
2. **Verifica**: `./scripts/verify-docker-hub-private.sh`
3. **Revisa**: GitHub Actions logs
4. **Consulta**: Esta documentación

---

**🔒 ¡Tu imagen de Backstage estará segura en un repositorio privado de Docker Hub!**

*Última actualización: $(date)*
*Repository: giovanemere/ia-ops-backstage-private*
*Visibility: 🔒 PRIVATE*
