
resource "kubernetes_service_v1" "main" {
  for_each = var.kube_service_config != null ? toset(["1"]) : toset([])

  metadata {
    name      = coalesce(var.kube_service_config.name, var.name)
    namespace = coalesce(var.kube_service_config.namespace, var.namespace)
  }
  spec {
    selector = coalesce(var.kube_service_config.selectors, {
      "app.kubernetes.io/name" = var.name
    })

    dynamic "port" {
      for_each = var.kube_service_config.ports

      content {
        name        = port.key
        protocol    = coalesce(port.value.protocol, "TCP")
        port        = port.value.port
        target_port = port.value.target_port
      }
    }

    type = coalesce(var.kube_service_config.type, "ClusterIP")
  }
}
