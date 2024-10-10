resource "kubernetes_horizontal_pod_autoscaler_v2" "main" {
  for_each = var.hpa != null ? toset(["1"]) : toset([])

  metadata {
    name      = "${var.name}-hpa"
    namespace = var.namespace
  }

  spec {
    max_replicas = var.hpa.max_replicas
    min_replicas = var.hpa.min_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = try(var.hpa.scale_target_ref.kind, "Deployment")
      name        = try(var.hpa.scale_target_ref.name, local.deployment_name)
    }

    behavior {
      dynamic "scale_down" {
        for_each = var.hpa.pod_scale_down != null ? toset(["1"]) : toset([])

        content {
          select_policy = "Max"
          policy {
            type           = "Pods"
            value          = var.hpa.pod_scale_down.value
            period_seconds = var.hpa.pod_scale_down.period_seconds
          }
        }
      }

      dynamic "scale_up" {
        for_each = var.hpa.pod_scale_up != null ? toset(["1"]) : toset([])

        content {
          select_policy = "Max"
          policy {
            type           = "Pods"
            value          = var.hpa.pod_scale_up.value
            period_seconds = var.hpa.pod_scale_up.period_seconds
          }
        }
      }
    }


    dynamic "metric" {
      for_each = try(var.hpa.external_metrics, null) != null ? toset(["1"]) : toset([])

      content {
        type = "External"
        external {
          metric {
            name = var.hpa.external_metrics.name
            selector {
              match_labels = var.hpa.external_metrics.match_labels
            }
          }
          target {
            type  = var.hpa.external_metrics.target_type
            value = var.hpa.external_metrics.target_value
          }
        }
      }
    }

    dynamic "metric" {
      for_each = var.hpa.resource_metrics != null ? var.hpa.resource_metrics : []
      content {
        type = "Resource"
        resource {
          name = metric.value.name
          target {
            type                = metric.value.target_type
            average_utilization = metric.value.target_type == "Utilization" ? metric.value.target_value : null
            average_value       = metric.value.target_type == "AverageValue" ? metric.value.target_value : null
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.deploy]
}



