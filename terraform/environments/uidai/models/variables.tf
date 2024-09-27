variable "models_service_account" {
  type    = string
  default = "default"
}

variable "models_namespace" {
  type    = string
  default = "default"
}

variable "node_selector_labels" {
  type     = map(string)
  nullable = false
  default = {
    type = "sarvam"
  }
  description = "Labels for selecting nodes to schedule pods of the deployment"
}