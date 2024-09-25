module "weaviate_env" {
  source = "../../../modules/config-maps"

  name       = "weaviate-env"
  namespaces = [var.fabric_namespace]
  data = {
    "weaviate-url" = "http://weaviate.${var.fabric_namespace}"
  }
}
