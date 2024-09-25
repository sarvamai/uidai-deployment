module "redis_config_maps" {
  source = "../../../modules/config-maps"

  name       = "redis-env"
  namespaces = ["default"]
  data = {
    "REDIS_HOST" = "redis-service"
    "REDIS_PORT" = 6379
    "REDIS_TLS"  = "false"
  }
}

module "redis_secrets" {
  source = "../../../modules/secrets"

  name       = "redis-secrets"
  namespaces = ["default"]
  data = {
    "REDIS_PASSWORD" = {
      "value" = "password"
    }
    "REDIS_URL_PREFIX" = {
      "value" = "redis://:password@redis-service:6379"
    }
  }
}
