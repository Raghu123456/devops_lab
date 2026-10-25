
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

resource "kubernetes_namespace" "lab" {
  metadata {
    name = "devops-lab"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-demo"
    namespace = kubernetes_namespace.lab.metadata[0].name
    labels = {
      app = "nginx-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-demo"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.lab.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "nginx-demo"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }
  }
}

output "application_url" {
  value = "http://localhost:8080"
}
