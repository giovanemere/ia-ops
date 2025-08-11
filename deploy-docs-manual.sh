#!/bin/bash

# 🚀 Manual Documentation Deployment Script
# This script manually deploys documentation to GitHub Pages

set -e

echo "🚀 Manual documentation deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if we're in the right directory
if [ ! -f "mkdocs.ci.yml" ]; then
    print_error "mkdocs.ci.yml not found. Are you in the right directory?"
    exit 1
fi

# Check if we're on trunk branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "trunk" ]; then
    print_warning "You're not on trunk branch (current: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled"
        exit 0
    fi
fi

# Check if virtual environment exists
if [ ! -d "venv-docs" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv-docs
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv-docs/bin/activate

# Install dependencies
print_status "Installing MkDocs dependencies..."
pip install --quiet mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Configure git for deployment
print_status "Configuring git for deployment..."
git config user.name "$(git config user.name || echo 'Documentation Bot')"
git config user.email "$(git config user.email || echo 'docs@example.com')"

# Build and deploy
print_status "Building and deploying documentation..."
if mkdocs gh-deploy --config-file mkdocs.ci.yml --force --clean; then
    print_success "✅ Documentation deployed successfully!"
    echo ""
    print_status "📚 Your documentation should be available at:"
    
    # Try to determine GitHub Pages URL
    REMOTE_URL=$(git remote get-url origin)
    if [[ $REMOTE_URL == *"github.com"* ]]; then
        # Extract username and repo name
        if [[ $REMOTE_URL == *".git" ]]; then
            REMOTE_URL=${REMOTE_URL%.git}
        fi
        
        if [[ $REMOTE_URL == *"github.com:"* ]]; then
            # SSH format: git@github.com:user/repo.git
            REPO_PATH=${REMOTE_URL#*github.com:}
        elif [[ $REMOTE_URL == *"github.com/"* ]]; then
            # HTTPS format: https://github.com/user/repo.git
            REPO_PATH=${REMOTE_URL#*github.com/}
        fi
        
        if [ -n "$REPO_PATH" ]; then
            USERNAME=$(echo $REPO_PATH | cut -d'/' -f1)
            REPO_NAME=$(echo $REPO_PATH | cut -d'/' -f2)
            print_status "🔗 https://${USERNAME}.github.io/${REPO_NAME}/"
        fi
    fi
    
    echo ""
    print_status "Note: It may take a few minutes for changes to appear on GitHub Pages"
else
    print_error "❌ Documentation deployment failed!"
    print_status "Check the error messages above for details"
    exit 1
fi

# Clean up
deactivate

print_success "🎉 Manual deployment completed!"
echo ""
print_status "Next steps:"
print_status "1. Wait a few minutes for GitHub Pages to update"
print_status "2. Visit your documentation site to verify changes"
print_status "3. Check GitHub repository → Settings → Pages for deployment status"
