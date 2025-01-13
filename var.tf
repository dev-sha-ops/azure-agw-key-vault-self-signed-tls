data "azurerm_client_config" "current" {}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default = "shadab-rg"
}

variable "location" {
  type        = string
  description = "The location to create the resources in"
  default = "East US"
}

variable "common_name" {
  type        = string
  description = "The value of the CN field of the certificate"
  default = "shadab.com"
}


terraform {
  required_providers {
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.0"
    }
  }
}
provider "azurerm" { 
    features {}
}