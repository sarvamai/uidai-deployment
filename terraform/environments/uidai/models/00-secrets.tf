module "hugging_face_secret" {
  source = "../../../modules/secrets"

  name       = "hugging-face-secret"
  namespaces = ["default"]
  data = {
    "HUGGING_FACE_HUB_TOKEN" = {
      value = "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"
    }
  }
}

module "azure_storage_secret" {
  source = "../../../modules/secrets"

  name       = "azure-storage-secret"
  namespaces = ["default"]
  data = {
    "AZURE_CLIENT_ID" = {
      value = "d3217e32-9d02-4d3a-aef4-5c433ce9527e"
    }
    "AZURE_TENANT_ID" = {
      value = "d1338f9b-2c29-4ab4-b3f2-ffd01533d16f"
    }
    "AZURE_CLIENT_SECRET" = {
      value = "kol8Q~JFCLZVl_cavim4YlNrEcSD7oQm96K2TdCr"
    }
  }
}

module "github_access_token" {
  source     = "../../../modules/secrets"
  name       = "github-access-token"
  namespaces = ["default"]
  data = {
    "GITHUB_ACCESS_TOKEN" = {
      value = "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"
    }
  }
}
