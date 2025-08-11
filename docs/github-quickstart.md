# Guía Rápida - Configuración GitHub con Backstage

## 🚀 Configuración Inicial

### 1. Crear Personal Access Token (PAT)

1. Ve a GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Selecciona los siguientes scopes:
   ```
   ✅ repo (Full control of private repositories)
   ✅ read:org (Read org and team membership)
   ✅ read:user (Read user profile data)
   ✅ user:email (Access user email addresses)
   ```
4. Copia el token y actualiza `GITHUB_TOKEN` en `.env`

### 2. Crear GitHub OAuth App

1. Ve a GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Configura:
   ```
   Application name: IA-Ops Backstage
   Homepage URL: http://localhost:8080
   Authorization callback URL: http://localhost:8080/api/auth/github/handler/frame
   ```
4. Copia Client ID y Client Secret a `.env`:
   ```bash
   AUTH_GITHUB_CLIENT_ID=tu_client_id
   AUTH_GITHUB_CLIENT_SECRET=tu_client_secret
   ```

### 3. Actualizar Variables en `.env`

```bash
# Actualizar con tu información
GITHUB_ORG=tu-organizacion-real
GITHUB_REPO=tu-repositorio-principal

# Verificar URLs
GITHUB_BASE_URL=https://github.com
GITHUB_API_URL=https://api.github.com
```

## ✅ Validación Rápida

```bash
# 1. Validar configuración
./scripts/validate-github-integration.sh

# 2. Probar integración completa
./scripts/test-github-backstage-integration.sh

# 3. Test manual rápido
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## 📋 Checklist de Configuración

### Variables Críticas
- [ ] `GITHUB_TOKEN` - Personal Access Token válido
- [ ] `GITHUB_ORG` - Tu organización de GitHub
- [ ] `GITHUB_REPO` - Repositorio principal
- [ ] `AUTH_GITHUB_CLIENT_ID` - OAuth App Client ID
- [ ] `AUTH_GITHUB_CLIENT_SECRET` - OAuth App Client Secret

### Permisos del Token
- [ ] `repo` - Acceso a repositorios
- [ ] `read:org` - Leer organización
- [ ] `read:user` - Leer usuario
- [ ] `user:email` - Acceso a email

### OAuth App
- [ ] Callback URL configurada correctamente
- [ ] Client ID y Secret en `.env`
- [ ] App habilitada y activa

## 🔧 Comandos Útiles

### Verificar Token
```bash
# Información del usuario
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Rate limits
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit

# Organizaciones
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/orgs
```

### Verificar Repositorios
```bash
# Repositorios de la organización
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/orgs/$GITHUB_ORG/repos

# Repositorio específico
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO
```

### Verificar Catálogo
```bash
# Archivo catalog-info.yaml
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/contents/catalog-info.yaml
```

## 🎯 Casos de Uso

### 1. Catálogo Automático
```yaml
# catalog-info.yaml en tu repositorio
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: mi-servicio
  description: Descripción del servicio
  annotations:
    github.com/project-slug: tu-organizacion/mi-servicio
spec:
  type: service
  lifecycle: production
  owner: team-backend
```

### 2. Autenticación en Backstage
- Los usuarios podrán hacer login con GitHub
- Acceso basado en membresía de organización
- Permisos automáticos según equipos

### 3. Auto-discovery
- Backstage encontrará automáticamente repositorios
- Basado en topics/etiquetas configuradas
- Actualización periódica del catálogo

## ⚠️ Troubleshooting Común

### Error: "Bad credentials"
```bash
# Verificar token
echo $GITHUB_TOKEN

# Regenerar token en GitHub
# Actualizar .env con nuevo token
```

### Error: "Not Found" para organización
```bash
# Verificar nombre de organización
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/orgs/$GITHUB_ORG

# Verificar permisos read:org
```

### Error OAuth: "redirect_uri_mismatch"
```bash
# Verificar callback URL en GitHub OAuth App
# Debe ser exactamente: http://localhost:8080/api/auth/github/handler/frame
```

### Rate Limit Exceeded
```bash
# Verificar límites
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# Esperar reset o usar GitHub App en lugar de PAT
```

## 🔒 Seguridad

### Mejores Prácticas
1. **Nunca commitear tokens**
   ```bash
   # Verificar .gitignore
   grep ".env" .gitignore
   ```

2. **Rotar tokens regularmente**
   ```bash
   # Programar rotación mensual
   # Usar tokens con fecha de expiración
   ```

3. **Principio de menor privilegio**
   ```bash
   # Solo scopes necesarios
   # Tokens específicos por función
   ```

## 📊 Monitoreo

### Health Checks
```bash
# GitHub API status
curl https://www.githubstatus.com/api/v2/status.json

# Tu conectividad
./scripts/validate-github-integration.sh
```

### Métricas
```bash
# Rate limits
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# Uso del token
# Revisar en GitHub Settings → Personal access tokens
```

## 🚀 Próximos Pasos

1. **Configurar Webhooks**
   ```bash
   # Para actualizaciones automáticas del catálogo
   # URL: http://localhost:8080/api/github/webhook
   ```

2. **Crear Templates**
   ```bash
   # Templates de Backstage para nuevos servicios
   # Integrados con GitHub Actions
   ```

3. **Configurar TechDocs**
   ```bash
   # Documentación automática desde repositorios
   # Usando MkDocs y GitHub Pages
   ```

## 📚 Referencias

- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Backstage GitHub Integration](https://backstage.io/docs/integrations/github/)
- [GitHub API Documentation](https://docs.github.com/en/rest)
