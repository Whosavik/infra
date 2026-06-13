variable "location" {
  type = string
}

variable "acr_name" {
  type        = string
  description = "Globally unique name for the Container Registry (alphanumeric only, 5-50 chars)"
}

variable "key_vault_name" {
  type        = string
  description = "Globally unique Key Vault name (3-24 chars, alphanumeric and hyphens)"
}
