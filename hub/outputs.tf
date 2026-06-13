output "resolver_inbound_ip" {
  value       = azurerm_private_dns_resolver_inbound_endpoint.main.ip_configurations[0].private_ip_address
  description = "IP of the DNS resolver inbound endpoint — used as the DNS server on spoke VNets"
}
