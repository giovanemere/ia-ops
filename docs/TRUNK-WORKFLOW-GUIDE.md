# 🌳 Trunk-Only Workflow Guide

## 📋 Overview

The IA-Ops Platform has been migrated to use a **trunk-only workflow** for simplified branch management and continuous integration. This guide explains the new workflow and migration process.

## 🎯 Why Trunk-Only Workflow?

### Benefits
- **Simplified branching**: Single source of truth
- **Faster integration**: Continuous integration on trunk
- **Reduced complexity**: No long-lived feature branches
- **Better collaboration**: All developers work from the same base
- **Faster feedback**: Immediate CI/CD feedback on trunk

### Workflow Principles
- **Trunk is always deployable**: All code on trunk should be production-ready
- **Small, frequent commits**: Feature development in small increments
- **Feature flags**: Use feature toggles for incomplete features
- **Quick feedback**: Fast CI/CD pipeline for immediate validation

## 🚀 Migration Summary

### What Changed
- **Default branch**: Changed from `main` to `trunk`
- **GitHub Actions**: All workflows now trigger on `trunk` branch
- **Documentation**: Updated all branch references
- **GitOps**: ArgoCD and deployment configurations updated
- **Backstage**: Catalog configurations updated

### Files Updated
- `.github/workflows/main-ci.yml`
- `.github/workflows/backstage-build.yml`
- `.github/workflows/trunk-validation.yml` (new)
- `gitops/argocd/*.yaml`
- `catalog-*.yaml`
- Documentation files

## 🔄 Development Workflow

### 1. Daily Development
```bash
# Start your day - sync with trunk
git checkout trunk
git pull origin trunk

# Create feature branch (optional, for complex features)
git checkout -b feature/my-feature

# Make changes and commit frequently
git add .
git commit -m "feat: add new feature component"

# Push to trunk (for simple changes) or feature branch
git push origin trunk
# OR
git push origin feature/my-feature
```

### 2. Feature Development
```bash
# For larger features, use short-lived feature branches
git checkout -b feature/user-authentication
# Develop feature...
git commit -m "feat: implement user authentication"

# Merge back to trunk quickly (within 1-2 days)
git checkout trunk
git pull origin trunk
git merge feature/user-authentication
git push origin trunk

# Clean up feature branch
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 3. Hotfixes
```bash
# Hotfixes go directly to trunk
git checkout trunk
git pull origin trunk

# Make hotfix
git add .
git commit -m "fix: resolve critical security issue"
git push origin trunk

# Deploy immediately
```

## 🏗️ CI/CD Pipeline

### Trunk Branch Pipeline
```yaml
# Triggers on every push to trunk
on:
  push:
    branches: [ trunk ]
  pull_request:
    branches: [ trunk ]
```

### Pipeline Stages
1. **Validation**: Structure and security checks
2. **Testing**: Unit, integration, and documentation tests
3. **Building**: Docker images and artifacts
4. **Deployment**: Automatic deployment to staging
5. **Production**: Manual approval for production deployment

### Quality Gates
- All tests must pass
- Security scan must pass
- Code coverage threshold met
- Documentation updated

## 🛠️ Migration Commands

### Automatic Migration
```bash
# Run the migration script
./migrate-to-trunk.sh
```

### Manual Migration Steps
```bash
# 1. Switch to trunk branch
git checkout trunk

# 2. Merge any pending changes from main
git merge main --no-ff -m "Merge main into trunk"

# 3. Push trunk to remote
git push -u origin trunk

# 4. Set trunk as default branch (GitHub settings)
# Go to repository settings and change default branch

# 5. Update local tracking
git branch --set-upstream-to=origin/trunk trunk

# 6. Clean up old main branch (after verification)
git branch -d main
git push origin --delete main
```

## 🔍 Validation

### Automated Validation
The `trunk-validation.yml` workflow runs automatically to ensure:
- Trunk branch configuration is correct
- All workflows reference trunk branch
- Documentation is updated
- GitOps configurations are correct
- Backstage catalogs are updated

### Manual Validation
```bash
# Check current branch
git branch --show-current

# Verify workflows
grep -r "branches.*trunk" .github/workflows/

# Check for old main references
grep -r "main" . --exclude-dir=.git | grep -v trunk
```

## 📚 Best Practices

### Commit Practices
- **Small commits**: Keep commits small and focused
- **Descriptive messages**: Use conventional commit format
- **Frequent pushes**: Push to trunk multiple times per day
- **Test before push**: Ensure local tests pass

### Feature Development
- **Feature flags**: Use toggles for incomplete features
- **Backward compatibility**: Maintain API compatibility
- **Database migrations**: Use forward-compatible migrations
- **Rollback ready**: Ensure changes can be rolled back

### Code Review
- **Pair programming**: Collaborate on complex features
- **Post-commit review**: Review changes after merge
- **Automated checks**: Rely on CI/CD for validation
- **Quick feedback**: Address issues immediately

## 🚨 Troubleshooting

### Common Issues

#### 1. Old Branch References
```bash
# Error: remote branch 'main' not found
# Solution: Update remote tracking
git remote set-head origin trunk
git branch --set-upstream-to=origin/trunk trunk
```

#### 2. Workflow Not Triggering
```bash
# Check workflow configuration
cat .github/workflows/main-ci.yml | grep branches

# Should show: branches: [ trunk ]
```

#### 3. ArgoCD Not Syncing
```bash
# Check ArgoCD application configuration
grep -r "targetRevision" gitops/argocd/

# Should show: targetRevision: trunk
```

### Recovery Procedures

#### Restore from Backup
```bash
# If migration fails, restore from backup
git checkout main
git reset --hard origin/main
# Re-run migration script with fixes
```

#### Force Sync
```bash
# Force sync with remote trunk
git fetch origin
git reset --hard origin/trunk
```

## 📊 Monitoring

### Key Metrics
- **Commit frequency**: Commits per day to trunk
- **Build success rate**: Percentage of successful builds
- **Deployment frequency**: Deployments per day
- **Lead time**: Time from commit to production

### Dashboards
- **GitHub Actions**: Monitor workflow success rates
- **ArgoCD**: Track deployment status
- **Backstage**: View service health and metrics

## 🔗 Related Documentation

- [GitHub Actions Setup](../GITHUB_ACTIONS_SETUP.md)
- [GitOps Configuration](../gitops/README.md)
- [Backstage Integration](../applications/backstage/README.md)
- [Deployment Guide](../docs/deployment-guide.md)

## 🤝 Team Guidelines

### Communication
- **Daily standups**: Discuss trunk changes
- **Slack notifications**: CI/CD status updates
- **Documentation**: Keep README and docs updated

### Responsibilities
- **All developers**: Maintain trunk quality
- **Tech leads**: Monitor trunk health
- **DevOps team**: Maintain CI/CD pipeline
- **Product team**: Manage feature flags

---

## 📞 Support

For questions about the trunk workflow:
- **Tech Lead**: tech-lead@tu-organizacion.com
- **DevOps Team**: devops@tu-organizacion.com
- **GitHub Issues**: [Workflow Issues](https://github.com/tu-organizacion/ia-ops/issues)

---

**🌳 Trunk-Only Workflow** - Simplified, fast, and reliable development process for IA-Ops Platform
