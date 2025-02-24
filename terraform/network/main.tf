# Resource Group
resource "azurerm_resource_group" "tf" {
  location = var.resource_group_location
  name     = "${random_pet.prefix.id}-tf"
}

# Virtuellt Nettverk
resource "azurerm_virtual_network" "tf-vnet" {
  name                = "tf-vnet"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet 1
resource "azurerm_subnet" "tf-subnet1" {
  name                 = "tf-subnet1"
  resource_group_name  = azurerm_resource_group.tf.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Subnet 2
resource "azurerm_subnet" "tf-subnet2" {
  name                 = "tf-subnet2"
  resource_group_name  = azurerm_resource_group.tf.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "random_pet" "prefix" {
  prefix = var.resource_group_name_prefix
  length = 1
}