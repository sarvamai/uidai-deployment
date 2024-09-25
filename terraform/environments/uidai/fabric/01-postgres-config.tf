module "kb_postgres_db_env" {
  source = "../../../modules/config-maps"

  name       = "kb-postgres-db-env"
  namespaces = ["default"]
  data = {
    "DATABASE_HOST" = var.kb_postgres_host
    "DATABASE_PORT" = var.kb_postgres_port
    "DATABASE_USER" = var.kb_postgres_user
  }
}

module "kb_postgres_db_secrets" {
  source = "../../../modules/secrets"

  name       = "kb-postgres-db-secrets"
  namespaces = ["default"]
  data = {
    "DATABASE_PASSWORD" = {
      "value" = var.kb_postgres_password
    }
  }
}

module "auth_postgres_db_env" {
  source = "../../../modules/config-maps"

  name       = "auth-postgres-db-env"
  namespaces = ["default"]
  data = {
    "DATABASE_HOST" = var.auth_postgres_host
    "DATABASE_PORT" = var.auth_postgres_port
    "DATABASE_USER" = var.auth_postgres_user
  }
}

module "auth_postgres_db_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-postgres-db-secrets"
  namespaces = ["default"]
  data = {
    "DATABASE_PASSWORD" = {
      "value" = var.auth_postgres_password
    }
  }
}
