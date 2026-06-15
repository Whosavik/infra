data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "hub/terraform.tfstate"
  }
}

data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "shared/terraform.tfstate"
  }
}

module "cluster" {
  source = "../modules/cluster"

  environment             = "prod"
  location                = var.location
  vm_size                 = var.vm_size
  min_nodes               = var.min_nodes
  max_nodes               = var.max_nodes
  hub_vnet_name           = var.hub_vnet_name
  hub_vnet_resource_group = var.hub_vnet_resource_group
  hub_resolver_inbound_ip = data.terraform_remote_state.hub.outputs.resolver_inbound_ip
  vnet_address_space      = var.vnet_address_space
  node_subnet_prefix      = var.node_subnet_prefix
  acr_id                  = data.terraform_remote_state.shared.outputs.acr_id
  key_vault_id            = data.terraform_remote_state.shared.outputs.key_vault_id
  parent_domain           = var.parent_domain
  cluster_subdomain       = var.cluster_subdomain
  nginx_ilb_ip            = var.nginx_ilb_ip
}
