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

resource "kubernetes_secret" "paperless_postgres_credentials" {
  metadata {
    name      = "paperless-postgres-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    username = "paperless"
    password = "paperless"
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
          database = "paperless"
          owner    = "paperless"
          secret = {
            name = kubernetes_secret.paperless_postgres_credentials.metadata[0].name
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
          },
          {
            name = "paperless"
            ensure = "present"
            passwordSecret = {
              name =  "paperless-postgres-credentials"    
            }
            login = true
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

resource "kubernetes_persistent_volume_claim" "data_pvc" {
  metadata {
    name      = "data-pvc"
    namespace = "home"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "media_pvc" {
  metadata {
    name      = "media-pvc"
    namespace = "home"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1.5Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "export_pvc" {
  metadata {
    name      = "export-pvc"
    namespace = "home"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "consume_pvc" {
  metadata {
    name      = "consume-pvc"
    namespace = "home"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_manifest" "paperless" {
  manifest = yamldecode(file("k8s/paperless-redis.deployment.yml"))
  depends_on = [ kubernetes_persistent_volume_claim.data_pvc, kubernetes_persistent_volume_claim.media_pvc, kubernetes_persistent_volume_claim.export_pvc, kubernetes_persistent_volume_claim.consume_pvc ]
}

resource "kubernetes_service" "paperless_service" {
  metadata {
    name      = "paperless-ngx"
    namespace = "home"
    annotations = {
      "metallb.universe.tf/loadBalancerIPs" = "10.0.0.103"
    }
  }

  spec {
    selector = {
      app = "paperless-ngx"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [ kubernetes_manifest.paperless ]
}


output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata[0].name
}