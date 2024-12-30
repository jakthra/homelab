variable "namespace_name" {
  description = "The name of the namespace to create"
  type        = string
  default     = "home"
}

variable "pihole_values_path" {
  description = "Path to PiHole values file"
  type        = string
  default     = "helm-charts/pihole/values.yml"
}

variable "postgres_credentials" {
  description = "PostgreSQL user credentials"
  type = object({
    username = string
    password = string
  })
  sensitive = true
  default = {
    username = "cluster"
    password = "cluster"  # Change this in secrets.tfvars
  }
}