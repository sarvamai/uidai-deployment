locals {

  client_auth_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
  }

  client_auth_env_vars = {
    "SARVAM_BASE_URL" = {
      "value" = "http://auth-service"
    }
    "GOOGLE_CLIENT_ID" = {
      "ref"   = null /* object */
      "value" = ""
    }
    "GOOGLE_CLIENT_SECRET" = {
      "value" = ""
    }
    "NEXTAUTH_SECRET" = {
      "value" = "VoNoeL47YPHlsd02mCG1KlXOFdJJqHyTR2GjEJL/A7w="
    }
    "NEXTAUTH_URL" = {
      "value" = "http://4.157.157.106/auth/api/auth"
    }
    "TOGGLE_AUTH" = {
      "value" = "false"
    }
    "NEXT_AUTH_BASE_PATH" = {
      "value" = "/auth"
    }
    "SARVAM_AUTH_URL" = {
      "value" = "http://auth-service"
    }
    "SARVAM_ORG_URL" = {
      "value" = "http://org-service"
    }
    "AZURE_AD_B2C_TENANT_NAME" = {
      "ref"   = null /* object */
      "value" = ""
    }
    "AZURE_AD_B2C_CLIENT_ID" = {
      "ref"   = null
      "value" = ""
    }
    "AZURE_AD_B2C_PRIMARY_USER_FLOW" = {
      "ref"   = null /* object */
      "value" = ""
    }
    "AZURE_AD_B2C_CLIENT_SECRET" = {
      "value" = ""
    }
  }
}

module "client_auth" {
  source = "../../../modules/deployment"

  name      = "client-auth"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  # node_selector_labels = var.node_selector_labels
  containers = [
    {
      "env_from"          = local.client_auth_env_from
      "env_vars"          = local.client_auth_env_vars
      "image"             = "${var.docker_registry_name_sarvam}/client-auth:latest"
      "image_pull_policy" = "Always"
      "name"              = "client-auth"
      "ports" = {
        "http" = {
          "container_port" = 3000
          "port"           = 80
          "protocol"       = "TCP"
        }
      }

      "resources" = {
        "requests" = {
          "cpu"    = "100m"
          "memory" = "200Mi"
        }
        "limits" = {
          "cpu"    = "200m"
          "memory" = "500Mi"
        }
      }

      probes = {
        liveness = {
          protocol              = "http_get"
          port                  = "3000"
          http_get_path         = "/auth/health"
          initial_delay_seconds = 30
          period_seconds        = 10
          timeout_seconds       = 5
        }
      }
    }
  ]

  apply_default_liveness_probe = true
  liveliness_probe_port        = "3000"

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
        "target_port" = 3000
      }
    }
    type = "LoadBalancer"
  }
  # gpu_toleration = true
}

