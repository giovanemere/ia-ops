# =============================================================================
# IA-OPS PLATFORM - TERRAFORM CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# PROVIDERS
# =============================================================================

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# =============================================================================
# VARIABLES
# =============================================================================

variable "kube_config_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "ia-ops"
}

variable "docker_registry" {
  description = "Docker registry"
  type        = string
  default     = "edissonz8809"
}

# =============================================================================
# KUBERNETES NAMESPACE
# =============================================================================

resource "kubernetes_namespace" "ia_ops" {
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      environment = "development"
      project     = "ia-ops"
    }
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "namespace" {
  description = "Kubernetes namespace created"
  value       = kubernetes_namespace.ia_ops.metadata[0].name
}
