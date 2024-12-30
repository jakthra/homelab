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

resource "helm_release" "cnpg" {
  name      = "cnpg"
  repository = "https://cloudnative-pg.github.io/charts"
  chart = "cloudnative-pg"
  namespace = "cnpg-system"
  create_namespace = true
}


# Note: For the values file, you have two options:
# 1. Download it locally and reference it as shown above
# 2. Use a data source to fetch it during apply:

data "http" "kube_stack_config" {
  url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml"
}

# Alternative helm_release configuration using the http data source:
resource "helm_release" "prometheus_alt" {
  name       = "prometheus-community"
  repository =  "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    data.http.kube_stack_config.response_body
  ]

  depends_on = [helm_release.cnpg]
}