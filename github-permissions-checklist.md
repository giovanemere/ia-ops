# 🔒 GitHub Permissions Configuration Checklist

## ✅ Actions Configuration
- [ ] Ve a Settings → Actions → General
- [ ] Actions permissions: "Allow all actions and reusable workflows"
- [ ] Workflow permissions: "Read and write permissions"
- [ ] Allow GitHub Actions to create and approve pull requests: ✅

## ✅ Security & Analysis
- [ ] Ve a Settings → Security & analysis
- [ ] Dependency alerts: Enabled
- [ ] Dependabot security updates: Enabled
- [ ] Code scanning alerts: Enabled
- [ ] Secret scanning alerts: Enabled (si está disponible)

## ✅ Branch Protection
- [ ] Ve a Settings → Branches
- [ ] Add rule para rama "trunk"
- [ ] Require a pull request before merging: ✅
- [ ] Require status checks to pass before merging: ✅
- [ ] Require branches to be up to date before merging: ✅

## ✅ Verification
- [ ] Ejecutar workflow manualmente
- [ ] Verificar que no hay errores de permisos
- [ ] Verificar que SARIF se sube correctamente
- [ ] Verificar resultados en Security tab

## 🔧 URLs Importantes
- Repository Settings: https://github.com/giovanemere/ia-ops/settings
- Actions Settings: https://github.com/giovanemere/ia-ops/settings/actions
- Security Settings: https://github.com/giovanemere/ia-ops/settings/security_analysis
- Branch Settings: https://github.com/giovanemere/ia-ops/settings/branches
- Security Tab: https://github.com/giovanemere/ia-ops/security
- Actions Tab: https://github.com/giovanemere/ia-ops/actions

## 📝 Notes
- Fecha de configuración: $(date)
- Configurado por: Manual setup script
- Repositorio: giovanemere/ia-ops
