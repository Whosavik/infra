data "azurerm_client_config" "current" {}

data "terraform_remote_state" "nonprod" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "nonprod/terraform.tfstate"
  }
}

data "terraform_remote_state" "prod" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "prod/terraform.tfstate"
  }
}

# ── nonprod ──────────────────────────────────────────────────────────────────

module "bootstrap_nonprod" {
  source    = "../modules/cluster-bootstrap"
  providers = { kubernetes = kubernetes.nonprod }

  subscription_id         = data.azurerm_client_config.current.subscription_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  acr_host                = data.terraform_remote_state.nonprod.outputs.acr_login_server
  resource_group_name     = data.terraform_remote_state.nonprod.outputs.resource_group_name
  location                = data.terraform_remote_state.nonprod.outputs.location
  aso_client_id           = data.terraform_remote_state.nonprod.outputs.aso_client_id
  eso_client_id           = data.terraform_remote_state.nonprod.outputs.eso_client_id
  key_vault_uri           = data.terraform_remote_state.nonprod.outputs.key_vault_uri
  cert_manager_client_id  = data.terraform_remote_state.nonprod.outputs.cert_manager_client_id
  dns_zone_name           = data.terraform_remote_state.nonprod.outputs.dns_zone_name
  dns_zone_resource_group = data.terraform_remote_state.nonprod.outputs.dns_zone_resource_group
  nginx_ilb_ip            = data.terraform_remote_state.nonprod.outputs.nginx_ilb_ip
}

# ── prod ─────────────────────────────────────────────────────────────────────

module "bootstrap_prod" {
  source    = "../modules/cluster-bootstrap"
  providers = { kubernetes = kubernetes.prod }

  subscription_id         = data.azurerm_client_config.current.subscription_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  acr_host                = data.terraform_remote_state.prod.outputs.acr_login_server
  resource_group_name     = data.terraform_remote_state.prod.outputs.resource_group_name
  location                = data.terraform_remote_state.prod.outputs.location
  aso_client_id           = data.terraform_remote_state.prod.outputs.aso_client_id
  eso_client_id           = data.terraform_remote_state.prod.outputs.eso_client_id
  key_vault_uri           = data.terraform_remote_state.prod.outputs.key_vault_uri
  cert_manager_client_id  = data.terraform_remote_state.prod.outputs.cert_manager_client_id
  dns_zone_name           = data.terraform_remote_state.prod.outputs.dns_zone_name
  dns_zone_resource_group = data.terraform_remote_state.prod.outputs.dns_zone_resource_group
  nginx_ilb_ip            = data.terraform_remote_state.prod.outputs.nginx_ilb_ip
}
