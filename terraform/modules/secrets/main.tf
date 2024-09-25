
resource "random_pet" "main" {
  for_each = toset(var.generated_data)
}

locals {
  data = merge(
    { for k, v in var.data : k => v.value },
    { for k in var.generated_data : k => random_pet.main[k].id },
  )
}


resource "kubernetes_secret_v1" "main" {
  for_each = toset(var.namespaces)

  metadata {
    name      = var.name
    namespace = each.key
  }

  data = local.data
}
