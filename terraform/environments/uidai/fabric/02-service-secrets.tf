module "auth_shared_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-shared-secrets"
  namespaces = [var.fabric_namespace]
  generated_data = [
    "TOKEN_JWT_SECRET_ACCESS_KEY"
  ]
}


module "auth_service_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-service-secrets"
  namespaces = [var.fabric_namespace]
  generated_data = [
    "FIRST_USER_PASSWORD",
    "TOKEN_JWT_SECRET_REFRESH_KEY"
  ]
}
