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

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "aso_client_id" {
  value = azurerm_user_assigned_identity.aso.client_id
}

output "eso_client_id" {
  value = azurerm_user_assigned_identity.eso.client_id
}

output "key_vault_uri" {
  value = data.terraform_remote_state.shared.outputs.key_vault_uri
}

output "cert_manager_client_id" {
  value = azurerm_user_assigned_identity.cert_manager.client_id
}

output "dns_zone_name" {
  value = azurerm_dns_zone.internal.name
}

output "dns_zone_resource_group" {
  value = azurerm_resource_group.nonprod.name
}

output "zone_nameservers" {
  value = azurerm_dns_zone.internal.name_servers
}

output "nginx_ilb_ip" {
  value = var.nginx_ilb_ip
}
