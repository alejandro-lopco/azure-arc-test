terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.22.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "3.5.0"
    }
    tls = {
        source = "hashicorp/tls"
        version = "~>4.1.0"
    }     
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}