#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR SECRETOS DE CLOUD PROVIDERS
# =============================================================================
# Ayuda a configurar las variables de entorno para cada proveedor de nube

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

# Función para hacer backup del .env
backup_env() {
    if [ -f ".env" ]; then
        cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
        print_success "Backup creado: .env.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Función para actualizar variable en .env
update_env_var() {
    local var_name=$1
    local var_value=$2
    local env_file=".env"
    
    if grep -q "^${var_name}=" "$env_file"; then
        # Variable existe, actualizarla
        sed -i "s|^${var_name}=.*|${var_name}=${var_value}|" "$env_file"
        print_success "Actualizada: $var_name"
    else
        print_warning "Variable $var_name no encontrada en .env"
    fi
}

# Función para configurar Azure
configure_azure() {
    print_status "🔵 Configurando Microsoft Azure..."
    echo
    
    echo "Para configurar Azure necesitas:"
    echo "1. Una aplicación registrada en Azure AD"
    echo "2. Un Service Principal con permisos"
    echo "3. Una suscripción de Azure activa"
    echo
    
    read -p "¿Deseas configurar Azure ahora? (y/N): " configure_azure_now
    
    if [[ "$configure_azure_now" =~ ^[Yy]$ ]]; then
        echo
        read -p "Azure Client ID: " azure_client_id
        read -p "Azure Client Secret: " azure_client_secret
        read -p "Azure Tenant ID: " azure_tenant_id
        read -p "Azure Subscription ID: " azure_subscription_id
        
        # Opcional
        read -p "Azure DevOps Organization (opcional): " azure_devops_org
        read -p "Azure DevOps Token (opcional): " azure_devops_token
        read -p "Azure Container Registry Name (opcional): " azure_registry_name
        read -p "Azure AKS Cluster Name (opcional): " azure_aks_cluster
        read -p "Azure AKS Resource Group (opcional): " azure_aks_rg
        
        # Actualizar variables
        [ -n "$azure_client_id" ] && update_env_var "AZURE_CLIENT_ID" "$azure_client_id"
        [ -n "$azure_client_secret" ] && update_env_var "AZURE_CLIENT_SECRET" "$azure_client_secret"
        [ -n "$azure_tenant_id" ] && update_env_var "AZURE_TENANT_ID" "$azure_tenant_id"
        [ -n "$azure_subscription_id" ] && update_env_var "AZURE_SUBSCRIPTION_ID" "$azure_subscription_id"
        [ -n "$azure_devops_org" ] && update_env_var "AZURE_DEVOPS_ORG" "$azure_devops_org"
        [ -n "$azure_devops_token" ] && update_env_var "AZURE_DEVOPS_TOKEN" "$azure_devops_token"
        [ -n "$azure_registry_name" ] && update_env_var "AZURE_REGISTRY_NAME" "$azure_registry_name"
        [ -n "$azure_aks_cluster" ] && update_env_var "AZURE_AKS_CLUSTER_NAME" "$azure_aks_cluster"
        [ -n "$azure_aks_rg" ] && update_env_var "AZURE_AKS_RESOURCE_GROUP" "$azure_aks_rg"
        
        if [ -n "$azure_registry_name" ]; then
            update_env_var "AZURE_REGISTRY_URL" "${azure_registry_name}.azurecr.io"
        fi
        
        print_success "Azure configurado correctamente"
    else
        print_status "Saltando configuración de Azure"
    fi
    echo
}

# Función para configurar AWS
configure_aws() {
    print_status "🟠 Configurando Amazon Web Services..."
    echo
    
    echo "Para configurar AWS necesitas:"
    echo "1. Una cuenta de AWS activa"
    echo "2. Un usuario IAM con permisos programáticos"
    echo "3. Access Key ID y Secret Access Key"
    echo
    
    read -p "¿Deseas configurar AWS ahora? (y/N): " configure_aws_now
    
    if [[ "$configure_aws_now" =~ ^[Yy]$ ]]; then
        echo
        read -p "AWS Access Key ID: " aws_access_key_id
        read -p "AWS Secret Access Key: " aws_secret_access_key
        read -p "AWS Default Region [us-east-1]: " aws_region
        aws_region=${aws_region:-us-east-1}
        read -p "AWS Account ID: " aws_account_id
        
        # Opcional
        read -p "AWS EKS Cluster Name (opcional): " aws_eks_cluster
        read -p "AWS S3 Bucket Name (opcional): " aws_s3_bucket
        
        # Actualizar variables
        [ -n "$aws_access_key_id" ] && update_env_var "AWS_ACCESS_KEY_ID" "$aws_access_key_id"
        [ -n "$aws_secret_access_key" ] && update_env_var "AWS_SECRET_ACCESS_KEY" "$aws_secret_access_key"
        [ -n "$aws_region" ] && update_env_var "AWS_DEFAULT_REGION" "$aws_region"
        [ -n "$aws_region" ] && update_env_var "AWS_REGION" "$aws_region"
        [ -n "$aws_account_id" ] && update_env_var "AWS_ACCOUNT_ID" "$aws_account_id"
        [ -n "$aws_eks_cluster" ] && update_env_var "AWS_EKS_CLUSTER_NAME" "$aws_eks_cluster"
        [ -n "$aws_s3_bucket" ] && update_env_var "AWS_S3_BUCKET_NAME" "$aws_s3_bucket"
        
        if [ -n "$aws_account_id" ] && [ -n "$aws_region" ]; then
            update_env_var "AWS_ECR_REGISTRY_URL" "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"
        fi
        
        print_success "AWS configurado correctamente"
    else
        print_status "Saltando configuración de AWS"
    fi
    echo
}

# Función para configurar GCP
configure_gcp() {
    print_status "🟢 Configurando Google Cloud Platform..."
    echo
    
    echo "Para configurar GCP necesitas:"
    echo "1. Un proyecto de Google Cloud activo"
    echo "2. Una cuenta de servicio con permisos"
    echo "3. Un archivo de clave JSON de la cuenta de servicio"
    echo
    
    read -p "¿Deseas configurar GCP ahora? (y/N): " configure_gcp_now
    
    if [[ "$configure_gcp_now" =~ ^[Yy]$ ]]; then
        echo
        read -p "GCP Project ID: " gcp_project_id
        read -p "GCP Service Account Email: " gcp_sa_email
        read -p "Path al archivo de clave JSON: " gcp_key_file
        read -p "GCP Region [us-central1]: " gcp_region
        gcp_region=${gcp_region:-us-central1}
        
        # Opcional
        read -p "GKE Cluster Name (opcional): " gcp_gke_cluster
        read -p "GCS Bucket Name (opcional): " gcp_storage_bucket
        
        # Verificar que el archivo de clave existe
        if [ -n "$gcp_key_file" ] && [ ! -f "$gcp_key_file" ]; then
            print_warning "Archivo de clave no encontrado: $gcp_key_file"
            read -p "¿Continuar de todas formas? (y/N): " continue_gcp
            if [[ ! "$continue_gcp" =~ ^[Yy]$ ]]; then
                print_status "Saltando configuración de GCP"
                return
            fi
        fi
        
        # Actualizar variables
        [ -n "$gcp_project_id" ] && update_env_var "GCP_PROJECT_ID" "$gcp_project_id"
        [ -n "$gcp_sa_email" ] && update_env_var "GCP_SERVICE_ACCOUNT_EMAIL" "$gcp_sa_email"
        [ -n "$gcp_key_file" ] && update_env_var "GCP_SERVICE_ACCOUNT_KEY_FILE" "$gcp_key_file"
        [ -n "$gcp_key_file" ] && update_env_var "GOOGLE_APPLICATION_CREDENTIALS" "$gcp_key_file"
        [ -n "$gcp_region" ] && update_env_var "GCP_REGION" "$gcp_region"
        [ -n "$gcp_gke_cluster" ] && update_env_var "GCP_GKE_CLUSTER_NAME" "$gcp_gke_cluster"
        [ -n "$gcp_storage_bucket" ] && update_env_var "GCP_STORAGE_BUCKET" "$gcp_storage_bucket"
        
        if [ -n "$gcp_project_id" ]; then
            update_env_var "GCP_GCR_PROJECT_ID" "$gcp_project_id"
            update_env_var "GCP_CLOUDBUILD_PROJECT_ID" "$gcp_project_id"
        fi
        
        print_success "GCP configurado correctamente"
    else
        print_status "Saltando configuración de GCP"
    fi
    echo
}

# Función para configurar OCI
configure_oci() {
    print_status "🔴 Configurando Oracle Cloud Infrastructure..."
    echo
    
    echo "Para configurar OCI necesitas:"
    echo "1. Una cuenta de Oracle Cloud activa"
    echo "2. Un usuario con permisos de API"
    echo "3. Un par de claves RSA para autenticación"
    echo
    
    read -p "¿Deseas configurar OCI ahora? (y/N): " configure_oci_now
    
    if [[ "$configure_oci_now" =~ ^[Yy]$ ]]; then
        echo
        read -p "OCI User OCID: " oci_user_id
        read -p "OCI Tenancy OCID: " oci_tenancy_id
        read -p "OCI Key Fingerprint: " oci_fingerprint
        read -p "Path a la clave privada: " oci_private_key_path
        read -p "OCI Region [us-ashburn-1]: " oci_region
        oci_region=${oci_region:-us-ashburn-1}
        read -p "OCI Compartment OCID: " oci_compartment_id
        
        # Opcional
        read -p "OKE Cluster Name (opcional): " oci_oke_cluster
        read -p "Object Storage Bucket (opcional): " oci_storage_bucket
        
        # Verificar que el archivo de clave existe
        if [ -n "$oci_private_key_path" ] && [ ! -f "$oci_private_key_path" ]; then
            print_warning "Archivo de clave privada no encontrado: $oci_private_key_path"
            read -p "¿Continuar de todas formas? (y/N): " continue_oci
            if [[ ! "$continue_oci" =~ ^[Yy]$ ]]; then
                print_status "Saltando configuración de OCI"
                return
            fi
        fi
        
        # Actualizar variables
        [ -n "$oci_user_id" ] && update_env_var "OCI_USER_ID" "$oci_user_id"
        [ -n "$oci_tenancy_id" ] && update_env_var "OCI_TENANCY_ID" "$oci_tenancy_id"
        [ -n "$oci_fingerprint" ] && update_env_var "OCI_FINGERPRINT" "$oci_fingerprint"
        [ -n "$oci_private_key_path" ] && update_env_var "OCI_PRIVATE_KEY_PATH" "$oci_private_key_path"
        [ -n "$oci_region" ] && update_env_var "OCI_REGION" "$oci_region"
        [ -n "$oci_compartment_id" ] && update_env_var "OCI_COMPARTMENT_ID" "$oci_compartment_id"
        [ -n "$oci_oke_cluster" ] && update_env_var "OCI_OKE_CLUSTER_NAME" "$oci_oke_cluster"
        [ -n "$oci_storage_bucket" ] && update_env_var "OCI_OBJECT_STORAGE_BUCKET" "$oci_storage_bucket"
        
        if [ -n "$oci_tenancy_id" ]; then
            update_env_var "OCI_ROOT_COMPARTMENT_ID" "$oci_tenancy_id"
        fi
        
        print_success "OCI configurado correctamente"
    else
        print_status "Saltando configuración de OCI"
    fi
    echo
}

# Función para mostrar resumen
show_summary() {
    print_status "📊 Resumen de configuración:"
    echo
    
    # Verificar Azure
    if grep -q "^AZURE_CLIENT_ID=your-azure-client-id" .env; then
        print_warning "Azure: No configurado"
    else
        print_success "Azure: Configurado"
    fi
    
    # Verificar AWS
    if grep -q "^AWS_ACCESS_KEY_ID=your-aws-access-key-id" .env; then
        print_warning "AWS: No configurado"
    else
        print_success "AWS: Configurado"
    fi
    
    # Verificar GCP
    if grep -q "^GCP_PROJECT_ID=your-gcp-project-id" .env; then
        print_warning "GCP: No configurado"
    else
        print_success "GCP: Configurado"
    fi
    
    # Verificar OCI
    if grep -q "^OCI_USER_ID=ocid1.user.oc1..your-user-ocid" .env; then
        print_warning "OCI: No configurado"
    else
        print_success "OCI: Configurado"
    fi
    
    echo
    print_status "Para validar la configuración ejecuta:"
    print_status "./scripts/validate-cloud-config.sh"
}

# Función principal
main() {
    print_status "=== CONFIGURACIÓN DE SECRETOS DE CLOUD PROVIDERS ==="
    echo
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f ".env" ]; then
        print_error "Archivo .env no encontrado. Ejecuta desde el directorio raíz del proyecto."
        exit 1
    fi
    
    # Hacer backup
    backup_env
    
    # Menú de opciones
    echo "Selecciona los proveedores a configurar:"
    echo "1) Microsoft Azure"
    echo "2) Amazon Web Services (AWS)"
    echo "3) Google Cloud Platform (GCP)"
    echo "4) Oracle Cloud Infrastructure (OCI)"
    echo "5) Todos los proveedores"
    echo "6) Mostrar resumen"
    echo "7) Salir"
    echo
    
    read -p "Opción [1-7]: " choice
    
    case $choice in
        1) configure_azure ;;
        2) configure_aws ;;
        3) configure_gcp ;;
        4) configure_oci ;;
        5) 
            configure_azure
            configure_aws
            configure_gcp
            configure_oci
            ;;
        6) show_summary ;;
        7) exit 0 ;;
        *) print_error "Opción inválida" ;;
    esac
    
    show_summary
    
    echo
    print_success "Configuración completada"
    print_status "Recuerda reiniciar Backstage para aplicar los cambios:"
    print_status "docker restart ia-ops-backstage"
}

# Ejecutar función principal
main
