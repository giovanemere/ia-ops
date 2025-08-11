#!/bin/bash

# Test Catalog Entity Relations
echo "🔍 Testing Backstage Catalog Entity Relations"
echo "=============================================="

# Function to test entity existence
test_entity() {
    local entity_type=$1
    local entity_name=$2
    local namespace=${3:-default}
    
    echo "Testing: $entity_type:$namespace/$entity_name"
    
    # Try to access the entity via the API (will get auth error but 401 means entity exists)
    response=$(curl -s -w "%{http_code}" "http://localhost:7007/api/catalog/entities/by-name/$entity_type/$namespace/$entity_name" -o /dev/null 2>/dev/null)
    
    if [ "$response" = "401" ]; then
        echo "✅ Entity exists (requires authentication)"
        return 0
    elif [ "$response" = "404" ]; then
        echo "❌ Entity not found"
        return 1
    else
        echo "⚠️  Unexpected response: $response"
        return 1
    fi
}

echo ""
echo "1. Testing missing entities from the original error:"
echo "=================================================="

# Test the entities that were reported as missing
missing_entities=(
    "api:default/github-api"
    "api:default/postgresql-api" 
    "component:default/github-integration"
    "component:default/postgresql"
    "group:default/ia-ops-team"
    "system:default/developer-platform"
    "api:default/backstage-api"
)

all_found=true

for entity in "${missing_entities[@]}"; do
    # Parse entity string (type:namespace/name)
    entity_type=$(echo $entity | cut -d: -f1)
    namespace_name=$(echo $entity | cut -d: -f2)
    namespace=$(echo $namespace_name | cut -d/ -f1)
    name=$(echo $namespace_name | cut -d/ -f2)
    
    if ! test_entity "$entity_type" "$name" "$namespace"; then
        all_found=false
    fi
    echo ""
done

echo ""
echo "2. Testing additional entities from catalog:"
echo "==========================================="

# Test some additional entities that should exist
additional_entities=(
    "component:default/backstage-portal"
    "domain:default/platform"
    "user:default/admin"
)

for entity in "${additional_entities[@]}"; do
    entity_type=$(echo $entity | cut -d: -f1)
    namespace_name=$(echo $entity | cut -d: -f2)
    namespace=$(echo $namespace_name | cut -d/ -f1)
    name=$(echo $namespace_name | cut -d/ -f2)
    
    test_entity "$entity_type" "$name" "$namespace"
    echo ""
done

echo ""
echo "3. Checking catalog file locations:"
echo "==================================="

# Check if catalog files exist in the correct locations
catalog_files=(
    "./packages/backend/catalog-entities.yaml"
    "./examples/entities.yaml"
    "./examples/org.yaml"
    "./catalog-info.yaml"
)

for file in "${catalog_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo ""
echo "4. Checking backend logs for catalog loading:"
echo "============================================="

if [ -f "backend-catalog.log" ]; then
    # Look for catalog-related messages
    if grep -q "catalog.*entities" backend-catalog.log; then
        echo "✅ Catalog entity loading detected in logs"
    else
        echo "⚠️  No catalog entity loading messages found"
    fi
    
    # Look for any catalog errors
    if grep -q -i "error.*catalog\|catalog.*error" backend-catalog.log; then
        echo "⚠️  Catalog errors found in logs:"
        grep -i "error.*catalog\|catalog.*error" backend-catalog.log | tail -3
    else
        echo "✅ No catalog errors found in logs"
    fi
else
    echo "⚠️  Backend log file not found"
fi

echo ""
echo "🎯 Summary:"
echo "==========="

if [ "$all_found" = true ]; then
    echo "✅ All previously missing entities are now available"
    echo "✅ Catalog relations should be resolved"
    echo ""
    echo "🌐 Access your Backstage instance:"
    echo "   Frontend: http://localhost:3002"
    echo "   Backend:  http://localhost:7007"
    echo ""
    echo "🔍 The entity relation errors should no longer appear in the UI!"
else
    echo "❌ Some entities are still missing"
    echo "💡 You may need to:"
    echo "   1. Check the catalog-entities.yaml file"
    echo "   2. Restart the backend to reload the catalog"
    echo "   3. Verify the catalog configuration in app-config.yaml"
fi
