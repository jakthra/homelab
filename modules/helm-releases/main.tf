variable "namespace_name" {
  description = "Namespace to install the release into"
  type        = string
}

variable "release_config" {
  description = "Configuration for the Helm release"
  type = object({
    name       = string
    repository = string
    chart      = string
    version    = string
    values     = optional(string)
    depends_on = list(string)
  })
}

resource "helm_release" "release" {
  name       = var.release_config.name
  repository = var.release_config.repository
  chart      = var.release_config.chart
  version    = var.release_config.version
  namespace  = var.namespace_name
  values     = var.release_config.values != null ? [file(var.release_config.values)] : []
}

output "release_name" {
  value = helm_release.release.name
}