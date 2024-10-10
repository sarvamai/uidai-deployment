resource "kubernetes_deployment" "speech_tts_nemo" {
  metadata {
    name      = "speech-tts-nemo"
    namespace = var.models_namespace
    labels = {
      app = "speech-tts-nemo"
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
        app = "speech-tts-nemo"
      }
    }

    template {
      metadata {
        labels = {
          app = "speech-tts-nemo"
        }
        annotations = {
          "prometheus.io/port"   = "8002"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        service_account_name = var.models_service_account
        node_selector = var.node_selector_labels
        
        container {
          name              = "speech-tts-nemo-container"
          image             = "${var.docker_registry_name}/inference/tts/deployment-tts-triton:on-prem-v2"
          image_pull_policy = "Always"

          command = ["/bin/sh", "-c"] # Override the entrypoint with a shell
          args    = ["tritonserver --metrics-interval-ms=1000 --model-repository=\"/data/models\""]

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }

          env {
            name  = "HUGGING_FACE_HUB_TOKEN"
            value = ""
          }

          env {
            name = "AZURE_CLIENT_ID"
            value = ""
          }

          env {
            name = "AZURE_TENANT_ID"
            value = ""
          }

          env {
            name = "AZURE_CLIENT_SECRET"
            value = ""
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
            value = "tts-nemo-release-0.1.3.json"
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
            name  = "MODEL_NAME"
            value = "bulbul_0_4"
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

          resources {
            limits = {
              "nvidia.com/gpu" = "1"
            }
            requests = {
              cpu              = "1"
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

          startup_probe {
            http_get {
              path = "/v2/health/ready"
              port = "health-port"
            }
            initial_delay_seconds = 0
            period_seconds        = 20
            failure_threshold     = 500
          }

          readiness_probe {
            http_get {
              path = "/v2/health/ready"
              port = "health-port"
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }

          liveness_probe {
            http_get {
              path = "/v2/health/ready"
              port = "health-port"
            }
            initial_delay_seconds = 0
            period_seconds        = 30
          }
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dns_policy                       = "ClusterFirst"
        scheduler_name                   = "default-scheduler"

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

resource "kubernetes_service" "speech_tts_nemo_service" {
  metadata {
    name      = "speech-tts-nemo-service"
    namespace = var.models_namespace
    labels = {
      app = "speech-tts-nemo"
    }
  }

  spec {
    selector = {
      app = "speech-tts-nemo"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "model-port"
    }

    port {
      port        = 8002
      target_port = 8002
      protocol    = "TCP"
      name        = "metrics-port"
    }
  }
}
