terraform {
  required_providers {
    kind = {
        source = "tehcyx/kind"
        version = "0.11.0"
    }
    helm = {
        source = "hashicorp/helm"
        version = "3.1.1"
    }
  }
}

resource "kind_cluster" "default"{
    name = "platform-cluster"
    wait_for_ready = true
}

provider "helm" {
    kubernetes = {
        host = kind_cluster.default.endpoint
        client_certificate = kind_cluster.default.client_certificate
        client_key = kind_cluster.default.client_key
        cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    }
}

resource "helm_release" "argocd" {
    name =  "argocd"
    
    repository  = "https://argoproj.github.io/argo-helm"
    chart       = "argo-cd"
    namespace   = "argocd"
    create_namespace = true
    version = "9.4.1"
}
