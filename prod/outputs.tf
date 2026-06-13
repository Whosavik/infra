output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = azurerm_resource_group.prod.name
}

output "acr_login_server" {
  value = data.terraform_remote_state.shared.outputs.acr_login_server
}
