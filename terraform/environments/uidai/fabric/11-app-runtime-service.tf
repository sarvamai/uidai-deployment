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
        value = "http://vllm-l3-1-sarvam-chat-tool-guard-service:8002/v1/chat/completions"
      }
      "SARVAM_OPENHATHI_URL" = {
        value = "http://vllm-l3-translation-new-service:8000/v1/chat/completions"
      }
      "SARVAM_OPENHATHI_XLIT_URL" = {
        value = "http://vllm-l3-translation-new-service:8002/v1/chat/completions"
      }
      "SARVAM_TTS_URL" = {
        value = "riva-combined-dev-service:8000"
      }
      "SARVAM_LLM_URL" = {
        "value" = "http://nim-llama3-1-8b-service:8000/v1/chat/completions"
      }
      "SARVAM_LLM_LLAMA_3_1_8B_URL" = {
        "value" = "http://nim-llama3-1-8b-service:8000/v1/chat/completions"
      }
      "SARVAM_LLM_LLAMA_3_1_70B_URL" = {
        "value" = "http://nim-llama3-1-8b-service:8000/v1/chat/completions"
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
        "value" = "/mnt/pvc/app-storage/apps"
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
        "value" = "riva-combined-dev-service:8000"
      }
      "EXOTEL_START_SPEECH_VOLUME_THRESHOLD" = {
        "value" = -29
      }
      "EXOTEL_FIRST_TURN_MIN_SPEECH_FRAMES" = {
        "value" = 5
      }
  })

}

module "sarvam_app_runtime_svc" {
  source = "../../../modules/deployment"

  name            = "sarvam-app-runtime-service"
  namespace       = "default"
  service_account = "default"
  containers = [{
    "env_from"          = local.sarvam_app_runtime_env_from
    "env_vars"          = local.sarvam_app_runtime_env_vars
    "image"             = "gitopsdocker.azurecr.io/sarvam-app-runtime-service:latest"
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
        "memory" = "1Gi"
      }
      "limits" = {
        "cpu"    = "200m"
        "memory" = "2Gi"
      }
    }
    volume_mounts = {
      "/mnt/pvc" = {
        "name"      = "shared-pvc"
        "read_only" = false
      }
    }
  }]

  replicas = 1

  pvc_volume_name = "shared-pvc"

  pvc_volume_def = {
    "local-storage-pvc" = {
      read_only = false
    }
  }

  kube_service_config = {
    "ports" = {
      "http" = {
        "port"        = 80
        "target_port" = 8080
      }
    }
    type = "LoadBalancer"
  }
  gpu_toleration = true

}
