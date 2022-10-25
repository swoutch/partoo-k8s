terraform {
  required_providers {
    gandi = {
      version = "~> 2.0.0"
      source  = "go-gandi/gandi"
    }
    scaleway = {
      source = "scaleway/scaleway"
    }
    kubernetes = {
      version = "2.14.0"
    }
    helm = {
      version = "2.7.1"
    }
    null = {
      version = "3.1.1"
    }
  }
  required_version = ">= 0.13"
}

locals {
  nginx_ingress_controller_service_name = "nginx-ingress"
}

############################################
# Gandi
############################################
resource "gandi_livedns_record" "pikachu_dns_record" {
  zone   = "swout.ch"
  name   = "pikachu"
  type   = "A"
  ttl    = 300
  values = [one(flatten(data.kubernetes_service.example.status[*].load_balancer[*].ingress[*].ip))]
}

############################################
# Scaleway
############################################

provider "scaleway" {
  zone   = "fr-par-1"
  region = "fr-par"
}

resource "scaleway_k8s_cluster" "jack" {
  name    = "partoo-k8s"
  version = "1.24.5"
  cni     = "cilium"
}

resource "scaleway_k8s_pool" "john" {
  cluster_id = scaleway_k8s_cluster.jack.id
  name       = "john"
  node_type  = "DEV1-M"
  size       = 2
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.john] # at least one pool here
  triggers = {
    host                   = scaleway_k8s_cluster.jack.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.jack.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.jack.kubeconfig[0].cluster_ca_certificate
  }
}

provider "kubernetes" {
  host  = null_resource.kubeconfig.triggers.host
  token = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
  )
}

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

provider "helm" {
  kubernetes {
    host  = null_resource.kubeconfig.triggers.host
    token = null_resource.kubeconfig.triggers.token
    cluster_ca_certificate = base64decode(
      null_resource.kubeconfig.triggers.cluster_ca_certificate
    )
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "0.15.1"
  namespace  = kubernetes_namespace.nginx_ingress.metadata[0].name
  set {
    name  = "controller.service.name"
    value = local.nginx_ingress_controller_service_name
  }
}

data "kubernetes_service" "example" {
  metadata {
    name      = local.nginx_ingress_controller_service_name
    namespace = kubernetes_namespace.nginx_ingress.metadata[0].name
  }
}

output "ip" {
  value = one(flatten(data.kubernetes_service.example.status[*].load_balancer[*].ingress[*].ip))
}
