terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

provider "azurerm" {
  features {   }
}

resource "azurerm_resource_group" "fd-jh" {
  name     = "fd-testtest"
  location = "West Europe"
}

resource "azurerm_storage_account" "sa-jhv" {
  name                     = "test65246426"
  resource_group_name      = azurerm_resource_group.fd-jh.name
  location                 = azurerm_resource_group.fd-jh.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


}