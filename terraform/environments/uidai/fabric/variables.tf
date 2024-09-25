# POSTGRES

variable "postgres_host" {
  type    = string
  default = ""
}

variable "postgres_port" {
  type    = string
  default = ""
}

variable "postgres_user" {
  type    = string
  default = ""
}

variable "postgres_password" {
  sensitive = true
  default   = ""
}

# REDIS

variable "redis_host" {
  type    = string
  default = ""
}

variable "redis_ssl_port" {
  type    = string
  default = ""
}

variable "redis_url_prefix" {
  type    = string
  default = ""
}

variable "redis_password" {
  sensitive = true
  default   = ""
}

# Docker Image 

variable "default_docker_registry_prefix" {
  type    = string
  default = ""
}