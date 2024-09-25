
resource "kubernetes_config_map_v1" "main" {
  for_each = toset(var.namespaces)

  metadata {
    name      = var.name
    namespace = each.key
  }

  data = var.data
}
