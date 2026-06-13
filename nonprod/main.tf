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
