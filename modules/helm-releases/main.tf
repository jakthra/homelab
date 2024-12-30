variable "namespace_name" {
  description = "The namespace to deploy to"
  type        = string
}

variable "pihole_values_path" {
  description = "Path to PiHole values file"
  type        = string
}

resource "helm_release" "pihole" {
  name       = "pihole"
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole"
  namespace  = var.namespace_name
  
  values = [
    file(var.pihole_values_path)
  ]
}