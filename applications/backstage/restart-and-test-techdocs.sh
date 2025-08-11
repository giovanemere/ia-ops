#!/bin/bash

# Script to restart Backstage and test TechDocs generation
# This script fixes the GitHub repository issues and tests documentation

echo "🚀 IA-OPS Backstage TechDocs Fix and Restart"
echo "=============================================="

# Set working directory
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

echo "📋 Step 1: Checking current processes..."
BACKSTAGE_PID=$(ps aux | grep -E "(backstage|node.*7007)" | grep -v grep | awk '{print $2}')
if [ ! -z "$BACKSTAGE_PID" ]; then
    echo "🔄 Stopping existing Backstage process (PID: $BACKSTAGE_PID)..."
    kill $BACKSTAGE_PID
    sleep 3
fi

echo "📋 Step 2: Testing MkDocs builds..."

# Test examples directory
echo "🔍 Testing examples documentation..."
cd examples
if mkdocs build --quiet; then
    echo "✅ Examples documentation builds successfully"
else
    echo "❌ Examples documentation build failed"
fi

# Test main Backstage documentation
echo "🔍 Testing main Backstage documentation..."
cd ..
if mkdocs build --quiet; then
    echo "✅ Main Backstage documentation builds successfully"
else
    echo "❌ Main Backstage documentation build failed"
fi

echo "📋 Step 3: Syncing environment variables..."
if [ -f "../../.env" ]; then
    echo "✅ Environment file found"
    # Source environment variables
    set -a
    source ../../.env
    set +a
    echo "✅ Environment variables loaded"
else
    echo "❌ Environment file not found at ../../.env"
    exit 1
fi

echo "📋 Step 4: Testing GitHub token..."
if [ ! -z "$GITHUB_TOKEN" ]; then
    GITHUB_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
    if echo "$GITHUB_RESPONSE" | grep -q "login"; then
        GITHUB_USER=$(echo "$GITHUB_RESPONSE" | grep -o '"login":"[^"]*' | cut -d'"' -f4)
        echo "✅ GitHub token is valid (User: $GITHUB_USER)"
    else
        echo "❌ GitHub token is invalid or expired"
        echo "Response: $GITHUB_RESPONSE"
    fi
else
    echo "⚠️  No GitHub token configured"
fi

echo "📋 Step 5: Cleaning build artifacts..."
rm -rf site examples/site node_modules/.cache 2>/dev/null
echo "✅ Build artifacts cleaned"

echo "📋 Step 6: Installing/updating dependencies..."
if yarn install --silent; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "📋 Step 7: Starting Backstage..."
echo "🌐 Frontend will be available at: http://localhost:3002"
echo "🔧 Backend will be available at: http://localhost:7007"
echo "📚 TechDocs will be available at: http://localhost:7007/docs"
echo ""
echo "📝 Note: The GitHub repository 'ia-ops/ia-ops' reference has been removed"
echo "📝 TechDocs will now use local documentation only"
echo ""
echo "🔄 Starting in development mode..."

# Start Backstage
yarn start

echo "🏁 Backstage startup completed!"
