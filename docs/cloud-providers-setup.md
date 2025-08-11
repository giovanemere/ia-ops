# ☁️ Configuración de Cloud Providers en Backstage

## 📋 Tabla de Contenidos

- [Introducción](#introducción)
- [Microsoft Azure](#-microsoft-azure)
- [Amazon Web Services (AWS)](#-amazon-web-services-aws)
- [Google Cloud Platform (GCP)](#-google-cloud-platform-gcp)
- [Oracle Cloud Infrastructure (OCI)](#-oracle-cloud-infrastructure-oci)
- [Configuración Multi-Cloud](#-configuración-multi-cloud)
- [Troubleshooting](#-troubleshooting)

## 🌟 Introducción

Esta guía te ayudará a configurar múltiples proveedores de nube en Backstage para una gestión centralizada de recursos cloud.

### Funcionalidades Disponibles:
- 🔍 **Descubrimiento de recursos** automático
- 📊 **Monitoreo** de costos y rendimiento
- 🔐 **Gestión de seguridad** y compliance
- ☸️ **Integración con Kubernetes** (EKS, AKS, GKE, OKE)
- 🏗️ **Plantillas de scaffolding** específicas por proveedor

## 🔵 Microsoft Azure

### Prerrequisitos:
1. Cuenta de Azure activa
2. Permisos de administrador en Azure AD
3. Suscripción de Azure con permisos de Contributor

### Paso 1: Crear Aplicación en Azure AD

```bash
# Usando Azure CLI
az ad app create \
  --display-name "Backstage IA-Ops" \
  --homepage "http://localhost:3000" \
  --reply-urls "http://localhost:3000/api/auth/microsoft/handler/frame"

# Obtener Application ID
az ad app list --display-name "Backstage IA-Ops" --query "[0].appId" -o tsv
```

### Paso 2: Crear Service Principal

```bash
# Crear Service Principal
az ad sp create-for-rbac \
  --name "backstage-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### Paso 3: Configurar Variables de Entorno

```bash
# En .env
AZURE_CLIENT_ID=tu-application-id
AZURE_CLIENT_SECRET=tu-client-secret
AZURE_TENANT_ID=tu-tenant-id
AZURE_SUBSCRIPTION_ID=tu-subscription-id
AZURE_DEVOPS_ORG=tu-organizacion
AZURE_DEVOPS_TOKEN=tu-devops-token
```

### Paso 4: Configurar Azure DevOps (Opcional)

1. Ve a https://dev.azure.com/tu-organizacion/_usersSettings/tokens
2. Crea un Personal Access Token con permisos:
   - **Code**: Read
   - **Project and Team**: Read
   - **Build**: Read
   - **Release**: Read

### Servicios Integrados:
- ✅ Azure Resource Manager
- ✅ Azure DevOps
- ✅ Azure Container Registry (ACR)
- ✅ Azure Kubernetes Service (AKS)
- ✅ Azure Key Vault
- ✅ Azure Application Insights

## 🟠 Amazon Web Services (AWS)

### Prerrequisitos:
1. Cuenta de AWS activa
2. Permisos de IAM para crear usuarios y roles
3. AWS CLI instalado (opcional)

### Paso 1: Crear Usuario IAM

```bash
# Usando AWS CLI
aws iam create-user --user-name backstage-user

# Crear Access Keys
aws iam create-access-key --user-name backstage-user
```

### Paso 2: Asignar Políticas

```bash
# Política básica (ajustar según necesidades)
aws iam attach-user-policy \
  --user-name backstage-user \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# O crear política personalizada
cat > backstage-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "rds:Describe*",
        "s3:List*",
        "s3:Get*",
        "lambda:List*",
        "lambda:Get*",
        "eks:Describe*",
        "eks:List*",
        "ecr:Describe*",
        "ecr:List*",
        "cloudformation:Describe*",
        "cloudformation:List*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name BackstagePolicy \
  --policy-document file://backstage-policy.json

aws iam attach-user-policy \
  --user-name backstage-user \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/BackstagePolicy
```

### Paso 3: Configurar Variables de Entorno

```bash
# En .env
AWS_ACCESS_KEY_ID=tu-access-key-id
AWS_SECRET_ACCESS_KEY=tu-secret-access-key
AWS_DEFAULT_REGION=us-east-1
AWS_ACCOUNT_ID=tu-account-id
AWS_EKS_CLUSTER_NAME=tu-eks-cluster
AWS_ECR_REGISTRY_URL=tu-account-id.dkr.ecr.us-east-1.amazonaws.com
```

### Paso 4: Configurar Rol para Cross-Account (Opcional)

```bash
# Crear rol para asumir
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:user/backstage-user"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "backstage-external-id"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
  --role-name BackstageRole \
  --assume-role-policy-document file://trust-policy.json
```

### Servicios Integrados:
- ✅ Amazon EC2
- ✅ Amazon RDS
- ✅ Amazon S3
- ✅ AWS Lambda
- ✅ Amazon EKS
- ✅ Amazon ECR
- ✅ AWS CloudFormation
- ✅ Amazon CloudWatch

## 🟢 Google Cloud Platform (GCP)

### Prerrequisitos:
1. Proyecto de Google Cloud activo
2. Permisos de Project Editor o Owner
3. Google Cloud SDK instalado (opcional)

### Paso 1: Crear Service Account

```bash
# Usando gcloud CLI
gcloud iam service-accounts create backstage-sa \
  --display-name="Backstage Service Account" \
  --description="Service account for Backstage integration"
```

### Paso 2: Asignar Roles

```bash
# Roles básicos
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:backstage-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# Roles específicos (más seguro)
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:backstage-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.viewer"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:backstage-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.viewer"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:backstage-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"
```

### Paso 3: Generar Clave JSON

```bash
gcloud iam service-accounts keys create backstage-key.json \
  --iam-account=backstage-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### Paso 4: Configurar Variables de Entorno

```bash
# En .env
GCP_PROJECT_ID=tu-project-id
GCP_SERVICE_ACCOUNT_EMAIL=backstage-sa@tu-project-id.iam.gserviceaccount.com
GCP_SERVICE_ACCOUNT_KEY_FILE=/path/to/backstage-key.json
GCP_REGION=us-central1
GCP_GKE_CLUSTER_NAME=tu-gke-cluster
GOOGLE_APPLICATION_CREDENTIALS=/path/to/backstage-key.json
```

### Servicios Integrados:
- ✅ Google Compute Engine
- ✅ Google Kubernetes Engine (GKE)
- ✅ Google Container Registry (GCR)
- ✅ Google Cloud Storage
- ✅ Google Cloud SQL
- ✅ Google Cloud Functions
- ✅ Google Cloud Build

## 🔴 Oracle Cloud Infrastructure (OCI)

### Prerrequisitos:
1. Cuenta de Oracle Cloud activa
2. Permisos de administrador en el tenancy
3. OCI CLI instalado (opcional)

### Paso 1: Crear Usuario API

1. Ve a https://cloud.oracle.com/identity/users
2. Crea un nuevo usuario o selecciona uno existente
3. Ve a "API Keys" en la configuración del usuario

### Paso 2: Generar Par de Claves

```bash
# Generar clave privada
openssl genrsa -out oci-private-key.pem 2048

# Generar clave pública
openssl rsa -pubout -in oci-private-key.pem -out oci-public-key.pem

# Obtener fingerprint
openssl rsa -pubout -outform DER -in oci-private-key.pem | openssl md5 -c
```

### Paso 3: Agregar Clave Pública al Usuario

1. Copia el contenido de `oci-public-key.pem`
2. Pégalo en la sección "API Keys" del usuario en OCI Console
3. Guarda el fingerprint generado

### Paso 4: Crear Políticas IAM

```bash
# Política básica para el grupo
Allow group BackstageGroup to read all-resources in tenancy
Allow group BackstageGroup to manage compute-management-family in tenancy
Allow group BackstageGroup to manage instance-family in tenancy
Allow group BackstageGroup to manage volume-family in tenancy
Allow group BackstageGroup to manage network-family in tenancy
Allow group BackstageGroup to manage database-family in tenancy
Allow group BackstageGroup to manage object-family in tenancy
```

### Paso 5: Configurar Variables de Entorno

```bash
# En .env
OCI_USER_ID=ocid1.user.oc1..tu-user-ocid
OCI_TENANCY_ID=ocid1.tenancy.oc1..tu-tenancy-ocid
OCI_FINGERPRINT=tu-key-fingerprint
OCI_PRIVATE_KEY_PATH=/path/to/oci-private-key.pem
OCI_REGION=us-ashburn-1
OCI_COMPARTMENT_ID=ocid1.compartment.oc1..tu-compartment-ocid
```

### Servicios Integrados:
- ✅ OCI Compute
- ✅ OCI Container Engine for Kubernetes (OKE)
- ✅ OCI Container Registry (OCIR)
- ✅ OCI Object Storage
- ✅ OCI Autonomous Database
- ✅ OCI Functions

## 🌐 Configuración Multi-Cloud

### Habilitar Múltiples Proveedores

```bash
# En .env
DEFAULT_CLOUD_PROVIDER=aws
ENABLED_CLOUD_PROVIDERS=aws,azure,gcp,oci
CLOUD_PROVIDER_PRIORITY=aws,gcp,azure,oci
```

### Configuración de Kubernetes Multi-Cloud

```yaml
# En app-config.yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        # AWS EKS
        - url: https://your-eks-cluster.amazonaws.com
          name: production-eks
          authProvider: 'aws'
        
        # Azure AKS
        - url: https://your-aks-cluster.azure.com
          name: production-aks
          authProvider: 'azure'
        
        # GCP GKE
        - url: https://your-gke-cluster.googleapis.com
          name: production-gke
          authProvider: 'google'
        
        # OCI OKE
        - url: https://your-oke-cluster.oraclecloud.com
          name: production-oke
          authProvider: 'oci'
```

## 🔧 Scripts de Configuración

### Ejecutar Configuración Automática

```bash
# Configurar todos los proveedores
./scripts/setup-cloud-providers.sh

# Validar configuración
./scripts/validate-cloud-config.sh

# Probar conectividad
./scripts/test-cloud-connections.sh
```

### Instalar Plugins Necesarios

```bash
# En el directorio de Backstage
yarn add @backstage/plugin-azure-devops
yarn add @backstage/plugin-aws-apps
yarn add @backstage/plugin-gcp-projects
yarn add @backstage/plugin-kubernetes
yarn add @backstage/plugin-cost-insights
```

## 🐛 Troubleshooting

### Problemas Comunes

#### Azure: "Invalid client credentials"
```bash
# Verificar credenciales
az login
az account show
az ad app show --id $AZURE_CLIENT_ID
```

#### AWS: "Access Denied"
```bash
# Verificar credenciales
aws sts get-caller-identity
aws iam get-user
```

#### GCP: "Permission denied"
```bash
# Verificar service account
gcloud auth activate-service-account --key-file=backstage-key.json
gcloud projects get-iam-policy $GCP_PROJECT_ID
```

#### OCI: "Authentication failed"
```bash
# Verificar configuración
oci iam user get --user-id $OCI_USER_ID
oci iam compartment get --compartment-id $OCI_COMPARTMENT_ID
```

### Logs de Diagnóstico

```bash
# Ver logs de Backstage
docker logs ia-ops-backstage | grep -i "cloud\|azure\|aws\|gcp\|oci"

# Probar conectividad específica
curl -H "Authorization: Bearer $AZURE_ACCESS_TOKEN" \
  "https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resources?api-version=2021-04-01"
```

## 📚 Referencias

- [Backstage Azure Integration](https://backstage.io/docs/integrations/azure/discovery)
- [Backstage AWS Integration](https://backstage.io/docs/integrations/aws-s3/discovery)
- [Backstage GCP Integration](https://backstage.io/docs/integrations/google-gcs/discovery)
- [Backstage Kubernetes Plugin](https://backstage.io/docs/features/kubernetes/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs)
- [OCI CLI Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/)

## 🎯 Próximos Pasos

1. **Configurar credenciales** para cada proveedor
2. **Ejecutar script de configuración**
3. **Validar conectividad**
4. **Configurar descubrimiento de recursos**
5. **Personalizar dashboards** de monitoreo
6. **Configurar alertas** de costos y seguridad
