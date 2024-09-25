
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
  type        = map(string)
  nullable    = false
  description = "Data to be stored in the config map"
}
