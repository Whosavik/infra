variable "environment" {
  type        = string
  description = "Environment name used as a suffix in all resource names (e.g. prod, nonprod)"
}

variable "location" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "min_nodes" {
  type = number
}

variable "max_nodes" {
  type = number
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_resource_group" {
  type = string
}

variable "hub_resolver_inbound_ip" {
  type        = string
  description = "Private IP of the DNS resolver inbound endpoint in the hub VNet"
}

variable "vnet_address_space" {
  type = string
}

variable "node_subnet_prefix" {
  type = string
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the shared Container Registry"
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the shared Key Vault"
}

variable "parent_domain" {
  type        = string
  description = "Root domain, e.g. busstop.dev"
}

variable "cluster_subdomain" {
  type        = string
  description = "Cluster subdomain prefix, e.g. prd or npe"
}

variable "nginx_ilb_ip" {
  type        = string
  default     = ""
  description = "Private IP of the nginx ILB; set after nginx deploys to create the DNS A record"
}

variable "wireguard_vm_private_ip" {
  type        = string
  default     = ""
  description = "Private IP of the hub WireGuard VM; when set, a route is added so the AKS subnet can reply to tunnel-sourced traffic"
}

variable "wireguard_tunnel_cidr" {
  type        = string
  default     = ""
  description = "CIDR of the WireGuard tunnel network; routed back through wireguard_vm_private_ip"
}
