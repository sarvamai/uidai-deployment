module "runtime_service_urls" {
  source = "../../../modules/config-maps"

  name       = "service-urls"
  namespaces = ["default"]
  data = {
    KNOWLEDGE_BASE_SERVICE_URL           = "http://knowledge-base-service"
    KNOWLEDGE_BASE_SERVICE_AUTHORING_URL = "http://knowledge-base-authoring-service"
    APP_AUTHORING_SERVICE_URL            = "http://sarvam-app-authoring-service"
  }
}
