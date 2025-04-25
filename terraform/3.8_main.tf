resource "kubernetes_config_map" "sample-config" {
  metadata {
    name      = "${local.name_prefix}-sample-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    "welcome-message" = "Welcome to EKS Activity!"
  }
}

resource "kubernetes_secret" "sample-secret" {
  metadata {
    name      = "${local.name_prefix}-sample-secret"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  data = {
    password = "mysecurepassword"
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "httpd_app" {
  metadata {
    name      = "${local.name_prefix}-sample-httpd-app"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = "httpd-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "httpd-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "httpd-app"
        }
      }
      spec {
        container {
          name  = "httpd-app"
          image = "hashicorp/http-echo:latest"

          args = [
            "-text=$(WELCOME_MESSAGE)"
          ]
          port {
            container_port = 5678
          }
          env {
            name = "WELCOME_MESSAGE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.sample-config.metadata[0].name
                key  = "welcome-message"
              }
            }
          }
          env {
            name = "APP_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.sample-secret.metadata[0].name
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "loadbalancer_service" {
  metadata {
    name      = "${local.name_prefix}-loadbalancer-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "httpd-app"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 5678
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "clusterip_service" {
  metadata {
    name      = "${local.name_prefix}-clusterip-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "httpd-app"
    }
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 5678
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "nodeport_service" {
  metadata {
    name      = "${local.name_prefix}-nodeport-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "httpd-app"
    }
    port {
      protocol    = "TCP"
      port        = 30001
      target_port = 5678
      node_port   = 30001
    }
    type = "NodePort"
  }
}
