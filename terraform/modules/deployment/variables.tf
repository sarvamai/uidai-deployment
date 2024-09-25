variable "name" {
  type        = string
  nullable    = false
  description = "Name of the service"
}


variable "namespace" {
  type    = string
  default = null
}

variable "deployment_name" {
  type        = string
  nullable    = true
  default     = null
  description = "Name of the deployment"
}


variable "labels" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "labels for the deployment"
}

variable "match_labels" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "labels used to find pods matching the deployment"
}

variable "pod_labels" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "labels for pods in the deployment"
}


variable "node_selector_labels" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "labels for selecting nodes to schedule pods of the deployment"
}

variable "service_account" {
  type        = string
  description = "service account to be used by the deployment."
}

variable "containers" {
  type = list(object({
    name              = string
    image             = string
    image_pull_policy = optional(string)
    command           = optional(list(string))
    args              = optional(list(string))
    env_from = map(object({
      source = string
    }))
    env_vars = map(object({
      value = optional(string)
      ref = optional(object({
        source = string
        name   = string
        key    = optional(string)
      }))
    }))
    ports = optional(map(object({
      protocol       = optional(string)
      container_port = number
    })))
    resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
    volume_mounts = optional(map(object({
      name      = string
      read_only = optional(bool)
    })))
    probes = optional(map(object({
      protocol              = string # http_get / grpc
      port                  = number
      http_get_path         = optional(string)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    })))

  }))

  description = "values for the containers in the deployment. For grpc, http_get probes, the key can be liveness, readiness or startup"
}

variable "apply_default_liveness_probe" {
  type        = bool
  default     = false
  nullable    = false
  description = "apply a default liveness probe, if none is given"
}

variable "liveliness_probe_port" {
  type        = string
  default     = "8080"
  nullable    = false
  description = "port to be used for liveness probe"
}

variable "memory_volume_def" {
  type = map(object({
    name = string
    size = optional(string)
  }))
  nullable = false
  default  = {}
}

variable "pvc_volume_name" {
  type     = string
  nullable = true
  default = ""
}

variable "pvc_volume_def" {
  type = map(object({
    read_only = optional(bool)
  }))
  nullable = false
  default  = {}
}

variable "replicas" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of replicas for the deployment when no hpa is specified"
}

variable "hpa" {
  type = object({
    max_replicas = number
    min_replicas = number

    scale_target_ref = optional(object({
      kind = string
      name = string
    }))

    external_metrics = optional(object({
      name         = string
      match_labels = optional(map(string))
      target_type  = string
      target_value = number
    }))

    pod_scale_up = optional(object({
      value          = number
      period_seconds = number
    }))

    pod_scale_down = optional(object({
      value          = number
      period_seconds = number
    }))

    resource_metrics = optional(list(object({
      name         = string
      target_type  = string
      target_value = number
    })))

  })
  default     = null
  description = "horizontal pod accelerator for deployment"
}

variable "kube_service_config" {
  type = object({
    name      = optional(string)
    namespace = optional(string)
    selectors = optional(map(string))
    type      = optional(string)
    ports = map(object({
      port        = number
      protocol    = optional(string)
      target_port = any
    }))
    ilb_subnet_name = optional(string)
  })
  default = null
}

variable "gpu_toleration" {
  type     = bool
  nullable = false
  default  = false
}

variable "prometheus_annotations" {
  type        = map(string)
  description = "Prometheus-specific annotations for the deployment"
  default     = {}
}

variable "pod_termination_grace_period_seconds" {
  default  = 90
  nullable = true
  type     = number

  validation {
    condition     = var.pod_termination_grace_period_seconds >= 30
    error_message = "pod_termination_grace_period_seconds must be greater than or equal to 30"
  }

}
