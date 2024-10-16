locals {

  auth_service_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
    "auth-postgres-db-env" = {
      "source" = "configMapRef"
    }
    "auth-postgres-db-secrets" = {
      "source" = "secretRef"
    }
  }

  auth_service_env_vars = {
    "BASE_LOGIN_URL" = {
      "value" = "http://auth-service/api/auth/form-login"
    }
    "BASE_ROOT_PATH" = {
      "ref"   = null /* object */
      "value" = "/api/auth"
    }
    "DATABASE_NAME" = {
      "ref"   = null /* object */
      "value" = "auth-db"
    }
    "FIRST_USER_CREATE" = {
      "ref"   = null /* object */
      "value" = "true"
    }
    "TOKEN_JWT_SECRET_ACCESS_KEY" = {
      "ref" = {
        "key"    = "TOKEN_JWT_SECRET_ACCESS_KEY"
        "name"   = "auth-shared-secrets"
        "source" = "secretKeyRef"
      }
      "value" = tostring(null)
    }
    "TOKEN_JWT_SECRET_REFRESH_KEY" = {
      "ref" = {
        "key"    = "TOKEN_JWT_SECRET_REFRESH_KEY"
        "name"   = "auth-service-secrets"
        "source" = "secretKeyRef"
      }
      "value" = tostring(null)
    }
    "FIRST_USER_PASSWORD" = {
      "ref" = {
        "key"    = "FIRST_USER_PASSWORD"
        "name"   = "auth-service-secrets"
        "source" = "secretKeyRef"
      }
      "value" = tostring(null)
    }
    "TOKEN_ACCESS_TOKEN_EXPIRE_MINUTES" = {
      "ref"   = null /* object */
      "value" = "10080" # 7 days
    }
  }
}

module "auth_service" {
  source = "../../../modules/deployment"

  name                 = "auth-service"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  node_selector_labels = var.node_selector_labels

  containers = [
    {
      "env_from"          = local.auth_service_env_from
      "env_vars"          = local.auth_service_env_vars
      "image"             = "${var.docker_registry_name_sarvam}/auth-service:v0.3.5"
      "image_pull_policy" = "Always"
      "name"              = "auth-service"
      "ports" = {
        "http" = {
          "container_port" = 8080
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
    "type" = "LoadBalancer"
  }

  gpu_toleration = true
}

