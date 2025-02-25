terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.20.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
    features {  }
    subscription_id = "b03b0d6e-32d0-4c8b-a3df-e5054df8ed86"

}

module "deployments" {
    source = "./deployments"
}