locals {
  model_urls_configmap_name = "on-prem-model-urls"
}

module "runtime_service_urls" {
  source = "../../../modules/config-maps"

  name       = "service-urls"
  namespaces = [var.fabric_namespace]
  data = {
    KNOWLEDGE_BASE_SERVICE_URL           = "http://knowledge-base-service"
    KNOWLEDGE_BASE_SERVICE_AUTHORING_URL = "http://knowledge-base-authoring-service"
    APP_AUTHORING_SERVICE_URL            = "http://sarvam-app-authoring-service"
  }
}

module "on_prem_model_urls" {
  source = "../../../modules/config-maps"

  name       = "on-prem-model-urls"
  namespaces = ["default"]
  data = {
    HOSTED_EMBEDDING_URL         = "speech-tts-nemo-service.${var.models_namespace}:8000"
    HOSTED_RERANKING_URL         = "speech-tts-nemo-service.${var.models_namespace}:8000"
    SARVAM_ASR_URL               = "speech-whisper-batched-service.${var.models_namespace}:8000"
    LLAMAGUARD_URL               = "http://vllm-llama-gaurd-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_OPENHATHI_URL         = "http://vllm-l3-translation-new-servic.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_OPENHATHI_XLIT_URL    = "http://vllm-pre-tts-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_TTS_URL               = "speech-tts-nemo-service.${var.models_namespace}:8000"
    SARVAM_LLM_URL               = "http://nim-llama3-1-8b-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_LLM_LLAMA_3_1_8B_URL  = "http://nim-llama3-1-8b-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_LLM_LLAMA_3_1_70B_URL = "http://nim-llama3-1-8b-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_TRANSLATE_URL         = "http://vllm-l3-translation-new-service.${var.models_namespace}:8000/v1/chat/completions"
    SARVAM_XLIT_URL              = "http://vllm-pre-tts-service.${var.models_namespace}:8000/v1/chat/completions"
    TRITON_PROMPT_INJECTION_URL  = "speech-tts-nemo-service.${var.models_namespace}:8000"
    SARVAM_XLIT_ROMAN_URL        = ""
  }
}
