data "azurerm_client_config" "current" {}

data "terraform_remote_state" "nonprod" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "nonprod/terraform.tfstate"
  }
}

data "terraform_remote_state" "prod" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa
    container_name       = var.backend_container
    key                  = "prod/terraform.tfstate"
  }
}

# ── nonprod ──────────────────────────────────────────────────────────────────

resource "kubernetes_namespace" "flux_system_nonprod" {
  provider = kubernetes.nonprod

  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_config_map" "cluster_vars_nonprod" {
  provider = kubernetes.nonprod

  metadata {
    name      = "cluster-vars"
    namespace = kubernetes_namespace.flux_system_nonprod.metadata[0].name
  }

  data = {
    ACR_HOST              = data.terraform_remote_state.nonprod.outputs.acr_login_server
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_RESOURCE_GROUP  = data.terraform_remote_state.nonprod.outputs.resource_group_name
    AZURE_LOCATION        = data.terraform_remote_state.nonprod.outputs.location
    ASO_CLIENT_ID         = data.terraform_remote_state.nonprod.outputs.aso_client_id
    ESO_CLIENT_ID         = data.terraform_remote_state.nonprod.outputs.eso_client_id
    KEY_VAULT_URI         = data.terraform_remote_state.nonprod.outputs.key_vault_uri
  }
}

# ── prod ─────────────────────────────────────────────────────────────────────

resource "kubernetes_namespace" "flux_system_prod" {
  provider = kubernetes.prod

  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_config_map" "cluster_vars_prod" {
  provider = kubernetes.prod

  metadata {
    name      = "cluster-vars"
    namespace = kubernetes_namespace.flux_system_prod.metadata[0].name
  }

  data = {
    ACR_HOST              = data.terraform_remote_state.prod.outputs.acr_login_server
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_RESOURCE_GROUP  = data.terraform_remote_state.prod.outputs.resource_group_name
    AZURE_LOCATION        = data.terraform_remote_state.prod.outputs.location
    ASO_CLIENT_ID         = data.terraform_remote_state.prod.outputs.aso_client_id
    ESO_CLIENT_ID         = data.terraform_remote_state.prod.outputs.eso_client_id
    KEY_VAULT_URI         = data.terraform_remote_state.prod.outputs.key_vault_uri
  }
}
