provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }

    # Used for nginx and cert-manager deployment 
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}