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

# WireGuard

resource "azurerm_subnet" "wireguard" {
  name                 = "snet-wireguard"
  resource_group_name  = var.hub_vnet_resource_group
  virtual_network_name = var.hub_vnet_name
  address_prefixes     = [var.hub_wireguard_subnet_prefix]
}

resource "azurerm_public_ip" "wireguard" {
  name                = "pip-wireguard"
  resource_group_name = var.hub_vnet_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "wireguard" {
  name                = "nsg-wireguard"
  resource_group_name = var.hub_vnet_resource_group
  location            = var.location

  security_rule {
    name                       = "AllowWireGuardInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSshInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "wireguard" {
  subnet_id                 = azurerm_subnet.wireguard.id
  network_security_group_id = azurerm_network_security_group.wireguard.id
}

resource "azurerm_network_interface" "wireguard" {
  name                  = "nic-wireguard"
  resource_group_name   = var.hub_vnet_resource_group
  location              = var.location
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wireguard.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wireguard.id
  }
}

resource "azurerm_linux_virtual_machine" "wireguard" {
  name                = "vm-wireguard-hub"
  resource_group_name = var.hub_vnet_resource_group
  location            = var.location
  size                = var.wireguard_vm_size
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.wireguard.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.sh.tpl", {
    server_private_key = var.wg_server_private_key
    server_address     = "${cidrhost(var.wg_tunnel_cidr, 1)}/${split("/", var.wg_tunnel_cidr)[1]}"
    client_public_key  = var.wg_client_public_key
    client_tunnel_ip   = var.wg_client_tunnel_ip
  }))
}
