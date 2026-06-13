variable "location" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_resource_group" {
  type = string
}

variable "hub_resolver_subnet_prefix" {
  type        = string
  description = "A free /28 CIDR block within the hub VNet for the DNS resolver inbound endpoint subnet"
}

variable "private_dns_zone_names" {
  type        = list(string)
  description = "Names of existing private DNS zones to link to the hub VNet for cross-spoke resolution"
  default     = []
}
