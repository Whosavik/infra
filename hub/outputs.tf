output "resolver_inbound_ip" {
  value       = azurerm_private_dns_resolver_inbound_endpoint.main.ip_configurations[0].private_ip_address
  description = "IP of the DNS resolver inbound endpoint — used as the DNS server on spoke VNets"
}

output "wireguard_vm_public_ip" {
  value       = azurerm_public_ip.wireguard.ip_address
  description = "Public IP of the WireGuard VM — used as the client config's Endpoint"
}

output "wireguard_vm_private_ip" {
  value       = azurerm_network_interface.wireguard.private_ip_address
  description = "Private IP of the WireGuard VM — used as the next hop for spoke route tables"
}
