resource "kubernetes_deployment_v1" "redis_deployment" {
  depends_on = [module.redis_secrets]

  metadata {
    name = "redis-deployment"
    labels = {
      app = "redis"
    }
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
          name  = "redis"
          image = "redis:6.2"

          command = ["redis-server", "--requirepass", "$(REDIS_PASSWORD)"]

          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = "redis-secrets"
                key  = "REDIS_PASSWORD"
              }
            }
          }

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-storage"
            mount_path = "/data/redis"
          }
        }

        volume {
          name = "redis-storage"
          persistent_volume_claim {
            claim_name = "local-storage-pvc"
          }
        }

        toleration {
          key      = "sku"
          operator = "Equal"
          value    = "gpu"
          effect   = "NoSchedule"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "redis_service" {
  metadata {
    name = "redis-service"
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      protocol    = "TCP"
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}
