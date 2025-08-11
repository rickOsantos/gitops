terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create namespace
resource "kubernetes_namespace" "gitops" {
  metadata {
    name = "gitops"
    labels = {
      name        = "gitops"
      environment = "production"
    }
  }
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  
  create_namespace = true
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

# Install cert-manager for SSL
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.11.0"
  
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Output
output "cluster_info" {
  value = {
    namespace = kubernetes_namespace.gitops.metadata[0].name
    ingress   = "nginx-ingress installed"
    ssl       = "cert-manager installed"
  }
}