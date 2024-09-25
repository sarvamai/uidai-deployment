locals {

  env_vars = {
    "MAX_WORKERS" = {
      "value" = "5"
    }
  }

  sarvam_vad_service_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
  }

}

module "sarvam_vad_service" {
  source = "../../../modules/deployment"

  name            = "sarvam-vad-service"
  namespace       = "default"
  service_account = "default"
  containers = [
    {
      "env_from"          = local.sarvam_vad_service_env_from
      "env_vars"          = local.env_vars
      "image"             = "gitopsdocker.azurecr.io/sarvam-vad-service"
      "image_pull_policy" = "Always"
      "name"              = "sarvam-vad-service"
      "ports" = {
        "grpc" = {
          "container_port" = 50051
          "port"           = 50051
          "protocol"       = "TCP"
        }
      }

      "resources" = {
        "requests" = {
          "cpu"    = "100m"
          "memory" = "1Gi"
        }
        "limits" = {
          "cpu"    = "500m"
          "memory" = "2Gi"
        }
      }
    }
  ]

  replicas = 1

  kube_service_config = {
    "ports" = {
      "grpc" = {
        "port"        = 50051
        "protocol"    = "TCP"
        "target_port" = 50051
      }
    }
  }
  gpu_toleration = true

}

