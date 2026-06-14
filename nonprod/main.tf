data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group
}

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

resource "azurerm_resource_group" "nonprod" {
  name     = "rg-nonprod"
  location = var.location
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-nonprod"
  location            = azurerm_resource_group.nonprod.location
  resource_group_name = azurerm_resource_group.nonprod.name
  address_space       = [var.vnet_address_space]
  dns_servers         = [data.terraform_remote_state.hub.outputs.resolver_inbound_ip]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-nonprod"
  resource_group_name  = azurerm_resource_group.nonprod.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.node_subnet_prefix]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-nonprod-to-hub"
  resource_group_name       = azurerm_resource_group.nonprod.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-nonprod"
  resource_group_name       = var.hub_vnet_resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

module "aks" {
  source = "../modules/aks"

  cluster_name        = "aks-nonprod"
  location            = azurerm_resource_group.nonprod.location
  resource_group_name = azurerm_resource_group.nonprod.name
  vm_size             = var.vm_size
  min_nodes           = var.min_nodes
  max_nodes           = var.max_nodes
  vnet_subnet_id      = azurerm_subnet.aks.id
  acr_id              = data.terraform_remote_state.shared.outputs.acr_id

  tags = {
    environment = "nonprod"
  }
}

# ASO

resource "azurerm_user_assigned_identity" "aso" {
  name                = "uami-aso-nonprod"
  resource_group_name = azurerm_resource_group.nonprod.name
  location            = azurerm_resource_group.nonprod.location
}

resource "azurerm_federated_identity_credential" "aso" {
  name                = "aso-fedcred"
  user_assigned_identity_id = azurerm_user_assigned_identity.aso.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:azureserviceoperator-system:azureserviceoperator-default"
}

resource "azurerm_role_assignment" "aso_contributor" {
  scope                = azurerm_resource_group.nonprod.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aso.principal_id
}

# ESO

resource "azurerm_user_assigned_identity" "eso" {
  name                = "uami-eso-nonprod"
  resource_group_name = azurerm_resource_group.nonprod.name
  location            = azurerm_resource_group.nonprod.location
}

resource "azurerm_federated_identity_credential" "eso" {
  name                = "eso-fedcred"
  user_assigned_identity_id = azurerm_user_assigned_identity.eso.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:external-secrets:external-secrets-external-secrets"
}

resource "azurerm_role_assignment" "eso_kv_secrets_user" {
  scope                = data.terraform_remote_state.shared.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.eso.principal_id
}

# DNS

locals {
  internal_zone = "${var.cluster_subdomain}.internal.${var.parent_domain}"
}

resource "azurerm_dns_zone" "internal" {
  name                = local.internal_zone
  resource_group_name = azurerm_resource_group.nonprod.name
}

resource "azurerm_dns_a_record" "wildcard" {
  count               = var.nginx_ilb_ip != "" ? 1 : 0
  name                = "*"
  zone_name           = azurerm_dns_zone.internal.name
  resource_group_name = azurerm_resource_group.nonprod.name
  ttl                 = 300
  records             = [var.nginx_ilb_ip]
}

# cert-manager

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                = "uami-cert-manager-nonprod"
  resource_group_name = azurerm_resource_group.nonprod.name
  location            = azurerm_resource_group.nonprod.location
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  name                      = "cert-manager-fedcred"
  user_assigned_identity_id = azurerm_user_assigned_identity.cert_manager.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = module.aks.oidc_issuer_url
  subject                   = "system:serviceaccount:cert-manager:cert-manager"
}

resource "azurerm_role_assignment" "cert_manager_dns" {
  scope                = azurerm_dns_zone.internal.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
    scope                = azurerm_subnet.aks.id
    role_definition_name = "Network Contributor"
    principal_id         = module.aks.cluster_identity_principal_id
}
