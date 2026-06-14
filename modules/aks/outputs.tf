output "cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "host" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "cluster_identity_principal_id" {
  value = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
