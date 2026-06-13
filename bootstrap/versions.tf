terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  alias                  = "nonprod"
  host                   = data.terraform_remote_state.nonprod.outputs.host
  client_certificate     = base64decode(data.terraform_remote_state.nonprod.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.nonprod.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.nonprod.outputs.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "prod"
  host                   = data.terraform_remote_state.prod.outputs.host
  client_certificate     = base64decode(data.terraform_remote_state.prod.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.prod.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.prod.outputs.cluster_ca_certificate)
}
