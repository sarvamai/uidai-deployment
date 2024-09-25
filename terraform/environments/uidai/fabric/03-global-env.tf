locals {
  global_env_vars = {
    depends_on = [
      module.auth_shared_secrets,
    ]
    "TOKEN_JWT_SECRET_ACCESS_KEY" = {
      "ref" = {
        "key"    = "TOKEN_JWT_SECRET_ACCESS_KEY"
        "name"   = "auth-shared-secrets"
        "source" = "secretKeyRef"
      }
      "value" = tostring(null)
    }
  }
}
