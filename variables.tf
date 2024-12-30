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