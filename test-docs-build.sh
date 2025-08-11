#!/bin/bash

# 📚 Test Documentation Build Script
# This script tests the MkDocs build process locally

set -e

echo "📚 Testing MkDocs documentation build..."

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

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed"
    exit 1
fi

print_status "Python version: $(python3 --version)"

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    print_error "pip3 is not installed"
    exit 1
fi

# Install MkDocs dependencies
print_status "Installing MkDocs dependencies..."
pip3 install --user mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Test CI configuration build
if [ -f "mkdocs.ci.yml" ]; then
    print_status "Testing build with CI configuration..."
    if mkdocs build --config-file mkdocs.ci.yml --clean; then
        print_success "✅ CI configuration build successful"
    else
        print_error "❌ CI configuration build failed"
        exit 1
    fi
else
    print_warning "mkdocs.ci.yml not found"
fi

# Test default configuration build (with fallback)
if [ -f "mkdocs.yml" ]; then
    print_status "Testing build with default configuration..."
    
    # Try building with default config
    if mkdocs build --clean 2>&1 | grep -q "techdocs-core"; then
        print_warning "techdocs-core plugin not available, creating temporary config..."
        
        # Create temporary config without techdocs-core
        sed 's/- techdocs-core/# - techdocs-core (disabled for testing)/' mkdocs.yml > mkdocs.temp.yml
        
        if mkdocs build --config-file mkdocs.temp.yml --clean; then
            print_success "✅ Default configuration build successful (without techdocs-core)"
            rm mkdocs.temp.yml
        else
            print_error "❌ Default configuration build failed"
            rm mkdocs.temp.yml
            exit 1
        fi
    else
        if mkdocs build --clean; then
            print_success "✅ Default configuration build successful"
        else
            print_error "❌ Default configuration build failed"
            exit 1
        fi
    fi
else
    print_warning "mkdocs.yml not found"
fi

# Check generated site
if [ -d "site" ]; then
    print_status "📊 Generated site structure:"
    find site -type f -name "*.html" | head -10
    
    print_status "📈 Site statistics:"
    echo "HTML files: $(find site -name "*.html" | wc -l)"
    echo "CSS files: $(find site -name "*.css" | wc -l)"
    echo "JS files: $(find site -name "*.js" | wc -l)"
    echo "Total size: $(du -sh site | cut -f1)"
    
    print_success "✅ Documentation site generated successfully"
else
    print_error "❌ No site directory found"
    exit 1
fi

# Test serve (optional)
if [ "$1" = "--serve" ]; then
    print_status "🚀 Starting local server..."
    print_status "Documentation will be available at: http://localhost:8000"
    print_status "Press Ctrl+C to stop the server"
    
    if [ -f "mkdocs.ci.yml" ]; then
        mkdocs serve --config-file mkdocs.ci.yml
    else
        mkdocs serve
    fi
fi

print_success "🎉 Documentation build test completed successfully!"
echo ""
print_status "To serve locally: ./test-docs-build.sh --serve"
print_status "To clean build: rm -rf site"
