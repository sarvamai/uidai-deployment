module "weaviate_env" {
  source = "../../../modules/config-maps"

  name       = "weaviate-env"
  namespaces = ["default"]
  data = {
    "weaviate-url" = "http://weaviate.default"
  }
}
