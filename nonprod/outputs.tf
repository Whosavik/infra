output "cluster_name" {
  value = module.cluster.cluster_name
}

output "resource_group_name" {
  value = module.cluster.resource_group_name
}

output "acr_login_server" {
  value = data.terraform_remote_state.shared.outputs.acr_login_server
}

output "location" {
  value = module.cluster.location
}

output "host" {
  value     = module.cluster.host
  sensitive = true
}

output "client_certificate" {
  value     = module.cluster.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.cluster.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.cluster.cluster_ca_certificate
  sensitive = true
}

output "oidc_issuer_url" {
  value = module.cluster.oidc_issuer_url
}

output "aso_client_id" {
  value = module.cluster.aso_client_id
}

output "eso_client_id" {
  value = module.cluster.eso_client_id
}

output "key_vault_uri" {
  value = data.terraform_remote_state.shared.outputs.key_vault_uri
}

output "cert_manager_client_id" {
  value = module.cluster.cert_manager_client_id
}

output "dns_zone_name" {
  value = module.cluster.dns_zone_name
}

output "dns_zone_resource_group" {
  value = module.cluster.dns_zone_resource_group
}

output "zone_nameservers" {
  value = module.cluster.zone_nameservers
}

output "nginx_ilb_ip" {
  value = module.cluster.nginx_ilb_ip
}
