#!/bin/bash

# =============================================================================
# SCRIPT DE CONFIGURACIÓN - CLOUD PROVIDERS
# =============================================================================
# Configura Azure, AWS, GCP y OCI en Backstage

set -e

# Colores para output
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

print_status "=== CONFIGURACIÓN DE CLOUD PROVIDERS ==="
echo

# Verificar que estamos en el directorio correcto
if [ ! -f ".env" ]; then
    print_error "Archivo .env no encontrado. Ejecuta desde el directorio raíz del proyecto."
    exit 1
fi

# Cargar variables de entorno
source .env

# Función para configurar Azure
setup_azure() {
    print_status "🔵 Configurando Microsoft Azure..."
    
    echo "Para configurar Azure, necesitas:"
    echo "1. Una aplicación registrada en Azure AD"
    echo "2. Un Service Principal con permisos adecuados"
    echo "3. Una suscripción de Azure activa"
    echo
    
    read -p "¿Tienes una aplicación de Azure AD configurada? (y/N): " has_azure_app
    
    if [[ "$has_azure_app" =~ ^[Yy]$ ]]; then
        echo "Configura estas variables en tu archivo .env:"
        echo "AZURE_CLIENT_ID=tu-client-id"
        echo "AZURE_CLIENT_SECRET=tu-client-secret"
        echo "AZURE_TENANT_ID=tu-tenant-id"
        echo "AZURE_SUBSCRIPTION_ID=tu-subscription-id"
        echo
        print_success "Azure configurado (variables pendientes)"
    else
        print_warning "Para configurar Azure:"
        echo "1. Ve a https://portal.azure.com"
        echo "2. Registra una nueva aplicación en Azure AD"
        echo "3. Crea un Service Principal"
        echo "4. Asigna permisos de Contributor a la suscripción"
        echo "5. Actualiza las variables en .env"
    fi
}

# Función para configurar AWS
setup_aws() {
    print_status "🟠 Configurando Amazon Web Services..."
    
    echo "Para configurar AWS, necesitas:"
    echo "1. Una cuenta de AWS activa"
    echo "2. Un usuario IAM con permisos programáticos"
    echo "3. Access Key ID y Secret Access Key"
    echo
    
    read -p "¿Tienes credenciales de AWS configuradas? (y/N): " has_aws_creds
    
    if [[ "$has_aws_creds" =~ ^[Yy]$ ]]; then
        echo "Configura estas variables en tu archivo .env:"
        echo "AWS_ACCESS_KEY_ID=tu-access-key-id"
        echo "AWS_SECRET_ACCESS_KEY=tu-secret-access-key"
        echo "AWS_DEFAULT_REGION=us-east-1"
        echo "AWS_ACCOUNT_ID=tu-account-id"
        echo
        print_success "AWS configurado (variables pendientes)"
    else
        print_warning "Para configurar AWS:"
        echo "1. Ve a https://console.aws.amazon.com/iam/"
        echo "2. Crea un nuevo usuario IAM"
        echo "3. Asigna políticas: PowerUserAccess o permisos específicos"
        echo "4. Genera Access Keys"
        echo "5. Actualiza las variables en .env"
    fi
}

# Función para configurar GCP
setup_gcp() {
    print_status "🟢 Configurando Google Cloud Platform..."
    
    echo "Para configurar GCP, necesitas:"
    echo "1. Un proyecto de Google Cloud activo"
    echo "2. Una cuenta de servicio con permisos adecuados"
    echo "3. Un archivo de clave JSON de la cuenta de servicio"
    echo
    
    read -p "¿Tienes una cuenta de servicio de GCP configurada? (y/N): " has_gcp_sa
    
    if [[ "$has_gcp_sa" =~ ^[Yy]$ ]]; then
        echo "Configura estas variables en tu archivo .env:"
        echo "GCP_PROJECT_ID=tu-project-id"
        echo "GCP_SERVICE_ACCOUNT_EMAIL=backstage@tu-project.iam.gserviceaccount.com"
        echo "GCP_SERVICE_ACCOUNT_KEY_FILE=/path/to/service-account-key.json"
        echo "GCP_REGION=us-central1"
        echo
        print_success "GCP configurado (variables pendientes)"
    else
        print_warning "Para configurar GCP:"
        echo "1. Ve a https://console.cloud.google.com/iam-admin/serviceaccounts"
        echo "2. Crea una nueva cuenta de servicio"
        echo "3. Asigna roles: Editor o permisos específicos"
        echo "4. Genera y descarga la clave JSON"
        echo "5. Actualiza las variables en .env"
    fi
}

# Función para configurar OCI
setup_oci() {
    print_status "🔴 Configurando Oracle Cloud Infrastructure..."
    
    echo "Para configurar OCI, necesitas:"
    echo "1. Una cuenta de Oracle Cloud activa"
    echo "2. Un usuario con permisos de API"
    echo "3. Un par de claves RSA para autenticación"
    echo
    
    read -p "¿Tienes credenciales de OCI configuradas? (y/N): " has_oci_creds
    
    if [[ "$has_oci_creds" =~ ^[Yy]$ ]]; then
        echo "Configura estas variables en tu archivo .env:"
        echo "OCI_USER_ID=ocid1.user.oc1..tu-user-ocid"
        echo "OCI_TENANCY_ID=ocid1.tenancy.oc1..tu-tenancy-ocid"
        echo "OCI_FINGERPRINT=tu-key-fingerprint"
        echo "OCI_PRIVATE_KEY_PATH=/path/to/oci-private-key.pem"
        echo "OCI_REGION=us-ashburn-1"
        echo
        print_success "OCI configurado (variables pendientes)"
    else
        print_warning "Para configurar OCI:"
        echo "1. Ve a https://cloud.oracle.com/identity/users"
        echo "2. Crea o selecciona un usuario"
        echo "3. Genera un par de claves API"
        echo "4. Agrega la clave pública al usuario"
        echo "5. Actualiza las variables en .env"
    fi
}

# Función para generar archivos de configuración
generate_configs() {
    print_status "📝 Generando archivos de configuración..."
    
    # Crear directorio de configuración si no existe
    mkdir -p config/cloud-providers
    
    # Generar configuración específica para cada proveedor
    cat > config/cloud-providers/azure.yaml << 'EOF'
# Azure-specific configuration
azure:
  resourceDiscovery:
    enabled: true
    subscriptions:
      - ${AZURE_SUBSCRIPTION_ID}
    resourceGroups:
      - ${AZURE_AKS_RESOURCE_GROUP}
  
  monitoring:
    applicationInsights:
      enabled: true
      instrumentationKey: ${AZURE_APPLICATION_INSIGHTS_KEY}
  
  security:
    securityCenter:
      enabled: true
      assessments: true
      alerts: true
EOF

    cat > config/cloud-providers/aws.yaml << 'EOF'
# AWS-specific configuration
aws:
  resourceDiscovery:
    enabled: true
    regions:
      - ${AWS_DEFAULT_REGION}
      - us-west-2
    services:
      - ec2
      - rds
      - s3
      - lambda
      - eks
  
  monitoring:
    cloudWatch:
      enabled: true
      metrics: true
      logs: true
  
  security:
    securityHub:
      enabled: true
      findings: true
      insights: true
EOF

    cat > config/cloud-providers/gcp.yaml << 'EOF'
# GCP-specific configuration
gcp:
  resourceDiscovery:
    enabled: true
    projects:
      - ${GCP_PROJECT_ID}
    regions:
      - ${GCP_REGION}
    services:
      - compute
      - sql
      - storage
      - functions
      - gke
  
  monitoring:
    stackdriver:
      enabled: true
      metrics: true
      logs: true
  
  security:
    securityCommandCenter:
      enabled: true
      findings: true
      assets: true
EOF

    cat > config/cloud-providers/oci.yaml << 'EOF'
# OCI-specific configuration
oci:
  resourceDiscovery:
    enabled: true
    compartments:
      - ${OCI_COMPARTMENT_ID}
    regions:
      - ${OCI_REGION}
    services:
      - compute
      - database
      - objectstorage
      - functions
      - oke
  
  monitoring:
    enabled: true
    metrics: true
    logs: true
  
  security:
    cloudGuard:
      enabled: true
      detectors: true
      problems: true
EOF

    print_success "Archivos de configuración generados en config/cloud-providers/"
}

# Función para instalar dependencias de cloud providers
install_dependencies() {
    print_status "📦 Instalando dependencias de cloud providers..."
    
    # Verificar si estamos en un contenedor de Backstage
    if docker ps | grep -q ia-ops-backstage; then
        print_status "Instalando dependencias en el contenedor de Backstage..."
        
        docker exec ia-ops-backstage bash -c "
            cd /app/backstage-app && \
            yarn add @backstage/plugin-azure-devops \
                     @backstage/plugin-aws-apps \
                     @backstage/plugin-gcp-projects \
                     @backstage/plugin-kubernetes \
                     @backstage/plugin-cost-insights \
                     @azure/msal-node \
                     aws-sdk \
                     @google-cloud/resource-manager \
                     oci-sdk
        " 2>/dev/null || print_warning "No se pudieron instalar las dependencias automáticamente"
    else
        print_warning "Contenedor de Backstage no encontrado. Instala manualmente:"
        echo "yarn add @backstage/plugin-azure-devops"
        echo "yarn add @backstage/plugin-aws-apps"
        echo "yarn add @backstage/plugin-gcp-projects"
        echo "yarn add @backstage/plugin-kubernetes"
        echo "yarn add @backstage/plugin-cost-insights"
    fi
}

# Función para validar configuración
validate_config() {
    print_status "✅ Validando configuración..."
    
    local errors=0
    
    # Validar Azure
    if [ -n "$AZURE_CLIENT_ID" ] && [ -n "$AZURE_CLIENT_SECRET" ]; then
        print_success "Azure: Variables básicas configuradas"
    else
        print_warning "Azure: Variables faltantes"
        ((errors++))
    fi
    
    # Validar AWS
    if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
        print_success "AWS: Variables básicas configuradas"
    else
        print_warning "AWS: Variables faltantes"
        ((errors++))
    fi
    
    # Validar GCP
    if [ -n "$GCP_PROJECT_ID" ] && [ -n "$GCP_SERVICE_ACCOUNT_EMAIL" ]; then
        print_success "GCP: Variables básicas configuradas"
    else
        print_warning "GCP: Variables faltantes"
        ((errors++))
    fi
    
    # Validar OCI
    if [ -n "$OCI_USER_ID" ] && [ -n "$OCI_TENANCY_ID" ]; then
        print_success "OCI: Variables básicas configuradas"
    else
        print_warning "OCI: Variables faltantes"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "Todos los proveedores tienen configuración básica"
    else
        print_warning "$errors proveedores necesitan configuración adicional"
    fi
}

# Menú principal
show_menu() {
    echo "Selecciona los proveedores a configurar:"
    echo "1) Microsoft Azure"
    echo "2) Amazon Web Services (AWS)"
    echo "3) Google Cloud Platform (GCP)"
    echo "4) Oracle Cloud Infrastructure (OCI)"
    echo "5) Todos los proveedores"
    echo "6) Generar archivos de configuración"
    echo "7) Instalar dependencias"
    echo "8) Validar configuración"
    echo "9) Salir"
    echo
    read -p "Opción: " choice
    
    case $choice in
        1) setup_azure ;;
        2) setup_aws ;;
        3) setup_gcp ;;
        4) setup_oci ;;
        5) setup_azure && setup_aws && setup_gcp && setup_oci ;;
        6) generate_configs ;;
        7) install_dependencies ;;
        8) validate_config ;;
        9) exit 0 ;;
        *) print_error "Opción inválida" ;;
    esac
}

# Ejecutar menú
while true; do
    show_menu
    echo
    read -p "¿Deseas continuar? (y/N): " continue_setup
    if [[ ! "$continue_setup" =~ ^[Yy]$ ]]; then
        break
    fi
    echo
done

print_success "Configuración de cloud providers completada"
print_status "Recuerda actualizar las variables en .env con tus credenciales reales"
print_status "Documentación disponible en:"
print_status "- Azure: https://backstage.io/docs/integrations/azure/discovery"
print_status "- AWS: https://backstage.io/docs/integrations/aws-s3/discovery"
print_status "- GCP: https://backstage.io/docs/integrations/google-gcs/discovery"
print_status "- Kubernetes: https://backstage.io/docs/features/kubernetes/"
