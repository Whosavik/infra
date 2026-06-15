variable "namespace_name" {
  type    = string
  default = "flux-system"
}

variable "acr_host" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aso_client_id" {
  type = string
}

variable "eso_client_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "cert_manager_client_id" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_resource_group" {
  type = string
}

variable "nginx_ilb_ip" {
  type = string
}
