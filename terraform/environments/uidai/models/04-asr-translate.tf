resource "kubernetes_deployment_v1" "speech_whisper_batched" {
  depends_on = [module.hugging_face_secret, module.azure_storage_secret]

  metadata {
    name      = "speech-whisper-batched"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "speech-whisper-batched"
      "monitor"                = "tritonserver-speech"
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
        "app.kubernetes.io/name" = "speech-whisper-batched"
        "monitor"                = "tritonserver-speech"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "speech-whisper-batched"
          "monitor"                = "tritonserver-speech"
        }

        annotations = {
          "prometheus.io/port"   = "8002"
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
            size_limit = "4Gi"
          }
        }

        volume {
          name = "nfs-volume"

          persistent_volume_claim {
            claim_name = "local-storage-pvc"
          }
        }

        container {
          name              = "speech-whisper-batched-container"
          image             = "v2vcrh100.azurecr.io/inference/riva/deployment-whisper-triton-onprem:latest"
          image_pull_policy = "Always"
          command           = ["/bin/sh", "-c"] # Override the entrypoint with a shell
          args              = ["tritonserver --metrics-interval-ms=1000 --model-repository=\"/data/models\""]
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
            name = "AZURE_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_CLIENT_ID"
              }
            }
          }

          env {
            name = "AZURE_TENANT_ID"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_TENANT_ID"
              }
            }
          }

          env {
            name = "AZURE_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = "azure-storage-secret"
                key  = "AZURE_CLIENT_SECRET"
              }
            }
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
            name  = "CONTAINER_METADATA"
            value = "whisper-release-batched-0.1.2.json"
          }

          env {
            name  = "WHISPER_HI_HF_MODEL_NAME"
            value = "/data/models/whisper-ml-hf/1/saaras_0_11"
          }

          env {
            name  = "LD_LIBRARY_PATH"
            value = "/opt/riva/lib/:/opt/tritonserver/backends/pytorch/"
          }

          env {
            name  = "IMAGE_TYPE"
            value = "riva"
          }

          env {
            name  = "NFS_BASE_PATH"
            value = "/nfs-mnt"
          }

          resources {
            limits = {
              "nvidia.com/gpu" = "1"
            }
            requests = {
              cpu              = "1000m"
              memory           = "4Gi"
              "nvidia.com/gpu" = "1"
            }
          }

          port {
            name           = "health-port"
            container_port = 8000
          }

          port {
            name           = "metrics-port"
            container_port = 8002
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

resource "kubernetes_service_v1" "speech_whisper_batched_service" {
  metadata {
    name      = "speech-whisper-batched-service"
    namespace = var.models_namespace
    labels = {
      "app.kubernetes.io/name" = "speech-whisper-batched"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "speech-whisper-batched"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "health-port"
    }

    port {
      port        = 8002
      target_port = 8002
      protocol    = "TCP"
      name        = "metrics-port"
    }

    type = "LoadBalancer"
  }
}
