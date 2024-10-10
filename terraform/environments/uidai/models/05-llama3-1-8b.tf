resource "kubernetes_deployment" "nim_llama3_1_8b" {

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
        node_selector = var.node_selector_labels

        volume {
          name = "dshm"

          empty_dir {
            medium     = "Memory"
            size_limit = "16Gi"
          }
        }

        container {
          name              = "nim-llama3-1-8b-container"
          image             = "${var.docker_registry_name}/inference/llm/nim/deployment-trt-llm-nim-release:v0.12.0.onprem.fix"
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
            value = "/data/models/sarvam-nim-models/"
          }

          env {
            name  = "TP_SIZE"
            value = "1"
          }

          env {
            name = "HUGGING_FACE_HUB_TOKEN"
            value = ""
          }

          env {
            name = "GITHUB_ACCESS_TOKEN"
            value = ""
          }

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
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
  }
}
