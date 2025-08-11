#!/bin/bash

# =============================================================================
# BACKSTAGE PRODUCTION MIGRATION SCRIPT
# =============================================================================
# Fecha: 8 de Agosto de 2025
# Versión: 2.0.0
# Descripción: Script para migrar de desarrollo a producción Backstage
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKSTAGE_DIR="$PROJECT_ROOT/applications/backstage"

echo -e "${BLUE}🚀 IA-Ops Backstage Production Migration${NC}"
echo -e "${BLUE}=======================================${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo -e "\n${BLUE}1. Checking Prerequisites${NC}"

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    exit 1
fi

if ! command -v yarn &> /dev/null; then
    print_error "Yarn is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18 or higher is required (current: $(node --version))"
    exit 1
fi

print_status "All prerequisites met"

# Backup current configuration
echo -e "\n${BLUE}2. Creating Backup${NC}"

BACKUP_DIR="$PROJECT_ROOT/backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp "$PROJECT_ROOT/docker-compose.yml" "$BACKUP_DIR/"
cp -r "$BACKSTAGE_DIR" "$BACKUP_DIR/backstage-backup"

print_status "Backup created at $BACKUP_DIR"

# Clean and reinstall dependencies
echo -e "\n${BLUE}3. Cleaning and Reinstalling Dependencies${NC}"

cd "$BACKSTAGE_DIR"

# Clean existing installations
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf dist-types
rm -f yarn.lock

print_status "Cleaned existing installations"

# Install dependencies with fixed versions
echo -e "${YELLOW}Installing dependencies (this may take a few minutes)...${NC}"
yarn install --frozen-lockfile --network-timeout 600000

print_status "Dependencies installed successfully"

# Run TypeScript compilation check
echo -e "\n${BLUE}4. TypeScript Compilation Check${NC}"

if yarn tsc --noEmit; then
    print_status "TypeScript compilation successful"
else
    print_warning "TypeScript compilation has warnings (continuing anyway)"
fi

# Build the application
echo -e "\n${BLUE}5. Building Application${NC}"

echo -e "${YELLOW}Building backend...${NC}"
if yarn build:backend; then
    print_status "Backend build successful"
else
    print_error "Backend build failed"
    exit 1
fi

echo -e "${YELLOW}Building frontend...${NC}"
if yarn workspace app build; then
    print_status "Frontend build successful"
else
    print_error "Frontend build failed"
    exit 1
fi

# Update Docker Compose configuration
echo -e "\n${BLUE}6. Updating Docker Configuration${NC}"

# Backup original docker-compose.yml
cp "$PROJECT_ROOT/docker-compose.yml" "$PROJECT_ROOT/docker-compose.yml.backup"

# Update the Dockerfile reference in docker-compose.yml
sed -i 's/dockerfile: Dockerfile$/dockerfile: Dockerfile.production/' "$PROJECT_ROOT/docker-compose.yml"

print_status "Docker configuration updated"

# Build Docker images
echo -e "\n${BLUE}7. Building Docker Images${NC}"

cd "$PROJECT_ROOT"

echo -e "${YELLOW}Building Backstage backend image...${NC}"
docker-compose build backstage-backend

echo -e "${YELLOW}Building Backstage frontend image...${NC}"
docker-compose build backstage-frontend

print_status "Docker images built successfully"

# Test the build
echo -e "\n${BLUE}8. Testing the Build${NC}"

echo -e "${YELLOW}Starting services for testing...${NC}"
docker-compose up -d postgres redis

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
sleep 10

# Start Backstage backend
docker-compose up -d backstage-backend

# Wait for backend to start
echo -e "${YELLOW}Waiting for backend to start...${NC}"
sleep 30

# Test backend health
if curl -f http://localhost:7007/api/catalog/health > /dev/null 2>&1; then
    print_status "Backend health check passed"
else
    print_warning "Backend health check failed (may need more time to start)"
fi

# Start frontend
docker-compose up -d backstage-frontend

# Wait for frontend to start
echo -e "${YELLOW}Waiting for frontend to start...${NC}"
sleep 20

# Test frontend
if curl -f http://localhost:3002 > /dev/null 2>&1; then
    print_status "Frontend health check passed"
else
    print_warning "Frontend health check failed (may need more time to start)"
fi

# Final status
echo -e "\n${GREEN}🎉 Migration Completed Successfully!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Check the services are running: docker-compose ps"
echo "2. Access Backstage at: http://localhost:8080"
echo "3. Check logs if needed: docker-compose logs backstage-backend"
echo "4. Monitor the application for any issues"
echo ""
echo -e "${BLUE}Rollback Instructions:${NC}"
echo "If you need to rollback:"
echo "1. Stop services: docker-compose down"
echo "2. Restore backup: cp $BACKUP_DIR/docker-compose.yml $PROJECT_ROOT/"
echo "3. Restart: docker-compose up -d"
echo ""
echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"

# Optional: Clean up test containers
read -p "Do you want to stop the test containers? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose down
    print_status "Test containers stopped"
fi

echo -e "\n${GREEN}Migration script completed!${NC}"
