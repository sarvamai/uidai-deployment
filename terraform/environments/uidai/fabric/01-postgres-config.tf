module "kb_postgres_db_env" {
  source = "../../../modules/config-maps"

  name       = "kb-postgres-db-env"
  namespaces = ["default"]
  data = {
    "DATABASE_HOST" = "kb-postgres-service"
    "DATABASE_PORT" = 5432
    "DATABASE_USER" = "postgres"
  }
}

module "kb_postgres_db_secrets" {
  source = "../../../modules/secrets"

  name       = "kb-postgres-db-secrets"
  namespaces = ["default"]
  data = {
    "DATABASE_PASSWORD" = {
      "value" = "password"
    }
  }
}

module "auth_postgres_db_env" {
  source = "../../../modules/config-maps"

  name       = "auth-postgres-db-env"
  namespaces = ["default"]
  data = {
    "DATABASE_HOST" = "auth-postgres-service"
    "DATABASE_PORT" = 5432
    "DATABASE_USER" = "postgres"
  }
}

module "auth_postgres_db_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-postgres-db-secrets"
  namespaces = ["default"]
  data = {
    "DATABASE_PASSWORD" = {
      "value" = "password"
    }
  }
}
