terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }

}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "b03b0d6e-32d0-4c8b-a3df-e5054df8ed86"
  storage_use_azuread = true
}

resource "azurerm_resource_group" "rg_backend" {
  name     = var.rg_backend_name
  location = var.rg_backend_location
}

resource "random_string" "randomname" {
  length  = 10
  special = false
  upper   = false
}



# Storage account and container where the infrastructure state file will be stored
resource "azurerm_storage_account" "backend_sa" {
  name                     = "sabackend${random_string.randomname.result}"
  resource_group_name      = azurerm_resource_group.rg_backend.name
  location                 = azurerm_resource_group.rg_backend.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  shared_access_key_enabled = false
}
resource "azurerm_storage_container" "backend_container" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.backend_sa.name
  container_access_type = "private"
}



