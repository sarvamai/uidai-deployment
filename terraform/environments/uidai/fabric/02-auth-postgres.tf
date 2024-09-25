resource "kubernetes_stateful_set_v1" "auth_postgres_statefulset" {
  depends_on = [
    module.auth_postgres_db_env,
    module.auth_postgres_db_secrets,
    kubernetes_persistent_volume_claim.auth_postgres_pvc,
  ]
  metadata {
    name = "auth-postgres-statefulset"
    labels = {
      app = "auth-postgres"
    }
  }

  spec {
    service_name = "auth-postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "auth-postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "auth-postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "auth-postgres-db-secrets"
                key  = "DATABASE_PASSWORD"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value = "auth-db"
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                name = "auth-postgres-db-env"
                key  = "DATABASE_USER"
              }
            }
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.auth_postgres_pvc.metadata.0.name
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

resource "kubernetes_service_v1" "auth_postgres_service" {
  metadata {
    name = "auth-postgres-service"
  }

  spec {
    selector = {
      app = "auth-postgres"
    }

    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}
