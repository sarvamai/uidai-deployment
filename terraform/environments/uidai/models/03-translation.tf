resource "kubernetes_deployment_v1" "vllm_l3_translation_new" {

  metadata {
    name      = "vllm-l3-translation-new"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "vllm-l3-translation-new"
      "monitor"                = "vllm-server"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "4"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "vllm-l3-translation-new"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "vllm-l3-translation-new"
          "monitor"                = "vllm-server"
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
            size_limit = "40Gi"
          }
        }

        container {
          name              = "vllm-l3-translation-new-container"
          image             = "${var.docker_registry_name}/inference/llm/vllm-release-formal-eng-2-indic-2:0.5.2.post1.dynlen"
          image_pull_policy = "Always"

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }

          env {
            name = "HUGGING_FACE_HUB_TOKEN"
            value = ""
          }

          env {
            name  = "MODEL1"
            value = "/workspace/sarvam/translation-eng-2-formal-indic-2"
          }

          env {
            name  = "REVISION1"
            value = "v3.1"
          }

          env {
            name  = "PORT1"
            value = "8000"
          }

          env {
            name  = "GPU_MEM_UTIL1"
            value = "1.0"
          }

          env {
            name  = "MAX_MODEL_LEN1"
            value = "4096"
          }

          startup_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 20
            failure_threshold     = 300
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          port {
            name           = "model1-port"
            container_port = 8000
          }

          resources {
            limits = {
              "nvidia.com/gpu" = "1"
            }
            requests = {
              cpu              = "1000m"
              memory           = "20Gi"
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

resource "kubernetes_service_v1" "vllm_l3_translation_new" {
  metadata {
    name      = "vllm-l3-translation-new-service"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "vllm-l3-translation-new"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "vllm-l3-translation-new"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "model1-port"
    }
  }
}
