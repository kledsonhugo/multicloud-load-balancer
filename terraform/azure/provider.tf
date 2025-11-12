terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.52.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-lbtfkb001"
    storage_account_name = "lbtfkb002"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}