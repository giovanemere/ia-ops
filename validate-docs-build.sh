#!/bin/bash

# 📚 Documentation Build Validation Script
# This script validates that the documentation builds correctly

set -e

echo "📚 Validating documentation build..."

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

# Check if virtual environment exists
if [ ! -d "venv-docs" ]; then
    print_warning "venv-docs not found, creating new virtual environment..."
    python3 -m venv venv-docs
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv-docs/bin/activate

# Install dependencies
print_status "Installing MkDocs dependencies..."
pip install --quiet mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Test CI configuration build
print_status "Testing CI configuration build..."
if mkdocs build --config-file mkdocs.ci.yml --clean --quiet; then
    print_success "✅ CI configuration build successful"
else
    print_error "❌ CI configuration build failed"
    exit 1
fi

# Check generated site
if [ -d "site" ]; then
    print_status "📊 Generated site statistics:"
    echo "HTML files: $(find site -name "*.html" | wc -l)"
    echo "CSS files: $(find site -name "*.css" | wc -l)"
    echo "JS files: $(find site -name "*.js" | wc -l)"
    echo "Total size: $(du -sh site | cut -f1)"
    print_success "✅ Documentation site generated successfully"
else
    print_error "❌ No site directory found"
    exit 1
fi

# Validate key pages exist
print_status "Validating key pages..."
key_pages=("index.html" "getting-started/index.html" "architecture/index.html" "api/index.html" "guides/deployment/index.html")

for page in "${key_pages[@]}"; do
    if [ -f "site/$page" ]; then
        print_success "✅ $page exists"
    else
        print_error "❌ $page missing"
        exit 1
    fi
done

# Check for broken internal links (basic check)
print_status "Checking for basic link issues..."
if grep -r "href=\"#\"" site/ > /dev/null 2>&1; then
    print_warning "⚠️ Found empty anchor links"
fi

# Test serve capability (optional)
if [ "$1" = "--test-serve" ]; then
    print_status "🚀 Testing local server (5 seconds)..."
    mkdocs serve --config-file mkdocs.ci.yml &
    SERVER_PID=$!
    sleep 5
    
    if curl -s http://localhost:8000 > /dev/null; then
        print_success "✅ Local server working"
    else
        print_warning "⚠️ Local server test failed"
    fi
    
    kill $SERVER_PID 2>/dev/null || true
fi

# Clean up
print_status "Cleaning up..."
deactivate

print_success "🎉 Documentation validation completed successfully!"
echo ""
print_status "Summary:"
print_status "✅ CI configuration builds without errors"
print_status "✅ All key pages generated"
print_status "✅ Site structure is correct"
print_status "✅ Ready for GitHub Actions deployment"
echo ""
print_status "To test locally: ./validate-docs-build.sh --test-serve"
print_status "To clean build: rm -rf site"
