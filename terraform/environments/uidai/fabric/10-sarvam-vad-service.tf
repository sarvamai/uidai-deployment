locals {

  env_vars = {
    "MAX_WORKERS" = {
      "value" = "5"
    }
    "SILERO_PATH" = {
      "value" = "/workspace/snakers4_silero-vad_v5.2"
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
  namespace       = var.fabric_namespace
  service_account = var.fabric_service_account
  node_selector_labels = var.node_selector_labels

  containers = [
    {
      "env_from"          = local.sarvam_vad_service_env_from
      "env_vars"          = local.env_vars
      "image"             = "${var.docker_registry_name}/sarvam-vad-service:v0.1.2"
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
          "memory" = "2Gi"
        }
        "limits" = {
          "cpu"    = "500m"
          "memory" = "3Gi"
        }
      }
    }
  ]

  hpa = {
    "max_replicas" = 1
    "min_replicas" = 1
    "resource_metrics" = [
      {
        "name"         = "cpu"
        "target_type"  = "Utilization"
        "target_value" = "70"
      },
      {
        "name"         = "memory"
        "target_type"  = "Utilization"
        "target_value" = "70"
      },
    ]
    "pod_scale_up" = {
      "value"          = 4
      "period_seconds" = "30"
    }
    "pod_scale_down" = {
      "value"          = 100
      "period_seconds" = "30"
    }
  }

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

