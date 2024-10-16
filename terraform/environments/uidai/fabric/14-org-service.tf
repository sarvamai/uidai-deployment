locals {

  org_service_env_from = {
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

  org_service_env_vars = {
    "DATABASE_NAME" = {
      "ref"   = null /* object */
      "value" = "org-service-db"
    }
    "BASE_LOG_ESCAPE_NEWLINES" = {
      "ref"   = null /* object */
      "value" = "false"
    }
    "TOKEN_JWT_SECRET_ACCESS_KEY" = {
      "value" = ""
    }
    "TOKEN_JWT_SECRET_REFRESH_KEY" = {
      "value" = ""
    }
    "FIRST_ORG_CREATE" = {
      value = "true"
    }
  }
}

module "org_service" {
  source = "../../../modules/deployment"

  name      = "org-service"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  # node_selector_labels = var.node_selector_labels

  containers = [
    {
      "env_from"          = local.org_service_env_from
      "env_vars"          = local.org_service_env_vars
      "image"             = "${var.docker_registry_name_sarvam}/org-service:v0.2.5"
      "image_pull_policy" = "Always"
      "name"              = "org-service"
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
      }

    }
  ]

  apply_default_liveness_probe = true

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
        "protocol"    = "TCP"
        "target_port" = 8080
      }
    }
  }
  # gpu_toleration = true

}

