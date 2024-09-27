resource "kubernetes_deployment" "nim_llama3_1_8b" {
  depends_on = [module.github_access_token, module.hugging_face_secret]
  metadata {
    name      = "nim-llama3-1-8b"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "nim-llama3-1-8b"
      "monitor"                = "tritonserver"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "nim-llama3-1-8b"
        "monitor"                = "tritonserver"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "25%"
        max_surge       = "25%"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "nim-llama3-1-8b"
          "monitor"                = "tritonserver"
        }
        annotations = {
          "prometheus.io/port"   = "8000"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        service_account_name = var.models_service_account

        volume {
          name = "dshm"

          empty_dir {
            medium     = "Memory"
            size_limit = "16Gi"
          }
        }

        volume {
          name = "nfs-volume"

          persistent_volume_claim {
            claim_name = "local-storage-pvc"
          }
        }

        container {
          name              = "nim-llama3-1-8b-container"
          image             = "${var.docker_registry_name}/deployment-trt-llm-nim-release:v0.12.0.pre_json_decode_fixed3_with_engine_v2"
          image_pull_policy = "Always"

          startup_probe {
            http_get {
              path = "/v1/health/ready"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 20
            failure_threshold     = 500
          }

          readiness_probe {
            http_get {
              path = "/v1/health/ready"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          liveness_probe {
            http_get {
              path = "/v1/health/live"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          port {
            name           = "metrics-port"
            container_port = 8000
          }

          port {
            name           = "grpc-port"
            container_port = 8001
          }

          env {
            name  = "PYTHONIOENCODING"
            value = "utf-8"
          }

          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }

          env {
            name  = "MODEL_PATH"
            value = "/nfs-mnt/trt-nim/l3.1-8b-fp8-mxbs256-isl4096-seq4096/llama-3.1-8b/"
          }

          env {
            name  = "TP_SIZE"
            value = "1"
          }

          env {
            name = "HUGGING_FACE_HUB_TOKEN"
            value_from {
              secret_key_ref {
                name = "hugging-face-secret"
                key  = "HUGGING_FACE_HUB_TOKEN"
              }
            }
          }

          env {
            name = "GITHUB_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = "github-access-token"
                key  = "GITHUB_ACCESS_TOKEN"
              }
            }
          }

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }

          volume_mount {
            name       = "nfs-volume"
            mount_path = "/mnt"
          }

          resources {
            limits = {
              "nvidia.com/gpu" = "1"
            }
            requests = {
              "cpu"            = "1000m"
              "nvidia.com/gpu" = "1"
            }
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


resource "kubernetes_service_v1" "nim_llama3_1_8b_service" {
  metadata {
    name      = "nim-llama3-1-8b-service"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "nim-llama3-1-8b"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "nim-llama3-1-8b"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "model1-port"
    }

    port {
      port        = 8002
      target_port = 8002
      protocol    = "TCP"
      name        = "model2-port"
    }

    type = "LoadBalancer"
  }
}
