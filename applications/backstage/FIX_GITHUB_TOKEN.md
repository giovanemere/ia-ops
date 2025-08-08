# 🔧 Solución Rápida: Configurar GitHub Token

## Problema Identificado
Tu Backstage está configurado correctamente para usar variables de entorno, pero el `GITHUB_TOKEN` está usando un valor dummy que limita la funcionalidad.

## ✅ Estado Actual (Verificado)
- ✅ Variables de entorno se cargan correctamente
- ✅ Configuración de Backstage usa variables de entorno
- ✅ Todos los archivos de configuración están presentes
- ✅ Dependencias instaladas
- ⚠️  GITHUB_TOKEN usa valor dummy

## 🚀 Solución en 2 Minutos

### Opción 1: Configurar GitHub Token Real (Recomendado)

1. **Obtener GitHub Token:**
   ```bash
   # Ve a: https://github.com/settings/tokens
   # Crea un nuevo token con permisos:
   # - repo (acceso a repositorios)
   # - read:user (leer información de usuario)
   # - read:org (leer información de organización)
   ```

2. **Actualizar archivo .env:**
   ```bash
   cd /home/giovanemere/ia-ops/ia-ops
   
   # Hacer backup del .env actual
   cp .env .env.backup
   
   # Reemplazar el token dummy
   sed -i 's/GITHUB_TOKEN=dummy-token-not-used/GITHUB_TOKEN=ghp_tu_token_real_aqui/' .env
   ```

3. **Verificar cambio:**
   ```bash
   cd applications/backstage
   ./check-env.sh
   ```

### Opción 2: Usar Sin GitHub Integration (Temporal)

Si no necesitas la integración de GitHub inmediatamente:

1. **Comentar configuración de GitHub:**
   ```bash
   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
   
   # Comentar la configuración de GitHub en app-config.yaml
   sed -i '/github:/,/token: ${GITHUB_TOKEN}/s/^/#/' app-config.yaml
   ```

2. **Iniciar sin GitHub:**
   ```bash
   yarn start
   ```

## 🎯 Iniciar Backstage Ahora

Una vez configurado el token (o comentado GitHub), puedes iniciar:

```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Opción 1: Script personalizado (recomendado)
./start.sh

# Opción 2: Comando directo con dotenv
yarn start

# Opción 3: Tu comando original (también funciona)
dotenv -e ../../.env -- yarn start
```

## 🔍 Verificar que Funciona

1. **Frontend:** http://localhost:3002 (según tu configuración)
2. **Backend:** http://localhost:7007
3. **Verificar logs:** No deberían aparecer errores de GitHub token

## 📋 Checklist Post-Configuración

- [ ] GitHub token configurado o GitHub comentado
- [ ] `./check-env.sh` muestra ✅ para variables críticas
- [ ] Backstage inicia sin errores
- [ ] Frontend carga correctamente
- [ ] Catálogo muestra entidades de ejemplo
- [ ] TechDocs funciona (sample-service)

## 🆘 Si Aún Hay Problemas

### Error: "Invalid GitHub token"
```bash
# Verificar que el token es válido
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

### Error: "Port already in use"
```bash
# Verificar puertos ocupados
./check-env.sh

# Cambiar puertos si es necesario
export BACKSTAGE_BACKEND_PORT=7008
export BACKSTAGE_FRONTEND_PORT=3003
```

### Error: "Database connection failed"
```bash
# Usar SQLite por defecto (ya configurado)
# No requiere acción adicional
```

## 💡 Próximos Pasos

Una vez que Backstage esté funcionando:

1. **Personalizar para IA-OPS:** Ver `QUICK_START.md`
2. **Añadir servicios reales:** Crear catalog-info.yaml para tus servicios
3. **Configurar plugins adicionales:** Azure DevOps, Tech Radar, etc.

---

**¿Todo listo?** Ejecuta `./start.sh` y ve a http://localhost:3002 🚀
