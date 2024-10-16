locals {

  sarvam_v2v_web_ui_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
  }

  sarvam_v2v_web_ui_env_vars = {
    "GOOGLE_API_KEY" = {
      "value" = ""
    }
    "GOOGLE_CSE_ID" = {
      "value" = ""
    }
    "NEXTAUTH_BASE_PATH" = {
      "ref"   = null /* object */
      "value" = "/api/authentication"
    }
    "NEXTAUTH_SECRET" = {
      "value" = "VoNoeL47YPHlsd02mCG1KlXOFdJJqHyTR2GjEJL/A7w="
    }
    "NEXTAUTH_URL" = {
      "value" = "http://4.157.157.99/api/authentication"
    }
    "SARVAM_APP_RUNTIME_HTTP_URL" = {
      "value" = "http://auth-service"
    }
    "SARVAM_APP_RUNTIME_WS_URL" = {
      "ref"   = null /* object */
      "value" = "ws://10.10.109.28:31983/channels/web-call-custom-auth"
    }
    "TOGGLE_AUTH" = {
      "ref"   = null /* object */
      "value" = "true"
    }
    "TOGGLE_VAD" = {
      "ref"   = null /* object */
      "value" = "false"
    }
    "CLIENT_INTERRUPT" = {
      "ref"   = null /* object */
      "value" = "true"
    }
    "RECORDING_GAIN_VALUE" = {
      "ref"   = null /* object */
      "value" = "1"
    }
    "PLAYBACK_VOLUME_LOW" = {
      "ref"   = null /* object */
      "value" = "0.5"
    }
    "PLAYBACK_VOLUME_HIGH" = {
      "ref"   = null /* object */
      "value" = "1.0"
    }
  }

}

module "sarvam_v2v_web_ui" {
  source = "../../../modules/deployment"

  name                 = "sarvam-v2v-web-ui"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  # node_selector_labels = var.node_selector_labels

  containers = [
    {
      "env_from"          = local.sarvam_v2v_web_ui_env_from
      "env_vars"          = local.sarvam_v2v_web_ui_env_vars
      "image"             = "${var.docker_registry_name_sarvam}/sarvam-v2v-web-ui:v0.0.3-onprem"
      "image_pull_policy" = "Always"
      "name"              = "sarvam-v2v-web-ui"
      "ports" = {
        "http" = {
          "container_port" = 3000
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

  gpu_toleration = true
}

