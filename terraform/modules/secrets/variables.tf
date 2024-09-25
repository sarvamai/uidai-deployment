
variable "name" {
  type        = string
  nullable    = false
  description = "name of the config map"
}

variable "namespaces" {
  type        = list(string)
  nullable    = false
  description = "Namespace where configmap is to be created"
}

variable "data" {
  type = map(object({
    value = optional(string)
  }))
  nullable    = false
  default     = {}
  description = "Data to be stored in the config map"
}


variable "generated_data" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Data to be stored in the config map"
}
