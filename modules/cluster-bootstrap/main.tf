resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_config_map" "cluster_vars" {
  metadata {
    name      = "cluster-vars"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  data = {
    ACR_HOST                = var.acr_host
    AZURE_SUBSCRIPTION_ID   = var.subscription_id
    AZURE_TENANT_ID         = var.tenant_id
    AZURE_RESOURCE_GROUP    = var.resource_group_name
    AZURE_LOCATION          = var.location
    ASO_CLIENT_ID           = var.aso_client_id
    ESO_CLIENT_ID           = var.eso_client_id
    KEY_VAULT_URI           = var.key_vault_uri
    CERT_MANAGER_CLIENT_ID  = var.cert_manager_client_id
    DNS_ZONE_NAME           = var.dns_zone_name
    DNS_ZONE_RESOURCE_GROUP = var.dns_zone_resource_group
    NGINX_ILB_IP            = var.nginx_ilb_ip
  }
}
