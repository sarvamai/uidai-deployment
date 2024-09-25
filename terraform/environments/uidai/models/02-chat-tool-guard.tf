resource "kubernetes_deployment_v1" "vllm_l3_1_sarvam_chat_tool_guard" {
  depends_on = [module.hugging_face_secret, module.azure_storage_secret]

  metadata {
    name = "vllm-l3-1-sarvam-chat-tool-guard"
    labels = {
      "app.kubernetes.io/name" = "vllm-l3-1-sarvam-chat-tool-guard"
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
        "app.kubernetes.io/name" = "vllm-l3-1-sarvam-chat-tool-guard"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "vllm-l3-1-sarvam-chat-tool-guard"
          "monitor"                = "vllm-server"
        }
      }

      spec {
        volume {
          name = "dshm"

          empty_dir {
            medium     = "Memory"
            size_limit = "40Gi"
          }
        }

        volume {
          name = "nfs-volume"

          persistent_volume_claim {
            claim_name = "local-storage-pvc"
          }
        }

        container {
          name              = "vllm-l3-1-sarvam-chat-container"
          image             = "appsprodacr.azurecr.io/inference/llm/vllm-release:0.5.2.post1.dynlen"
          image_pull_policy = "Always"

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }

          volume_mount {
            name       = "nfs-volume"
            mount_path = "/nfs-mnt"
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
            name  = "HF_HOME"
            value = "/nfs-mnt/.cache"
          }

          env {
            name  = "MODEL1"
            value = "sarvam/sarvam_bot_v1_chat"
          }

          env {
            name  = "REVISION1"
            value = ""
          }

          env {
            name  = "PORT1"
            value = "8000"
          }

          env {
            name  = "GPU_MEM_UTIL1"
            value = "0.3"
          }

          env {
            name  = "MAX_MODEL_LEN1"
            value = "4096"
          }

          env {
            name  = "GPU_MEM_UTIL1"
            value = "0.3"
          }

          env {
            name  = "MODEL2"
            value = "sarvam/sarvam_bot_v1_tool"
          }

          env {
            name  = "REVISION2"
            value = ""
          }

          env {
            name  = "PORT2"
            value = "8001"
          }

          env {
            name  = "GPU_MEM_UTIL2"
            value = "0.3"
          }

          env {
            name  = "MAX_MODEL_LEN2"
            value = "4096"
          }

          env {
            name  = "MODEL3"
            value = "meta-llama/Llama-Guard-3-8B"
          }

          env {
            name  = "REVISION3"
            value = ""
          }

          env {
            name  = "PORT3"
            value = "8002"
          }

          env {
            name  = "GPU_MEM_UTIL3"
            value = "0.3"
          }

          env {
            name  = "MAX_MODEL_LEN3"
            value = "4096"
          }

          startup_probe {
            http_get {
              path = "/health"
              port = 8002
            }
            initial_delay_seconds = 0
            period_seconds        = 20
            failure_threshold     = 300
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8002
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8002
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          port {
            name           = "model1-port"
            container_port = 8000
          }

          port {
            name           = "model2-port"
            container_port = 8001
          }

          port {
            name           = "model3-port"
            container_port = 8002
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

resource "kubernetes_service_v1" "vllm_l3_1_sarvam_chat_tool_guard_service" {
  metadata {
    name = "vllm-l3-1-sarvam-chat-tool-guard-service"
    labels = {
      "app.kubernetes.io/name" = "vllm-l3-1-sarvam-chat-tool-guard"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "vllm-l3-1-sarvam-chat-tool-guard"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "model1-port"
    }

    port {
      port        = 8001
      target_port = 8001
      protocol    = "TCP"
      name        = "model2-port"
    }

    port {
      port        = 8002
      target_port = 8002
      protocol    = "TCP"
      name        = "model3-port"
    }

    type = "ClusterIP"
  }
}
