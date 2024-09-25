provider "kubernetes" {
  # Ensure that you have the Kubernetes provider configured with appropriate credentials
}

resource "kubernetes_deployment" "riva_combined_dev" {
  metadata {
    name      = "riva-combined-dev"
    namespace = "default"
    labels = {
      app = "riva-combined-dev"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }

    selector {
      match_labels = {
        app = "riva-combined-dev"
      }
    }

    template {
      metadata {
        labels = {
          app = "riva-combined-dev"
        }
      }

      spec {
        container {
          name            = "riva-combined-dev-container"
          image           = "v2vcrh100.azurecr.io/inference/riva/deployment-riva-triton:custom-nemo-colocated"
          image_pull_policy = "Always"

          command = ["./tools/entrypoint.sh"]

          env {
            name  = "PYTHONIOENCODING"
            value = "utf-8"
          }

          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }

          env {
            name  = "MODEL_NAME"
            value = "large-v2"
          }

          env {
            name  = "AZURE_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_CLIENT_ID"
              }
            }
          }

          env {
            name  = "AZURE_TENANT_ID"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_TENANT_ID"
              }
            }
          }

          env {
            name  = "AZURE_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_CLIENT_SECRET"
              }
            }
          }

          env {
            name  = "CONTAINER_METADATA"
            value = "asr-tts-nemo-riva-multilingual-0.1.15.json"
          }

          env {
            name  = "WHISPER_MODEL_NAME"
            value = "large-v2"
          }

          env {
            name  = "WHISPER_HI_HF_MODEL_NAME"
            value = "sarvam/saaras_0_6"
          }

          env {
            name  = "WHISPER_ML_HF_MODEL_NAME"
            value = "sarvam/saaras_0_6"
          }

          env {
            name  = "WHISPER_STOCK_HF_MODEL_NAME"
            value = "openai/whisper-large-v2"
          }

          env {
            name  = "HUGGING_FACE_HUB_TOKEN"
            value = "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"
          }

          env {
            name  = "LD_LIBRARY_PATH"
            value = "/opt/riva/lib/:/opt/tritonserver/backends/pytorch/"
          }

          env {
            name  = "EMBEDDING_MODEL_NAME"
            value = "Alibaba-NLP/gte-large-en-v1.5"
          }

          env {
            name  = "PROMPT_INJECTION_MODEL_NAME"
            value = "protectai/deberta-v3-base-prompt-injection-v2"
          }

          env {
            name  = "RERANKING_MODEL_NAME"
            value = "BAAI/bge-reranker-v2-m3"
          }

          env {
            name  = "IMAGE_TYPE"
            value = "trtllm"
          }

          resources {
            limits = {
              "nvidia.com/gpu" = "1"
            }
            requests = {
              cpu    = "1"
              memory = "4Gi"
            }
          }

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }
        }

        restart_policy                 = "Always"
        termination_grace_period_seconds = 30
        dns_policy                      = "ClusterFirst"
        scheduler_name                  = "default-scheduler"

        toleration {
          key      = "sku"
          operator = "Equal"
          value    = "gpu"
          effect   = "NoSchedule"
        }

        volume {
          name = "dshm"

          empty_dir {
            medium     = "Memory"
            size_limit = "4Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "riva_combined_dev_service" {
  metadata {
    name      = "riva-combined-dev-service"
    namespace = "default"
    labels = {
      app = "riva-combined-dev"
    }
  }

  spec {
    selector = {
      app = "riva-combined-dev"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}