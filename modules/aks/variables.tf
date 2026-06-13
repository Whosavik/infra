variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
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

variable "vnet_subnet_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
