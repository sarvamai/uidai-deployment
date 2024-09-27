locals {

  kb_common_env_vars = [
    "TOKEN_JWT_SECRET_ACCESS_KEY"
  ]

  kb_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
    "kb-postgres-db-env" = {
      "source" = "configMapRef"
    }
    "kb-postgres-db-secrets" = {
      "source" = "secretRef"
    }
    "redis-env" = {
      "source" = "configMapRef"
    }
    "redis-secrets" = {
      "source" = "secretRef"
    }
  }

  kb_env_vars = merge(
    { for k, v in local.kb_common_env_vars : v => local.global_env_vars[v] },
    {
      "LOG_LEVEL" = {
        "value" = "DEBUG"
      }
      "OPENAI_API_KEY" = {
        value = ""
      }
      "BASE_LOGIN_URL" = {
        "value" = "http://kb-service/api/kb/form-login"
      }
      "BASE_ROOT_PATH" = {
        "value" = "/api/kb"
      }
      "CELERY_BROKER_DB" = {
        "value" = "0"
      }
      "CELERY_BROKER_URL" = {
        "value" = "$(REDIS_URL_PREFIX)/$(CELERY_BROKER_DB)"
      }
      "CELERY_BACKEND_DB" = {
        "value" = "1"
      }
      "CELERY_BACKEND_URL" = {
        "value" = "$(REDIS_URL_PREFIX)/$(CELERY_BACKEND_DB)"
      }
      "DATABASE_NAME" = {
        "value" = "kb-db"
      }
      "HOSTED_EMBEDDING_URL" = {
        "ref" = {
          "key"    = "HOSTED_EMBEDDING_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "HOSTED_RERANKING_URL" = {
        "ref" = {
          "key"    = "HOSTED_RERANKING_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "KB_STORAGE_PATH" = {
        "value" = var.kb_storage_path
      }
      "WEAVIATE_URL" = {
        "ref" = {
          "key"    = "weaviate-url"
          "name"   = "weaviate-env"
          "source" = "configMapKeyRef"
        }
      }
      "HUGGINGFACE_HUB_TOKEN" = {
        "value" = ""
      }

  })

  kb_worker_env_vars = merge(local.kb_env_vars,
    {
      "ROLE" = {
        "value" = "worker"
      }
  })

  kb_query_service_env_vars = merge(local.kb_env_vars,
    {
      "ROLE" = {
        "value" = "query-service"
      }
  })

}


module "knowledge_base_authoring_service" {
  source = "../../../modules/deployment"

  name                 = "knowledge-base-authoring-service"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  node_selector_labels = var.node_selector_labels

  containers = [{
    "name"              = "knowledge-base-authoring-service"
    "env_from"          = local.kb_env_from
    "env_vars"          = local.kb_env_vars
    "image"             = "${var.docker_registry_name}/knowledge-base-service"
    "image_pull_policy" = "Always"
    "ports" = {
      "http" = {
        "container_port" = 8080
        "port"           = 80
        "protocol"       = "TCP"
      }
    }
  }]

  hpa = {
    "max_replicas" = 3
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
      "http" = {
        "port"        = 80
        "target_port" = 8080
      }
    }
    type = "ClusterIP"
  }

  gpu_toleration = true

}


module "knowledge_base_authoring_service_worker" {
  source = "../../../modules/deployment"

  name                 = "knowledge-base-service-worker"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  node_selector_labels = var.node_selector_labels

  containers = [{
    "name"              = "knowledge-base-service-worker"
    "env_from"          = local.kb_env_from
    "env_vars"          = local.kb_worker_env_vars
    "image"             = "${var.docker_registry_name}/knowledge-base-service"
    "image_pull_policy" = "Always"
    "resources" = {
      "requests" = {
        "cpu"    = "500m"
        "memory" = "1500Mi"
      }
      "limits" = {
        "cpu"    = "1000m"
        "memory" = "3000Mi"
      }
    }
  }]

  hpa = {
    "max_replicas" = 3
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
  gpu_toleration = true

}


module "knowledge_base_runtime_service" {
  source = "../../../modules/deployment"

  name                 = "knowledge-base-service"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  node_selector_labels = var.node_selector_labels

  containers = [{
    "name"              = "knowledge-base-service"
    "env_from"          = local.kb_env_from
    "env_vars"          = local.kb_query_service_env_vars
    "image"             = "${var.docker_registry_name}/knowledge-base-service"
    "image_pull_policy" = "Always"
    "ports" = {
      "http" = {
        "container_port" = 8080
        "port"           = 80
        "protocol"       = "TCP"
      }
    }

    "resources" = {
      "requests" = {
        "cpu"    = "500m"
        "memory" = "1500Mi"
      }
      "limits" = {
        "cpu"    = "1000m"
        "memory" = "3000Mi"
      }
    }
  }]

  hpa = {
    "max_replicas" = 10
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
      "http" = {
        "port"        = 80
        "target_port" = 8080
      }
    }
    type = "ClusterIP"
  }

  gpu_toleration = true
}

