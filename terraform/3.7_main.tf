locals {
  name_prefix = "ky-tf"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.name_prefix}-eks-activity"
  }
}

resource "kubernetes_service_account" "nginx_sa" {
  metadata {
    name      = "${local.name_prefix}-nginx-service-account"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "${local.name_prefix}-nginx-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.nginx_sa.metadata[0].name

        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "${local.name_prefix}-nginx-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}


