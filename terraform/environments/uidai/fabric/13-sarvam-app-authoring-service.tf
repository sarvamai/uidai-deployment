locals {

  sarvam_app_authoring_service_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
    "kb-postgres-db-env" = {
      "source" = "configMapRef"
    }
    "kb-postgres-db-secrets" = {
      "source" = "secretRef"
    }
  }

  sarvam_app_authoring_service_vars = merge(
    {
      "TOKEN_JWT_SECRET_ACCESS_KEY" = {
        "ref" = {
          "key"    = "TOKEN_JWT_SECRET_ACCESS_KEY"
          "name"   = "auth-shared-secrets"
          "source" = "secretKeyRef"
        }
        "value" = tostring(null)
      }
      "OPENAI_API_KEY" = {
        value = ""
      }
      "DATABASE_NAME" = {
        "value" = "sarvam-app-authoring-service-db"
      }
      "LOG_LEVEL" = {
        "value" = "DEBUG"
      }
      "APP_STORAGE_URL" = {
        "value" = var.app_storge_path
      }
  })

}


module "sarvam_app_authoring_service" {
  source = "../../../modules/deployment"

  name            = "sarvam-app-authoring-service"
  namespace       = var.fabric_namespace
  service_account = var.fabric_service_account
  # node_selector_labels = var.node_selector_labels

  containers = [{
    "env_from"          = local.sarvam_app_authoring_service_from
    "env_vars"          = local.sarvam_app_authoring_service_vars
    "image"             = "${var.docker_registry_name_sarvam}/sarvam-app-authoring-service:v0.0.27"
    "image_pull_policy" = "Always"
    "name"              = "sarvam-app-authoring-service"
    "ports" = {
      "http" = {
        "container_port" = 8080
        "port"           = 80
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

    probes = {
      liveness = {
        protocol              = "http_get"
        port                  = "8080"
        http_get_path         = "/health"
        initial_delay_seconds = 120
        period_seconds        = 10
        timeout_seconds       = 5
      }
    }

  }]

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
  }

  kube_service_config = {
    "ports" = {
      "http" = {
        "port"        = 80
        "target_port" = 8080
      }
    }
    "type" = "LoadBalancer"
  }

  # gpu_toleration = true
}

