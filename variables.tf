variable "namespace_name" {
  description = "The name of the namespace to create"
  type        = string
  default     = "home"
}

variable "pihole_config" {
  description = "Configuration for the Pihole Helm release"
  type = object({
    name       = string
    repository = string
    chart      = string
    version    = string
    values     = string
    depends_on = list(string)
  })
  default = {
    name       = "pihole"
    repository = "https://mojo2600.github.io/pihole-kubernetes/"
    chart      = "pihole"
    version    = null
    values     = "helm-charts/pihole/values.yml"
    depends_on = []
  }
}

variable "postgresql_config" {
  description = "Configuration for the PostgreSQL Helm release"
  type = object({
    name       = string
    repository = string
    chart      = string
    version    = string
    values     = string
    depends_on = list(string)
  })
  default = {
    name       = "postgresql"
    repository = "oci://registry-1.docker.io/bitnamicharts"
    chart      = "postgresql"
    version    = "16.3.4"
    values     = "helm-charts/postgresql/values.yml"
    depends_on = ["module.pihole"]
  }
}

