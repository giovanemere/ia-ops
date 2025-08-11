# 📚 GitHub Pages Setup Guide

## Overview

This guide explains how to set up GitHub Pages for the IA-Ops Platform documentation.

## 🔧 Repository Configuration

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Save the configuration

### 2. Configure Permissions

The repository needs the following permissions for GitHub Actions:

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**

### 3. Branch Protection (Optional but Recommended)

1. Go to **Settings** → **Branches**
2. Add rule for `trunk` branch:
   - ✅ **Require status checks to pass before merging**
   - ✅ **Require branches to be up to date before merging**
   - Select: `validate-structure`, `test-documentation`, `security-scan`

## 🚀 Deployment Workflows

### Automatic Deployment

The documentation is automatically deployed when:
- Changes are pushed to the `trunk` branch
- Files in `docs/` directory are modified
- MkDocs configuration files are updated

**Workflow file**: `.github/workflows/deploy-docs.yml`

### Manual Deployment

You can manually trigger documentation deployment:

1. Go to **Actions** tab in your repository
2. Select **Deploy Documentation to GitHub Pages**
3. Click **Run workflow**
4. Select `trunk` branch
5. Click **Run workflow**

## 📋 Workflow Status

### Main CI/CD Pipeline
- **File**: `.github/workflows/main-ci.yml`
- **Triggers**: Push to `trunk`, Pull Requests
- **Purpose**: Validate, test, and build (but not deploy)

### Documentation Deployment
- **File**: `.github/workflows/deploy-docs.yml`
- **Triggers**: Push to `trunk` (docs changes), Manual dispatch
- **Purpose**: Build and deploy documentation to GitHub Pages

## 🔍 Troubleshooting

### Common Issues

#### 1. Pages Not Updating
```bash
# Check if workflow ran successfully
# Go to Actions tab and verify deploy-docs workflow

# Force rebuild by pushing a change to docs/
git commit --allow-empty -m "docs: trigger pages rebuild"
git push origin trunk
```

#### 2. Permission Denied Errors
```bash
# Verify repository permissions:
# Settings → Actions → General → Workflow permissions
# Should be "Read and write permissions"
```

#### 3. Build Failures
```bash
# Test build locally
./validate-docs-build.sh

# Check for broken links or missing files
mkdocs build --config-file mkdocs.ci.yml --clean
```

#### 4. Custom Domain Issues
```bash
# If using custom domain, add CNAME file to docs/
echo "your-domain.com" > docs/CNAME
git add docs/CNAME
git commit -m "docs: add custom domain"
git push origin trunk
```

## 📊 Monitoring

### Check Deployment Status

1. **Actions Tab**: Monitor workflow runs
2. **Pages Settings**: View deployment history
3. **Repository Insights**: Check Pages traffic

### Useful Commands

```bash
# Check if site is accessible
curl -I https://your-username.github.io/ia-ops/

# Validate local build
./validate-docs-build.sh

# Test with local server
./validate-docs-build.sh --test-serve
```

## 🔗 URLs

After successful setup, your documentation will be available at:

- **GitHub Pages URL**: `https://your-username.github.io/repository-name/`
- **Custom Domain** (if configured): `https://your-domain.com/`

## 📝 Configuration Files

### MkDocs Configuration
- **Production**: `mkdocs.yml` (with techdocs-core for Backstage)
- **CI/CD**: `mkdocs.ci.yml` (without techdocs-core for GitHub Actions)

### GitHub Actions
- **Main CI**: `.github/workflows/main-ci.yml`
- **Documentation**: `.github/workflows/deploy-docs.yml`
- **Trunk Validation**: `.github/workflows/trunk-validation.yml`

## 🛡️ Security

### Permissions Required
- `contents: read` - Read repository content
- `pages: write` - Deploy to GitHub Pages
- `id-token: write` - OIDC token for deployment

### Best Practices
- Use minimal required permissions
- Enable branch protection rules
- Review deployment logs regularly
- Monitor for unauthorized changes

## 📞 Support

If you encounter issues:

1. **Check Actions logs**: Detailed error messages in workflow runs
2. **Validate locally**: Use `./validate-docs-build.sh`
3. **GitHub Docs**: [GitHub Pages documentation](https://docs.github.com/en/pages)
4. **MkDocs Docs**: [MkDocs documentation](https://www.mkdocs.org/)

---

## 🎯 Quick Setup Checklist

- [ ] Enable GitHub Pages with "GitHub Actions" source
- [ ] Set workflow permissions to "Read and write"
- [ ] Push changes to `trunk` branch
- [ ] Verify deployment in Actions tab
- [ ] Check documentation site is accessible
- [ ] Test automatic deployment with a docs change

**Your documentation should now be automatically deployed! 🎉**
