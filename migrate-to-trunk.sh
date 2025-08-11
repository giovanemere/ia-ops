#!/bin/bash

# 🚀 IA-Ops Platform - Migration to Trunk-Only Workflow
# This script migrates the repository to use only the trunk branch

set -e

echo "🚀 Starting migration to trunk-only workflow..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This is not a git repository!"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
print_status "Current branch: $CURRENT_BRANCH"

# Step 1: Ensure we're on trunk branch
print_status "Step 1: Switching to trunk branch..."
if git show-ref --verify --quiet refs/heads/trunk; then
    print_status "Trunk branch exists, switching to it..."
    git checkout trunk
else
    print_warning "Trunk branch doesn't exist, creating it from current branch..."
    git checkout -b trunk
fi

# Step 2: Merge any changes from main if it exists
if git show-ref --verify --quiet refs/heads/main && [ "$CURRENT_BRANCH" != "trunk" ]; then
    print_status "Step 2: Merging changes from main branch..."
    git merge main --no-ff -m "Merge main into trunk for migration"
    print_success "Merged main branch into trunk"
else
    print_status "Step 2: No main branch to merge or already on trunk"
fi

# Step 3: Update remote trunk branch
print_status "Step 3: Pushing trunk branch to remote..."
git push -u origin trunk
print_success "Trunk branch pushed to remote"

# Step 4: Set trunk as default branch (requires GitHub CLI or manual action)
print_status "Step 4: Setting trunk as default branch..."
if command -v gh &> /dev/null; then
    print_status "GitHub CLI found, setting trunk as default branch..."
    gh repo edit --default-branch trunk
    print_success "Trunk set as default branch via GitHub CLI"
else
    print_warning "GitHub CLI not found. Please manually set trunk as default branch in GitHub repository settings:"
    print_warning "1. Go to your repository on GitHub"
    print_warning "2. Click on Settings"
    print_warning "3. In the General section, find 'Default branch'"
    print_warning "4. Change it from 'main' to 'trunk'"
    print_warning "5. Click 'Update'"
fi

# Step 5: Update any references to main branch in documentation
print_status "Step 5: Updating documentation references..."

# Update README.md if it contains main branch references
if [ -f "README.md" ]; then
    if grep -q "main" README.md; then
        print_status "Updating README.md branch references..."
        sed -i 's/main/trunk/g' README.md
        print_success "Updated README.md"
    fi
fi

# Update any other documentation files
find docs/ -name "*.md" -type f 2>/dev/null | while read -r file; do
    if grep -q "main" "$file"; then
        print_status "Updating $file branch references..."
        sed -i 's/main/trunk/g' "$file"
        print_success "Updated $file"
    fi
done

# Step 6: Update GitOps configurations if they exist
print_status "Step 6: Updating GitOps configurations..."
if [ -d "gitops" ]; then
    find gitops/ -name "*.yaml" -o -name "*.yml" | while read -r file; do
        if grep -q "main" "$file"; then
            print_status "Updating $file branch references..."
            sed -i 's/main/trunk/g' "$file"
            print_success "Updated $file"
        fi
    done
fi

# Step 7: Update ArgoCD applications if they exist
if [ -d "gitops/argocd" ]; then
    find gitops/argocd/ -name "*.yaml" -o -name "*.yml" | while read -r file; do
        if grep -q "targetRevision.*main" "$file"; then
            print_status "Updating ArgoCD targetRevision in $file..."
            sed -i 's/targetRevision: main/targetRevision: trunk/g' "$file"
            sed -i 's/targetRevision: "main"/targetRevision: "trunk"/g' "$file"
            print_success "Updated ArgoCD configuration in $file"
        fi
    done
fi

# Step 8: Update Backstage catalog configurations
print_status "Step 8: Updating Backstage catalog configurations..."
find . -name "catalog-*.yaml" -o -name "catalog-*.yml" | while read -r file; do
    if grep -q "main" "$file"; then
        print_status "Updating $file branch references..."
        sed -i 's/main/trunk/g' "$file"
        print_success "Updated $file"
    fi
done

# Step 9: Update any CI/CD scripts
print_status "Step 9: Updating CI/CD scripts..."
find . -name "*.sh" -type f | while read -r file; do
    if grep -q "main" "$file" && [ "$file" != "./migrate-to-trunk.sh" ]; then
        print_status "Updating $file branch references..."
        sed -i 's/main/trunk/g' "$file"
        print_success "Updated $file"
    fi
done

# Step 10: Commit all changes
print_status "Step 10: Committing migration changes..."
git add .
if git diff --staged --quiet; then
    print_status "No changes to commit"
else
    git commit -m "🚀 Migrate repository to trunk-only workflow

- Updated GitHub Actions workflows to use trunk branch
- Updated documentation references from main to trunk
- Updated GitOps and ArgoCD configurations
- Updated Backstage catalog configurations
- Updated CI/CD scripts

This migration establishes trunk as the single source of truth branch."
    print_success "Migration changes committed"
fi

# Step 11: Push changes
print_status "Step 11: Pushing migration changes..."
git push origin trunk
print_success "Migration changes pushed to remote"

# Step 12: Cleanup instructions
print_status "Step 12: Cleanup instructions..."
print_warning "After confirming trunk is set as default branch on GitHub:"
print_warning "1. You can safely delete the main branch locally: git branch -d main"
print_warning "2. Delete the main branch on remote: git push origin --delete main"
print_warning "3. Update any external integrations to use trunk branch"

# Final summary
echo ""
print_success "🎉 Migration to trunk-only workflow completed!"
echo ""
print_status "Summary of changes:"
print_status "✅ Switched to trunk branch"
print_status "✅ Updated GitHub Actions workflows"
print_status "✅ Updated documentation references"
print_status "✅ Updated GitOps configurations"
print_status "✅ Updated Backstage catalog configurations"
print_status "✅ Committed and pushed all changes"
echo ""
print_warning "Next steps:"
print_warning "1. Verify trunk is set as default branch on GitHub"
print_warning "2. Test all workflows and integrations"
print_warning "3. Update team documentation about the new branch strategy"
print_warning "4. Clean up old main branch when ready"
echo ""
print_success "Your IA-Ops Platform is now using trunk-only workflow! 🚀"
