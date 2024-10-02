provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "redis_namespace" {
  metadata {
    name = "redis-namespace"
  }
}

resource "kubernetes_deployment" "redis_deployment" {
  metadata {
    name      = "redis-deployment"
    namespace = kubernetes_namespace.redis_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          image = "redis:6.0.9"
          name  = "redis"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name      = "redis-service"
    namespace = kubernetes_namespace.redis_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}
