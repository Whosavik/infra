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

variable "vnet_address_space" {
  type = string
}

variable "node_subnet_prefix" {
  type = string
}

variable "backend_rg" {
  type = string
}

variable "backend_sa" {
  type = string
}

variable "backend_container" {
  type = string
}
