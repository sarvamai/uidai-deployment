module "redis_config_maps" {
  source = "../../../modules/config-maps"

  name       = "redis-env"
  namespaces = [var.fabric_namespace]
  data = {
    "REDIS_HOST" = var.redis_host
    "REDIS_PORT" = var.redis_port
    "REDIS_TLS"  = var.redis_tls
  }
}

module "redis_secrets" {
  source = "../../../modules/secrets"

  name       = "redis-secrets"
  namespaces = [var.fabric_namespace]
  data = {
    "REDIS_PASSWORD" = {
      "value" = var.redis_password
    }
    "REDIS_URL_PREFIX" = {
      "value" = var.redis_url_prefix
    }
  }
}
