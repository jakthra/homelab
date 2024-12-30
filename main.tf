module "namespace" {
  source = "./modules/k8s-manifests"
  
  namespace_name = var.namespace_name
}

module "pihole" {
  source = "./modules/helm-releases"
  
  namespace_name = module.namespace.namespace_name
  release_config = var.pihole_config

  depends_on = [module.namespace]
}

module "postgresql" {
  source = "./modules/helm-releases"
  
  namespace_name = module.namespace.namespace_name
  release_config = var.postgresql_config

  depends_on = [module.namespace, module.pihole]
}
