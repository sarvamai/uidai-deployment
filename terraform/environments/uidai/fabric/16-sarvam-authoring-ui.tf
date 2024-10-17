locals {

  sarvam_authoring_ui_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
  }

  sarvam_authoring_ui_env_vars = {
    "SARVAM_BASE_URL" = {
      "value" = "http://4.157.157.106/api"
    }
    "SARVAM_KB_URL" = {
      "value" = "http://48.216.162.2"
    }
    "SARVAM_AUTH_URL" = {
      "ref"   = null /* object */
      "value" = "http://auth-service"
    }
    "NEXTAUTH_SECRET" = {
      "value" = "VoNoeL47YPHlsd02mCG1KlXOFdJJqHyTR2GjEJL/A7w="
    }
    "NEXTAUTH_URL" = {
      value = "http://4.157.173.86/auth/api/auth"
    }
    "NEXT_AUTH_BASE_PATH" = {
      value = "/auth"
    }
    "NEXT_AUTH_URL" = {
      value = "http://4.157.157.106"
    }
    "ORG_URL" = {
      "ref"   = null /* object */
      "value" = "http://org-service"
    }
    "SARVAM_WS_BASE_URL" = {
      "value" = "ws://4.157.171.249"
    }
  }

}

module "sarvam_authoring_ui" {
  source = "../../../modules/deployment"

  name      = "sarvam-authoring-ui"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  # node_selector_labels = var.node_selector_labels
  containers = [
    {
      "env_from"          = local.sarvam_authoring_ui_env_from
      "env_vars"          = local.sarvam_authoring_ui_env_vars
      "image"             = "${var.docker_registry_name_sarvam}/sarvam-authoring-ui:v0.0.1-onprem"
      "image_pull_policy" = "Always"
      "name"              = "sarvam-authoring-ui"
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
    "type" = "LoadBalancer"
  }
  # gpu_toleration = true

}

