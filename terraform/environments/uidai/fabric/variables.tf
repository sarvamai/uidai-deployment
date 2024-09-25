# KB POSTGRES

variable "kb_postgres_host" {
  type    = string
  default = "kb-postgres-service"
}

variable "kb_postgres_port" {
  type    = string
  default = "5432"
}

variable "kb_postgres_user" {
  type    = string
  default = "postgres"
}

variable "kb_postgres_password" {
  sensitive = true
  default   = "password"
}

# AUTH POSTGRES

variable "auth_postgres_host" {
  type    = string
  default = "auth-postgres-service"
}

variable "auth_postgres_port" {
  type    = string
  default = "5432"
}

variable "auth_postgres_user" {
  type    = string
  default = "postgres"
}

variable "auth_postgres_password" {
  sensitive = true
  default   = "password"
}

# REDIS

variable "redis_host" {
  type    = string
  default = "redis-service"
}

variable "redis_port" {
  type    = string
  default = "6379"
}
variable "redis_tls" {
  type    = string
  default = "false"
}

variable "redis_url_prefix" {
  type    = string
  default = "redis://:password@redis-service:6379"
}

variable "redis_password" {
  sensitive = true
  default   = "password"
}

# TODO: Docker Image 
variable "docker_registry_name" {
  type    = string
  default = "uidaimodels.azurecr.io"
}

variable "fabric_namespace" {
  type    = string
  default = "default"
}

variable "fabric_service_account" {
  type    = string
  default = "default"
}

variable "models_namespace" {
  type    = string
  default = "default"
}