# 🔒 Scripts Completos para Configurar Permisos de GitHub

## 📋 Problema Resuelto

Has solicitado scripts para automatizar la configuración de permisos de GitHub que resuelven el error:
```
Workflow permissions denied
```

## 🛠️ Scripts Creados

### 1. 🔧 `setup-workflow-permissions.sh` - Configuración Automática via API
**Ubicación**: `/home/giovanemere/ia-ops/ia-ops/scripts/setup-workflow-permissions.sh`

**Funcionalidades**:
- Configura automáticamente permisos de workflow via GitHub API
- Soporte para múltiples repositorios
- Verificación de configuración actual
- Configuración de permisos: `write`, `read`, `restricted`

**Uso**:
```bash
# Configurar repositorio por defecto
./scripts/setup-workflow-permissions.sh

# Configurar repositorio específico
./scripts/setup-workflow-permissions.sh -o usuario -r repo -p write

# Solo verificar configuración actual
./scripts/setup-workflow-permissions.sh --check

# Configurar múltiples repositorios
./scripts/setup-workflow-permissions.sh --multiple

# Ver ayuda completa
./scripts/setup-workflow-permissions.sh --help
```

### 2. 🔒 `setup-repository-security.sh` - Configuración Completa de Seguridad
**Ubicación**: `/home/giovanemere/ia-ops/ia-ops/scripts/setup-repository-security.sh`

**Funcionalidades**:
- Configuración completa de seguridad del repositorio
- Habilita GitHub Actions con permisos correctos
- Configura alertas de vulnerabilidad
- Crea configuración de Dependabot y CodeQL
- Configura protección de ramas

**Uso**:
```bash
# Configurar seguridad completa para repositorio por defecto
./scripts/setup-repository-security.sh

# Configurar repositorio específico
./scripts/setup-repository-security.sh usuario repo

# Ver ayuda
./scripts/setup-repository-security.sh --help
```

### 3. 📋 `manual-permissions-guide.sh` - Guía Manual Paso a Paso
**Ubicación**: `/home/giovanemere/ia-ops/ia-ops/scripts/manual-permissions-guide.sh`

**Funcionalidades**:
- Guía manual detallada para configurar permisos
- Instrucciones paso a paso con URLs específicas
- Checklist interactivo
- Troubleshooting completo
- No requiere API, funciona siempre

**Uso**:
```bash
# Mostrar guía completa
./scripts/manual-permissions-guide.sh

# Ver ayuda
./scripts/manual-permissions-guide.sh --help
```

### 4. 🔍 `diagnose-github-actions.sh` - Diagnóstico de Problemas
**Ubicación**: `/home/giovanemere/ia-ops/ia-ops/scripts/diagnose-github-actions.sh`

**Funcionalidades**:
- Diagnóstico completo de workflows
- Verificación de permisos
- Generación de workflows corregidos
- Soluciones para problemas comunes

**Uso**:
```bash
# Ejecutar diagnóstico completo
./scripts/diagnose-github-actions.sh

# Solo generar workflow corregido
./scripts/diagnose-github-actions.sh fix

# Ver ayuda
./scripts/diagnose-github-actions.sh --help
```

### 5. ✅ `verify-github-permissions.sh` - Verificación Post-Configuración
**Ubicación**: `/home/giovanemere/ia-ops/ia-ops/scripts/verify-github-permissions.sh`

**Funcionalidades**:
- Verificación completa post-configuración
- Test de conectividad con GitHub API
- Validación de permisos de token
- Simulación de SARIF upload

**Uso**:
```bash
# Verificar configuración completa
./scripts/verify-github-permissions.sh
```

## 🚀 Flujo de Uso Recomendado

### Opción A: Configuración Automática (Si tienes token con permisos)
```bash
# 1. Verificar estado actual
./scripts/diagnose-github-actions.sh

# 2. Configurar permisos automáticamente
./scripts/setup-workflow-permissions.sh

# 3. Configurar seguridad completa
./scripts/setup-repository-security.sh

# 4. Verificar configuración
./scripts/verify-github-permissions.sh
```

### Opción B: Configuración Manual (Recomendado)
```bash
# 1. Mostrar guía manual completa
./scripts/manual-permissions-guide.sh

# 2. Seguir las instrucciones paso a paso
# 3. Usar el checklist generado: github-permissions-checklist.md

# 4. Verificar configuración
./scripts/verify-github-permissions.sh
```

## 📊 Configuraciones que Resuelven el Problema

### 🔧 GitHub Actions Settings
**URL**: `https://github.com/giovanemere/ia-ops/settings/actions`

**Configuración requerida**:
- **Actions permissions**: "Allow all actions and reusable workflows"
- **Workflow permissions**: ✅ **"Read and write permissions"**
- **Allow GitHub Actions to create and approve pull requests**: ✅ **Habilitado**

### 🔒 Security & Analysis Settings
**URL**: `https://github.com/giovanemere/ia-ops/settings/security_analysis`

**Configuraciones requeridas**:
- **Dependency alerts**: ✅ Habilitado
- **Dependabot security updates**: ✅ Habilitado
- **Code scanning alerts**: ✅ Habilitado
- **Secret scanning alerts**: ✅ Habilitado (si está disponible)

## 🎯 Archivos Generados por los Scripts

### Archivos de Configuración Automática:
1. **`.github/dependabot.yml`** - Configuración de Dependabot
2. **`.github/workflows/codeql-analysis.yml`** - Análisis de CodeQL
3. **`github-permissions-checklist.md`** - Checklist interactivo

### Archivos de Diagnóstico:
1. **`.github/workflows/security-scan-fixed.yml`** - Workflow corregido
2. **Logs de diagnóstico** - Salida detallada de verificaciones

## 🔍 Verificación de Éxito

### ✅ Indicadores de Configuración Correcta:
```bash
# En los logs de GitHub Actions deberías ver:
✅ Successfully uploaded results
✅ Processing sarif files: ["trivy-results.sarif"]
✅ Validating trivy-results.sarif
✅ Adding fingerprints to SARIF file
```

### ❌ Errores que ya NO deberías ver:
```bash
❌ Resource not accessible by integration
❌ Workflow permissions denied
❌ Token permissions insufficient
❌ Error: Resource not accessible by integration
```

## 📚 URLs Importantes para Verificación

### Configuración:
- **Repository Settings**: https://github.com/giovanemere/ia-ops/settings
- **Actions Settings**: https://github.com/giovanemere/ia-ops/settings/actions
- **Security Settings**: https://github.com/giovanemere/ia-ops/settings/security_analysis
- **Branch Settings**: https://github.com/giovanemere/ia-ops/settings/branches

### Verificación de Resultados:
- **Actions Tab**: https://github.com/giovanemere/ia-ops/actions
- **Security Tab**: https://github.com/giovanemere/ia-ops/security
- **Code Scanning**: https://github.com/giovanemere/ia-ops/security/code-scanning

## 🛠️ Troubleshooting Rápido

### Si los scripts automáticos no funcionan:
1. **Usar la guía manual**: `./scripts/manual-permissions-guide.sh`
2. **Verificar token**: Asegúrate de que tenga scopes: `repo`, `workflow`, `security_events`
3. **Usar configuración manual**: Seguir las instrucciones paso a paso

### Si aún tienes errores después de la configuración:
1. **Ejecutar diagnóstico**: `./scripts/diagnose-github-actions.sh`
2. **Verificar configuración**: `./scripts/verify-github-permissions.sh`
3. **Revisar workflows**: Asegúrate de que tengan `permissions: security-events: write`

## 🎉 Resultado Final Esperado

Después de usar estos scripts y configurar los permisos:

1. ✅ **GitHub Actions funcionará** sin errores de permisos
2. ✅ **SARIF uploads funcionarán** correctamente
3. ✅ **Security scanning** aparecerá en el Security tab
4. ✅ **Workflows ejecutarán** sin warnings de permisos
5. ✅ **Dependabot y CodeQL** funcionarán automáticamente

## 📝 Comandos de Verificación Final

```bash
# 1. Commit todos los cambios
git add scripts/ .github/ *.md
git commit -m "🔒 Add complete GitHub permissions configuration scripts"
git push origin trunk

# 2. Ejecutar workflow manualmente en GitHub
# Ve a Actions → Security Scan → Run workflow

# 3. Verificar resultados
# Ve a Security tab y confirma que aparecen los resultados SARIF
```

---

**✨ Scripts creados exitosamente por el equipo IA-Ops**  
**📅 Fecha: $(date)**  
**🔧 Total de scripts**: 5 scripts completos  
**🎯 Problema resuelto**: Workflow permissions denied + SARIF upload issues
