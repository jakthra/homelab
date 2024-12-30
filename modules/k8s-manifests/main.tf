variable "namespace_name" {
  description = "The namespace to create"
  type        = string
}

variable "postgres_credentials" {
  description = "PostgreSQL user credentials"
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    username = var.postgres_credentials.username
    password = var.postgres_credentials.password
  }
}

resource "kubernetes_manifest" "postgres_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "postgres-cluster"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      instances = 3
      storage = {
        size = "1Gi"
      }
      monitoring = {
        enablePodMonitor = true
      }
      bootstrap = {
        initdb = {
          database = "app"
          owner    = var.postgres_credentials.username
          secret = {
            name = kubernetes_secret.postgres_credentials.metadata[0].name
          }
        }
      }
      managed = {
        roles = [
          {
            name = "cluster"
            ensure = "present"
            passwordSecret = {
              name =  "postgres-credentials"    
            }
            login = true
            superuser = true
          }
        ]
      #   services = {
      #   additional = [
      #     { 
      #       selectorType = "rw"
      #       serviceTemplate = {
      #         metadata = {
      #           name = "postgres-lb"
      #           annotations = {
      #             "metallb.universe.tf/loadBalancerIPs" = "10.0.0.102"
      #           }
      #         }
      #         spec = {
      #           type = "LoadBalancer"
      #         }
      #       }  
      #     }
      #   ]
      # }
      }
      
    }
  }

  depends_on = [kubernetes_namespace.namespace, kubernetes_secret.postgres_credentials]
}

output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata[0].name
}