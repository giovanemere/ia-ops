#!/bin/bash

# 🌳 IA-Ops Platform - Trunk Setup Validation Script
# This script validates that the repository is properly configured for trunk-only workflow

set -e

echo "🌳 Validating trunk-only setup..."

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

# Validation counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to validate and count results
validate_check() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    print_status "Checking: $description"
    
    if eval "$command"; then
        if [ -n "$expected" ]; then
            print_success "$expected"
        else
            print_success "✅ PASSED"
        fi
        ((PASSED++))
    else
        print_error "❌ FAILED: $description"
        ((FAILED++))
    fi
}

# Function to validate with warning
validate_warning() {
    local description="$1"
    local command="$2"
    local warning_msg="$3"
    
    print_status "Checking: $description"
    
    if eval "$command"; then
        print_success "✅ PASSED"
        ((PASSED++))
    else
        print_warning "⚠️ WARNING: $warning_msg"
        ((WARNINGS++))
    fi
}

echo ""
print_status "🔍 Starting trunk-only workflow validation..."
echo ""

# 1. Check current branch
validate_check "Current branch is trunk" \
    '[ "$(git branch --show-current)" = "trunk" ]' \
    "Currently on trunk branch"

# 2. Check if trunk branch exists on remote
validate_check "Trunk branch exists on remote" \
    'git ls-remote --heads origin trunk | grep -q trunk' \
    "Trunk branch found on remote"

# 3. Check GitHub Actions workflows
validate_check "Main CI workflow configured for trunk" \
    'grep -q "branches: \[ trunk \]" .github/workflows/main-ci.yml' \
    "Main CI workflow uses trunk branch"

validate_check "Backstage build workflow configured for trunk" \
    'grep -q "branches: \[trunk\]" .github/workflows/backstage-build.yml' \
    "Backstage build workflow uses trunk branch"

validate_check "Trunk validation workflow exists" \
    '[ -f ".github/workflows/trunk-validation.yml" ]' \
    "Trunk validation workflow found"

# 4. Check for old main branch references in workflows
validate_warning "No main branch references in workflows" \
    '! grep -r "main" .github/workflows/ | grep -v trunk | grep -v migrate-to-trunk' \
    "Found potential main branch references in workflows"

# 5. Check GitOps configurations
if [ -d "gitops" ]; then
    validate_warning "GitOps configurations use trunk" \
        '! find gitops -name "*.yaml" -o -name "*.yml" | xargs grep -l "targetRevision.*main" 2>/dev/null' \
        "Found GitOps configurations still referencing main branch"
else
    print_status "GitOps directory not found - skipping GitOps validation"
fi

# 6. Check Backstage catalog configurations
validate_warning "Backstage catalogs use trunk" \
    '! find . -name "catalog-*.yaml" -o -name "catalog-*.yml" | xargs grep -l "main" 2>/dev/null' \
    "Found Backstage catalog files still referencing main branch"

# 7. Check if main branch still exists locally
validate_warning "Main branch removed locally" \
    '! git show-ref --verify --quiet refs/heads/main' \
    "Main branch still exists locally - consider removing it"

# 8. Check if main branch still exists on remote
validate_warning "Main branch removed on remote" \
    '! git ls-remote --heads origin main | grep -q main' \
    "Main branch still exists on remote - consider removing it"

# 9. Check documentation references
validate_warning "Documentation updated for trunk" \
    '! find docs/ -name "*.md" -type f 2>/dev/null | xargs grep -l "main" | head -1' \
    "Found documentation files with potential main branch references"

# 10. Check migration tools exist
validate_check "Migration script exists" \
    '[ -f "migrate-to-trunk.sh" ]' \
    "Migration script found"

validate_check "Trunk workflow guide exists" \
    '[ -f "docs/TRUNK-WORKFLOW-GUIDE.md" ]' \
    "Trunk workflow guide found"

echo ""
print_status "📊 Validation Summary:"
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "⚠️ Warnings: $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    print_success "🎉 Trunk-only setup validation completed successfully!"
    
    if [ $WARNINGS -gt 0 ]; then
        print_warning "There are $WARNINGS warnings that should be addressed for optimal setup."
    fi
    
    echo ""
    print_status "🚀 Your IA-Ops Platform is ready for trunk-only workflow!"
    echo ""
    print_status "Next steps:"
    print_status "1. Set trunk as default branch on GitHub (if not done already)"
    print_status "2. Update team documentation about the new workflow"
    print_status "3. Remove old main branch when ready"
    print_status "4. Test all workflows and integrations"
    
    exit 0
else
    print_error "❌ Trunk-only setup validation failed with $FAILED errors!"
    print_error "Please fix the errors above before proceeding."
    exit 1
fi
