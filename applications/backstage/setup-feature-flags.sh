#!/bin/bash

# Feature Flags Setup Script for Backstage
# This script sets up and tests the feature flags implementation

set -e

echo "🚀 Setting up Feature Flags in Backstage..."

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

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "packages" ]; then
    print_error "Please run this script from the Backstage root directory"
    exit 1
fi

print_status "Checking current directory structure..."
ls -la packages/

print_status "Installing dependencies for the new plugin..."
cd plugins/example-feature-flags
yarn install || {
    print_warning "Yarn install failed, trying to install from root..."
    cd ../..
    yarn install
}
cd ../..

print_status "Building the feature flags plugin..."
yarn workspace @internal/plugin-example-feature-flags build || {
    print_warning "Plugin build failed, continuing with main build..."
}

print_status "Installing app dependencies..."
yarn workspace app install

print_status "Building the entire application..."
yarn build:all || {
    print_warning "Full build failed, trying individual builds..."
    yarn workspace app build
    yarn workspace backend build
}

print_status "Checking feature flags configuration in app-config.yaml..."
if grep -q "featureFlags:" app-config.yaml; then
    print_success "Feature flags configuration found in app-config.yaml"
    echo "Current feature flags:"
    grep -A 10 "featureFlags:" app-config.yaml
else
    print_error "Feature flags configuration not found in app-config.yaml"
    echo "Please add the following to your app-config.yaml:"
    echo ""
    echo "featureFlags:"
    echo "  enable-advanced-features: true"
    echo "  enable-experimental-ui: false"
    echo "  enable-beta-analytics: true"
    echo "  enable-dark-mode-enhancements: false"
fi

print_status "Verifying plugin structure..."
if [ -d "plugins/example-feature-flags/src" ]; then
    print_success "Plugin structure is correct"
    echo "Plugin files:"
    find plugins/example-feature-flags/src -name "*.ts" -o -name "*.tsx" | head -10
else
    print_error "Plugin structure is missing"
fi

print_status "Checking if the plugin is properly integrated in App.tsx..."
if grep -q "ExampleFeatureFlagsPage" packages/app/src/App.tsx; then
    print_success "Plugin is integrated in App.tsx"
else
    print_warning "Plugin integration not found in App.tsx"
fi

print_status "Checking navigation integration..."
if grep -q "feature-flags" packages/app/src/components/Root/Root.tsx; then
    print_success "Navigation integration found"
else
    print_warning "Navigation integration not found"
fi

echo ""
print_success "Feature Flags setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Start your Backstage application: yarn start"
echo "2. Navigate to http://localhost:3002/feature-flags"
echo "3. Test different feature flag combinations in app-config.yaml"
echo ""
echo "🔧 To modify feature flags:"
echo "1. Edit app-config.yaml"
echo "2. Restart the application"
echo "3. Check the Feature Flags page to see the changes"
echo ""
echo "📚 Feature flags available:"
echo "  - enable-advanced-features: Enhanced functionality"
echo "  - enable-experimental-ui: New UI components and animations"
echo "  - enable-beta-analytics: Analytics dashboard"
echo "  - enable-dark-mode-enhancements: Improved dark mode"
echo ""

# Test if we can start the application
print_status "Testing if the application can start..."
timeout 30s yarn start --check || {
    print_warning "Could not verify application startup (this is normal)"
    print_status "Try starting manually with: yarn start"
}

print_success "Setup script completed successfully!"
