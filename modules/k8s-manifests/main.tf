variable "namespace_name" {
  description = "The namespace to create"
  type        = string
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace_name
  }
}

output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata[0].name
}