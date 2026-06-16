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

variable "hub_wireguard_subnet_prefix" {
  type        = string
  description = "A free /28 (or larger) CIDR block within the hub VNet for the WireGuard VM"
}

variable "wireguard_vm_size" {
  type        = string
  default     = "Standard_B2als_v2"
  description = "The old Bs/Bms family (e.g. Standard_B1s) is not available in some subscriptions/regions — stick to the Bsv2/Basv2 family"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for the WireGuard VM's admin user"
}

variable "wg_server_private_key" {
  type        = string
  sensitive   = true
  description = "WireGuard server private key, generated out-of-band (wg genkey)"
}

variable "wg_tunnel_cidr" {
  type        = string
  description = "CIDR of the WireGuard tunnel network, e.g. 10.200.0.0/24. The server takes the first host address."
}

variable "wg_client_public_key" {
  type        = string
  description = "WireGuard public key of the first client peer, generated out-of-band (wg genkey | wg pubkey)"
}

variable "wg_client_tunnel_ip" {
  type        = string
  description = "Tunnel address allowed for the first client peer, e.g. 10.200.0.2/32"
}
