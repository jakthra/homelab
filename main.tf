module "k8s_manifests" {
  source = "./modules/k8s-manifests"
  
  namespace_name        = var.namespace_name
  postgres_credentials  = var.postgres_credentials
}

module "helm_releases" {
  source = "./modules/helm-releases"
  
  namespace_name     = module.k8s_manifests.namespace_name
  pihole_values_path = var.pihole_values_path

  depends_on = [module.k8s_manifests]
}