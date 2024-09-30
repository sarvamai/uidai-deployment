locals {
  sarvam_app_runtime_common_env_vars = [
    "TOKEN_JWT_SECRET_ACCESS_KEY",
  ]

  sarvam_app_runtime_env_from = {
    "observe-env" = {
      "source" = "configMapRef"
    }
    "redis-env" = {
      "source" = "configMapRef"
    }
    "redis-secrets" = {
      "source" = "secretRef"
    }

  }
  depends_on = [module.sarvam_vad_service]
  sarvam_app_runtime_env_vars = merge(
    { for k, v in local.sarvam_app_runtime_common_env_vars : v => local.global_env_vars[v] },
    {
      "OPENAI_API_KEY" = {
        value = ""
      }
      "SARVAM_ASR_URL" = {
        value = "speech-whisper-batched-service:8000"
      }
      "LLAMAGUARD_URL" = {
        "ref" = {
          "key"    = "LLAMAGUARD_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_OPENHATHI_URL" = {
        "ref" = {
          "key"    = "SARVAM_OPENHATHI_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_OPENHATHI_XLIT_URL" = {
        "ref" = {
          "key"    = "SARVAM_OPENHATHI_XLIT_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_TTS_URL" = {
        "ref" = {
          "key"    = "SARVAM_TTS_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_LLM_URL" = {
        "ref" = {
          "key"    = "SARVAM_LLM_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_LLM_LLAMA_3_1_8B_URL" = {
        "ref" = {
          "key"    = "SARVAM_LLM_LLAMA_3_1_8B_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_LLM_LLAMA_3_1_70B_URL" = {
        "ref" = {
          "key"    = "SARVAM_LLM_LLAMA_3_1_70B_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SILERO_VAD_URL" = {
        "ref"   = null
        "value" = "sarvam-vad-service:50051"
      }
      "MIN_SPEECH_FRAMES" = {
        "value" = 2
      }
      "OUTPUT_CHUNK_LENGTH_SIZE_MS" = {
        "value" = 800
      }
      "OUTPUT_FIRST_CHUNK_LENGTH_SIZE_MS" = {
        "value" = 200
      }
      "OUTPUT_CHUNK_LENGTH_SLEEP_PERCENTAGE" = {
        "value" = 0.1
      }
      "LOG_LEVEL" = {
        "value" = "DEBUG"
      }
      "EXOTEL_CHUNK_LENGTH_SIZE_MS" = {
        "value" = 100
      }
      "EXOTEL_FIRST_CHUNK_LENGTH_SIZE_MS" = {
        "value" = 100
      }
      "EXOTEL_CHUNK_LENGTH_SLEEP_PERCENTAGE" = {
        "value" = 0
      }
      "EXOTEL_QUEUE_CHUNK_DELAY" = {
        "value" = 100
      }
      "EXOTEL_SILENT_AUDIO_SIZE_MS" = {
        "value" = 300
      }
      "EXOTEL_QUEUE_INITIAL_CHUNKS_DELAY" = {
        "value" = 100
      }
      "COUNT_INITIAL_CHUNKS" = {
        "value" = 15
      }
      "BASE_ROOT_PATH" = {
        "value" = "/api/app-runtime"
      }
      "REDIS_DB" = {
        "value" = 6
      }
      "APP_STORAGE_URL" = {
        "value" = "https://v2vh100storage.blob.core.windows.net/on-prem-test/apps/"
      }
      "NUM_WORKERS" = {
        value = 1
      }
      "APP_BASE_URL" = {
        value = ""
      }
      "APP_BASE_WSS_URL" = {
        value = "ws://app-runtime-service/"
      }
      "KNOWLEDGE_BASE_SERVICE_URL" = {
        ref = {
          source = "configMapKeyRef"
          name   = "service-urls"
          key    = "KNOWLEDGE_BASE_SERVICE_URL"
        }
      }
      "TRITON_PROMPT_INJECTION_URL" = {
        "ref" = {
          "key"    = "TRITON_PROMPT_INJECTION_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "EXOTEL_START_SPEECH_VOLUME_THRESHOLD" = {
        "value" = -29
      }
      "EXOTEL_FIRST_TURN_MIN_SPEECH_FRAMES" = {
        "value" = 5
      }
      "SARVAM_TRANSLATE_URL" = {
        "ref" = {
          "key"    = "SARVAM_TRANSLATE_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_XLIT_URL" = {
        "ref" = {
          "key"    = "SARVAM_XLIT_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      "SARVAM_XLIT_ROMAN_URL" = {
        "ref" = {
          "key"    = "SARVAM_XLIT_ROMAN_URL"
          "name"   = local.model_urls_configmap_name
          "source" = "configMapKeyRef"
        }
      }
      # "SARVAM_LLM_LLAMA_3_1_8B_HF_NAME" = {
      #   "value" = "/ext-mnt/trt_engines/Meta-Llama-3.1-8B-Instruct-a100-bf16-mxbsz96-isl2048-seq4096/bf16/1-gpu/"
      # }
      # "SARVAM_LLM_LLAMA_3_1_70B_HF_NAME" = {
      #   "value" = "/ext-mnt/trt_engines/Meta-Llama-3.1-70B-Instruct-a100-bf16-mxbsz96-isl2048-seq4096/bf16/1-gpu/"
      # }
  })

}

module "sarvam_app_runtime_svc" {
  source = "../../../modules/deployment"

  name                 = "sarvam-app-runtime-service"
  namespace            = var.fabric_namespace
  service_account      = var.fabric_service_account
  node_selector_labels = var.node_selector_labels
  
  containers = [{
    "env_from"          = local.sarvam_app_runtime_env_from
    "env_vars"          = local.sarvam_app_runtime_env_vars
    "image"             = "${var.docker_registry_name}/sarvam-app-runtime-service:v0.1.35"
    "image_pull_policy" = "Always"
    "name"              = "sarvam-app-runtime-service"
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
        "memory" = "2Gi"
      }
      "limits" = {
        "cpu"    = "200m"
        "memory" = "4Gi"
      }
    }
  }]


  hpa = {
    "max_replicas" = 3
    "min_replicas" = 3
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
