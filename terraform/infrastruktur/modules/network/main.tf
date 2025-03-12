resource "azurerm_network_security_group" "nsg" {
  name                = "${var.nsg_name}-${var.rg_name_static}"
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static

  /**security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }**/
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  depends_on = [azurerm_subnet.subnet, azurerm_network_security_group.nsg]
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${var.rg_name_static}"
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  address_space       = var.vnet_addresspace
}

resource "azurerm_subnet" "subnet" {
  depends_on = [azurerm_virtual_network.vnet]
  name                 = "${var.subnet_name}-${var.rg_name_static}"
  resource_group_name  = var.rg_name_static
  virtual_network_name = "${var.vnet_name}-${var.rg_name_static}"
  address_prefixes     = var.subnet_address_prefixes
  service_endpoints    = var.subnet_service_endpoint
  delegation {
    name = "${var.subnet_delegation_name}-${var.rg_name_static}"
    service_delegation {
      name = var.subnet_service_delegation_name
      actions = var.subnet_service_delegation_actions
    }
  }
}

resource "azurerm_private_dns_zone" "privdnszone" {
  name                = var.privdnszone_name
  resource_group_name = var.rg_name_static
}

resource "azurerm_private_dns_zone_virtual_network_link" "privdnslink" {
  name                  = var.privdnslink_name
  private_dns_zone_name = var.privdnszone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.rg_name_static
  depends_on            = [azurerm_subnet.subnet, azurerm_private_dns_zone.privdnszone]
}