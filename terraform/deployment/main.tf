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
    
    kind_config {
        kind       = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
        role = "control-plane"
        
        kubeadm_config_patches = [
            "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
        ]

        extra_port_mappings {
            container_port = 80
            host_port      = 80
            protocol       = "TCP"
        }

        extra_port_mappings {
            container_port = 443
            host_port      = 443
            protocol       = "TCP"
        }
        }
    }
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

resource "helm_release" "ingress_nginx" {
    name             = "ingress-nginx"
    repository       = "https://kubernetes.github.io/ingress-nginx"
    chart            = "ingress-nginx"
    namespace        = "ingress-nginx"
    create_namespace = true

    values = [file("values.yaml")]
}