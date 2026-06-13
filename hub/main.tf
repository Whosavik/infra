data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group
}

resource "azurerm_subnet" "resolver" {
  name                 = "snet-dnsresolver"
  resource_group_name  = var.hub_vnet_resource_group
  virtual_network_name = var.hub_vnet_name
  address_prefixes     = [var.hub_resolver_subnet_prefix]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_resolver" "main" {
  name                = "dnsresolver-hub"
  resource_group_name = var.hub_vnet_resource_group
  location            = var.location
  virtual_network_id  = data.azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {
  name                    = "inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.main.id
  location                = var.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.resolver.id
  }
}

data "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.private_dns_zone_names)
  name     = each.key
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_links" {
  for_each              = toset(var.private_dns_zone_names)
  name                  = "link-hub-${replace(each.key, ".", "-")}"
  resource_group_name   = data.azurerm_private_dns_zone.zones[each.key].resource_group_name
  private_dns_zone_name = each.key
  virtual_network_id    = data.azurerm_virtual_network.hub.id
  registration_enabled  = false
}
