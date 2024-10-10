# # TODO: Remove this
# module "hugging_face_secret" {
#   source = "../../../modules/secrets"

#   name       = "hugging-face-secret"
#   namespaces = ["default"]
#   data = {
#     "HUGGING_FACE_HUB_TOKEN" = {
#       value = ""
#     }
#   }
# }

# # TODO: Remove this
# module "azure_storage_secret" {
#   source = "../../../modules/secrets"

#   name       = "azure-storage-secret"
#   namespaces = ["default"]
#   data = {
#     "AZURE_CLIENT_ID" = {
#       value = ""
#     }
#     "AZURE_TENANT_ID" = {
#       value = ""
#     }
#     "AZURE_CLIENT_SECRET" = {
#       value = ""
#     }
#   }
# }

# # TODO: Remove this
# module "github_access_token" {
#   source     = "../../../modules/secrets"
#   name       = "github-access-token"
#   namespaces = ["default"]
#   data = {
#     "GITHUB_ACCESS_TOKEN" = {
#       value = ""
#     }
#   }
# }