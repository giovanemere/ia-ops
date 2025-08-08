#!/bin/bash

# =============================================================================
# SCRIPT DE VALIDACIÓN - CLOUD PROVIDERS
# =============================================================================
# Valida la configuración de Azure, AWS, GCP y OCI

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

# Cargar variables de entorno
if [ -f ".env" ]; then
    source .env
else
    print_error "Archivo .env no encontrado"
    exit 1
fi

print_status "=== VALIDACIÓN DE CLOUD PROVIDERS ==="
echo

errors=0
warnings=0

# Función para validar Azure
validate_azure() {
    print_status "🔵 Validando Microsoft Azure..."
    
    local azure_errors=0
    
    # Verificar variables básicas
    if [ -z "$AZURE_CLIENT_ID" ]; then
        print_error "AZURE_CLIENT_ID no está definida"
        ((azure_errors++))
    else
        print_success "AZURE_CLIENT_ID está definida"
    fi
    
    if [ -z "$AZURE_CLIENT_SECRET" ]; then
        print_error "AZURE_CLIENT_SECRET no está definida"
        ((azure_errors++))
    else
        print_success "AZURE_CLIENT_SECRET está definida"
    fi
    
    if [ -z "$AZURE_TENANT_ID" ]; then
        print_error "AZURE_TENANT_ID no está definida"
        ((azure_errors++))
    else
        print_success "AZURE_TENANT_ID está definida"
    fi
    
    if [ -z "$AZURE_SUBSCRIPTION_ID" ]; then
        print_error "AZURE_SUBSCRIPTION_ID no está definida"
        ((azure_errors++))
    else
        print_success "AZURE_SUBSCRIPTION_ID está definida"
    fi
    
    # Verificar formato de IDs
    if [ -n "$AZURE_TENANT_ID" ] && [[ ! "$AZURE_TENANT_ID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        print_warning "AZURE_TENANT_ID no tiene formato UUID válido"
        ((warnings++))
    fi
    
    # Probar conectividad (si curl está disponible)
    if command -v curl &> /dev/null && [ -n "$AZURE_CLIENT_ID" ] && [ -n "$AZURE_CLIENT_SECRET" ] && [ -n "$AZURE_TENANT_ID" ]; then
        print_status "Probando autenticación con Azure AD..."
        
        local token_response=$(curl -s -X POST \
            "https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/v2.0/token" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "client_id=$AZURE_CLIENT_ID&client_secret=$AZURE_CLIENT_SECRET&scope=https://management.azure.com/.default&grant_type=client_credentials" 2>/dev/null)
        
        if echo "$token_response" | grep -q "access_token"; then
            print_success "Autenticación con Azure AD exitosa"
        else
            print_error "Fallo en autenticación con Azure AD"
            ((azure_errors++))
        fi
    fi
    
    if [ $azure_errors -eq 0 ]; then
        print_success "✅ Azure configurado correctamente"
    else
        print_error "❌ Azure tiene $azure_errors errores"
        ((errors += azure_errors))
    fi
    
    echo
}

# Función para validar AWS
validate_aws() {
    print_status "🟠 Validando Amazon Web Services..."
    
    local aws_errors=0
    
    # Verificar variables básicas
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        print_error "AWS_ACCESS_KEY_ID no está definida"
        ((aws_errors++))
    else
        print_success "AWS_ACCESS_KEY_ID está definida"
    fi
    
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        print_error "AWS_SECRET_ACCESS_KEY no está definida"
        ((aws_errors++))
    else
        print_success "AWS_SECRET_ACCESS_KEY está definida"
    fi
    
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        print_warning "AWS_DEFAULT_REGION no está definida, usando us-east-1"
        ((warnings++))
    else
        print_success "AWS_DEFAULT_REGION está definida: $AWS_DEFAULT_REGION"
    fi
    
    # Verificar formato de Access Key
    if [ -n "$AWS_ACCESS_KEY_ID" ] && [[ ! "$AWS_ACCESS_KEY_ID" =~ ^AKIA[0-9A-Z]{16}$ ]] && [[ ! "$AWS_ACCESS_KEY_ID" =~ ^ASIA[0-9A-Z]{16}$ ]]; then
        print_warning "AWS_ACCESS_KEY_ID no tiene formato estándar de AWS"
        ((warnings++))
    fi
    
    # Probar conectividad con AWS (si aws cli está disponible)
    if command -v aws &> /dev/null; then
        print_status "Probando conectividad con AWS..."
        
        export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
        export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
        export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
        
        if aws sts get-caller-identity &>/dev/null; then
            local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
            print_success "Conectividad con AWS exitosa (Account: $account_id)"
        else
            print_error "Fallo en conectividad con AWS"
            ((aws_errors++))
        fi
    else
        print_warning "AWS CLI no disponible, saltando prueba de conectividad"
        ((warnings++))
    fi
    
    if [ $aws_errors -eq 0 ]; then
        print_success "✅ AWS configurado correctamente"
    else
        print_error "❌ AWS tiene $aws_errors errores"
        ((errors += aws_errors))
    fi
    
    echo
}

# Función para validar GCP
validate_gcp() {
    print_status "🟢 Validando Google Cloud Platform..."
    
    local gcp_errors=0
    
    # Verificar variables básicas
    if [ -z "$GCP_PROJECT_ID" ]; then
        print_error "GCP_PROJECT_ID no está definida"
        ((gcp_errors++))
    else
        print_success "GCP_PROJECT_ID está definida: $GCP_PROJECT_ID"
    fi
    
    if [ -z "$GCP_SERVICE_ACCOUNT_EMAIL" ]; then
        print_error "GCP_SERVICE_ACCOUNT_EMAIL no está definida"
        ((gcp_errors++))
    else
        print_success "GCP_SERVICE_ACCOUNT_EMAIL está definida"
    fi
    
    if [ -z "$GCP_SERVICE_ACCOUNT_KEY_FILE" ]; then
        print_error "GCP_SERVICE_ACCOUNT_KEY_FILE no está definida"
        ((gcp_errors++))
    else
        if [ -f "$GCP_SERVICE_ACCOUNT_KEY_FILE" ]; then
            print_success "Archivo de clave de servicio encontrado"
            
            # Verificar que es un JSON válido
            if jq empty "$GCP_SERVICE_ACCOUNT_KEY_FILE" 2>/dev/null; then
                print_success "Archivo de clave JSON es válido"
            else
                print_error "Archivo de clave JSON no es válido"
                ((gcp_errors++))
            fi
        else
            print_error "Archivo de clave de servicio no encontrado: $GCP_SERVICE_ACCOUNT_KEY_FILE"
            ((gcp_errors++))
        fi
    fi
    
    # Verificar formato del email de service account
    if [ -n "$GCP_SERVICE_ACCOUNT_EMAIL" ] && [[ ! "$GCP_SERVICE_ACCOUNT_EMAIL" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.iam\.gserviceaccount\.com$ ]]; then
        print_warning "GCP_SERVICE_ACCOUNT_EMAIL no tiene formato de service account válido"
        ((warnings++))
    fi
    
    # Probar conectividad con GCP (si gcloud está disponible)
    if command -v gcloud &> /dev/null && [ -f "$GCP_SERVICE_ACCOUNT_KEY_FILE" ]; then
        print_status "Probando conectividad con GCP..."
        
        if gcloud auth activate-service-account --key-file="$GCP_SERVICE_ACCOUNT_KEY_FILE" --quiet 2>/dev/null; then
            if gcloud projects describe "$GCP_PROJECT_ID" --quiet &>/dev/null; then
                print_success "Conectividad con GCP exitosa"
            else
                print_error "No se puede acceder al proyecto GCP"
                ((gcp_errors++))
            fi
        else
            print_error "Fallo en autenticación con GCP"
            ((gcp_errors++))
        fi
    else
        print_warning "gcloud CLI no disponible o archivo de clave faltante, saltando prueba"
        ((warnings++))
    fi
    
    if [ $gcp_errors -eq 0 ]; then
        print_success "✅ GCP configurado correctamente"
    else
        print_error "❌ GCP tiene $gcp_errors errores"
        ((errors += gcp_errors))
    fi
    
    echo
}

# Función para validar OCI
validate_oci() {
    print_status "🔴 Validando Oracle Cloud Infrastructure..."
    
    local oci_errors=0
    
    # Verificar variables básicas
    if [ -z "$OCI_USER_ID" ]; then
        print_error "OCI_USER_ID no está definida"
        ((oci_errors++))
    else
        print_success "OCI_USER_ID está definida"
    fi
    
    if [ -z "$OCI_TENANCY_ID" ]; then
        print_error "OCI_TENANCY_ID no está definida"
        ((oci_errors++))
    else
        print_success "OCI_TENANCY_ID está definida"
    fi
    
    if [ -z "$OCI_FINGERPRINT" ]; then
        print_error "OCI_FINGERPRINT no está definida"
        ((oci_errors++))
    else
        print_success "OCI_FINGERPRINT está definida"
    fi
    
    if [ -z "$OCI_PRIVATE_KEY_PATH" ]; then
        print_error "OCI_PRIVATE_KEY_PATH no está definida"
        ((oci_errors++))
    else
        if [ -f "$OCI_PRIVATE_KEY_PATH" ]; then
            print_success "Archivo de clave privada encontrado"
            
            # Verificar que es una clave RSA válida
            if openssl rsa -in "$OCI_PRIVATE_KEY_PATH" -check -noout 2>/dev/null; then
                print_success "Clave privada RSA es válida"
            else
                print_error "Clave privada RSA no es válida"
                ((oci_errors++))
            fi
        else
            print_error "Archivo de clave privada no encontrado: $OCI_PRIVATE_KEY_PATH"
            ((oci_errors++))
        fi
    fi
    
    # Verificar formato de OCIDs
    if [ -n "$OCI_USER_ID" ] && [[ ! "$OCI_USER_ID" =~ ^ocid1\.user\.oc1\.\.[a-zA-Z0-9]+$ ]]; then
        print_warning "OCI_USER_ID no tiene formato OCID válido"
        ((warnings++))
    fi
    
    if [ -n "$OCI_TENANCY_ID" ] && [[ ! "$OCI_TENANCY_ID" =~ ^ocid1\.tenancy\.oc1\.\.[a-zA-Z0-9]+$ ]]; then
        print_warning "OCI_TENANCY_ID no tiene formato OCID válido"
        ((warnings++))
    fi
    
    # Probar conectividad con OCI (si oci cli está disponible)
    if command -v oci &> /dev/null; then
        print_status "Probando conectividad con OCI..."
        
        # Crear configuración temporal
        local temp_config=$(mktemp)
        cat > "$temp_config" << EOF
[DEFAULT]
user=$OCI_USER_ID
fingerprint=$OCI_FINGERPRINT
key_file=$OCI_PRIVATE_KEY_PATH
tenancy=$OCI_TENANCY_ID
region=${OCI_REGION:-us-ashburn-1}
EOF
        
        if oci --config-file "$temp_config" iam user get --user-id "$OCI_USER_ID" &>/dev/null; then
            print_success "Conectividad con OCI exitosa"
        else
            print_error "Fallo en conectividad con OCI"
            ((oci_errors++))
        fi
        
        rm -f "$temp_config"
    else
        print_warning "OCI CLI no disponible, saltando prueba de conectividad"
        ((warnings++))
    fi
    
    if [ $oci_errors -eq 0 ]; then
        print_success "✅ OCI configurado correctamente"
    else
        print_error "❌ OCI tiene $oci_errors errores"
        ((errors += oci_errors))
    fi
    
    echo
}

# Función para validar configuración multi-cloud
validate_multicloud() {
    print_status "🌐 Validando configuración multi-cloud..."
    
    local multicloud_errors=0
    
    # Verificar provider por defecto
    if [ -n "$DEFAULT_CLOUD_PROVIDER" ]; then
        case "$DEFAULT_CLOUD_PROVIDER" in
            azure|aws|gcp|oci)
                print_success "DEFAULT_CLOUD_PROVIDER válido: $DEFAULT_CLOUD_PROVIDER"
                ;;
            *)
                print_error "DEFAULT_CLOUD_PROVIDER inválido: $DEFAULT_CLOUD_PROVIDER"
                ((multicloud_errors++))
                ;;
        esac
    else
        print_warning "DEFAULT_CLOUD_PROVIDER no está definida"
        ((warnings++))
    fi
    
    # Verificar providers habilitados
    if [ -n "$ENABLED_CLOUD_PROVIDERS" ]; then
        print_success "ENABLED_CLOUD_PROVIDERS: $ENABLED_CLOUD_PROVIDERS"
        
        # Contar providers habilitados
        local enabled_count=$(echo "$ENABLED_CLOUD_PROVIDERS" | tr ',' '\n' | wc -l)
        print_status "Número de providers habilitados: $enabled_count"
    else
        print_warning "ENABLED_CLOUD_PROVIDERS no está definida"
        ((warnings++))
    fi
    
    if [ $multicloud_errors -eq 0 ]; then
        print_success "✅ Configuración multi-cloud correcta"
    else
        print_error "❌ Configuración multi-cloud tiene $multicloud_errors errores"
        ((errors += multicloud_errors))
    fi
    
    echo
}

# Ejecutar validaciones
validate_azure
validate_aws
validate_gcp
validate_oci
validate_multicloud

# Resumen final
print_status "=== RESUMEN DE VALIDACIÓN ==="
echo

if [ $errors -eq 0 ]; then
    print_success "🎉 Todas las validaciones pasaron correctamente"
    if [ $warnings -gt 0 ]; then
        print_warning "⚠️  Se encontraron $warnings advertencias (no críticas)"
    fi
else
    print_error "❌ Se encontraron $errors errores críticos"
    if [ $warnings -gt 0 ]; then
        print_warning "⚠️  También se encontraron $warnings advertencias"
    fi
fi

echo
print_status "📚 Para más información sobre configuración:"
print_status "- Documentación: docs/cloud-providers-setup.md"
print_status "- Script de configuración: ./scripts/setup-cloud-providers.sh"
print_status "- Archivos de configuración: config/backstage/"

if [ $errors -gt 0 ]; then
    exit 1
else
    exit 0
fi
