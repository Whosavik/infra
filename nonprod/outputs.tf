output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = azurerm_resource_group.nonprod.name
}

output "acr_login_server" {
  value = data.terraform_remote_state.shared.outputs.acr_login_server
}

output "location" {
  value = azurerm_resource_group.nonprod.location
}

output "host" {
  value     = module.aks.host
  sensitive = true
}

output "client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks.cluster_ca_certificate
  sensitive = true
}
