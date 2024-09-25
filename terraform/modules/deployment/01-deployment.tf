locals {
  deployment_name = coalesce(var.deployment_name, "${var.name}")

  labels = merge({
    "app.kubernetes.io/name" = var.name
  }, var.labels)
  match_labels = merge({
    "app.kubernetes.io/name" = var.name
  }, var.match_labels)
  node_selector_labels = var.node_selector_labels
  pod_labels = merge({
    "app.kubernetes.io/name"      = var.name
    "azure.workload.identity/use" = "true"
  }, var.pod_labels)

  default_liveness_probe = var.apply_default_liveness_probe ? [{
    protocol              = "http_get"
    port                  = var.liveliness_probe_port
    http_get_path         = "/health"
    initial_delay_seconds = 30
    period_seconds        = 10
    timeout_seconds       = 5
  }] : []

  replicas = var.hpa == null ? tostring(coalesce(var.replicas, 1)) : null
}


# TODO: add workload identity
resource "kubernetes_deployment_v1" "deploy" {
  metadata {
    # metadata applies to the entire deployment
    name      = local.deployment_name
    namespace = var.namespace
    labels    = local.labels
  }


  spec {
    # spec applies to the pods created by the deployment

    # how many pods?
    replicas = local.replicas
    # how do we find them?
    selector {
      match_labels = local.match_labels
    }

    # the template to be used while creating the pods
    template {

      # the labels to be applied to the pods (could be different from the deployment labels, but we keep them same)
      metadata {
        labels      = local.pod_labels
        annotations = var.prometheus_annotations
      }

      # a pod can contain multiple containers, within the spec
      # at this point we have only one container per service
      spec {

        # the kubernetes service account to be used by the pod
        service_account_name = var.service_account

        # what nodes should the pod be scheduled on
        node_selector = local.node_selector_labels

        termination_grace_period_seconds = var.pod_termination_grace_period_seconds

        dynamic "volume" {
          for_each = var.memory_volume_def

          content {
            empty_dir {
              medium     = volume.value.medium
              size_limit = volume.value.size_limit
            }
          }
        }

        dynamic "volume" {
          for_each = var.pvc_volume_def
          content {
            name = var.pvc_volume_name
            persistent_volume_claim {
              claim_name = volume.key
              read_only  = volume.value.read_only
            }
          }
        }

        dynamic "toleration" {
          for_each = var.gpu_toleration ? toset(["1"]) : toset([])

          # Allow scheduling this job on gpu nodes
          # TODO: for GCP this is : nvidia.com/gpu:NoSchedule op=Exists 
          # The following works for Azure only
          content {
            key      = "sku"
            operator = "Equal"
            value    = "gpu"
            effect   = "NoSchedule" # this is strictly not necessary, and if missing all effects are tolerated
          }
        }

        # container to be deployed within the pod
        dynamic "container" {
          for_each = var.containers

          content {
            name  = container.value.name
            image = container.value.image

            lifecycle {
              pre_stop {
                exec {
                  command = ["sleep",var.pod_termination_grace_period_seconds - 10]
                }
              }
            }

            dynamic "env_from" {
              for_each = { for k, v in container.value.env_from : k => v if v.source == "configMapRef" }
              content {
                config_map_ref {
                  name = env_from.key
                }
              }
            }

            dynamic "env_from" {
              for_each = { for k, v in container.value.env_from : k => v if v.source == "secretRef" }
              content {
                secret_ref {
                  name = env_from.key
                }
              }
            }

            dynamic "env" {
              for_each = { for k, v in container.value.env_vars : k => v if v.value == null && v.ref != null && try(v.ref.source, null) == "secretKeyRef" }
              content {
                name = env.key
                value_from {
                  secret_key_ref {
                    name = env.value.ref.name
                    key  = env.value.ref.key
                  }
                }
              }
            }

            dynamic "env" {
              for_each = { for k, v in container.value.env_vars : k => v if v.value == null && v.ref != null && try(v.ref.source, null) == "configMapKeyRef" }
              content {
                name = env.key
                value_from {
                  config_map_key_ref {
                    name = env.value.ref.name
                    key  = env.value.ref.key
                  }
                }
              }
            }


            dynamic "env" {
              for_each = { for k, v in container.value.env_vars : k => v if v.value != null }
              content {
                name  = env.key
                value = env.value.value
              }
            }

            resources {
              limits   = try(container.value.resources.limits, null)
              requests = try(container.value.resources.requests, null)
            }

            dynamic "port" {
              for_each = coalesce(container.value.ports, {})

              content {
                protocol       = port.value.protocol
                container_port = port.value.container_port
              }
            }

            dynamic "volume_mount" {
              for_each = coalesce(container.value.volume_mounts, {})

              content {
                mount_path = volume_mount.key
                name       = volume_mount.value.name
                read_only  = volume_mount.value.read_only
              }
            }

            dynamic "liveness_probe" {
              for_each = try(container.value.probes["liveness"], null) != null ? toset([container.value.probes["liveness"]]) : toset(local.default_liveness_probe)

              content {
                dynamic "http_get" {
                  for_each = liveness_probe.value.protocol == "http_get" ? toset(["1"]) : toset([])
                  content {
                    path = liveness_probe.value.http_get_path
                    port = liveness_probe.value.port
                  }
                }

                dynamic "grpc" {
                  for_each = liveness_probe.value.protocol == "grpc" ? toset(["1"]) : toset([])
                  content {
                    port = liveness_probe.value.port
                  }
                }

                initial_delay_seconds = liveness_probe.value.initial_delay_seconds
                period_seconds        = liveness_probe.value.period_seconds
                timeout_seconds       = liveness_probe.value.timeout_seconds
              }
            }

            dynamic "readiness_probe" {
              for_each = try(container.value.probes["readiness"], null) != null ? toset(["1"]) : toset([])

              content {
                dynamic "http_get" {
                  for_each = container.value.probes["readiness"].protocol == "http_get" ? toset(["1"]) : toset([])
                  content {
                    path = container.value.probes["readiness"].http_get_path
                    port = container.value.probes["readiness"].port
                  }
                }

                dynamic "grpc" {
                  for_each = container.value.probes["readiness"].protocol == "grpc" ? toset(["1"]) : toset([])
                  content {
                    port = container.value.probes["readiness"].port
                  }
                }

                initial_delay_seconds = container.value.probes["readiness"].initial_delay_seconds
                period_seconds        = container.value.probes["readiness"].period_seconds
                timeout_seconds       = container.value.probes["readiness"].timeout_seconds
              }
            }

            dynamic "startup_probe" {
              for_each = try(container.value.probes["startup"], null) != null ? toset(["1"]) : toset([])

              content {
                dynamic "http_get" {
                  for_each = container.value.probes["startup"].protocol == "http_get" ? toset(["1"]) : toset([])
                  content {
                    path = container.value.probes["startup"].http_get_path
                    port = container.value.probes["startup"].port
                  }
                }

                dynamic "grpc" {
                  for_each = container.value.probes["startup"].protocol == "grpc" ? toset(["1"]) : toset([])
                  content {
                    port = container.value.probes["startup"].port
                  }
                }

                initial_delay_seconds = container.value.probes["startup"].initial_delay_seconds
                period_seconds        = container.value.probes["startup"].period_seconds
                timeout_seconds       = container.value.probes["startup"].timeout_seconds
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations["kubectl.kubernetes.io/restartedAt"],
    ]
  }

}

