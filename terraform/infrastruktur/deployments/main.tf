resource "azurerm_resource_group" "rg_dynamic" {
  for_each = var.rg_dynamic

  name     = each.value.name
  location = each.value.location
}

resource "azurerm_resource_group" "rg_static" {
  name = var.rg_name_static
  location = var.rg_location_static
}

module "containers" {
  depends_on = [ azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static ]
  source = "../modules/containers"
  rg_name_static = var.rg_name_static
  rg_location_static = var.rg_location_static
  law_name = var.law_name
  law_sku = var.law_sku
  law_retention = var.law_retention
  cae_name = var.cae_name
  container = var.container
}

module "database" {
  depends_on = [ azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static, module.network ]
  source = "../modules/database"
  rg_name_static = var.rg_name_static
  rg_location_static = var.rg_location_static
  postgreserver_name = var.postgreserver_name
  postgreserver_skuname = var.postgreserver_skuname
  postgreserver_storage_mb = var.postgreserver_storage_mb
  postgreserver_storage_tier = var.postgreserver_storage_tier
  postgreserver_backup_retention = var.postgreserver_backup_retention
  postgreserver_redundant_backup = var.postgreserver_redundant_backup
  postgreserver_auto_grow = var.postgreserver_auto_grow
  postgreserver_admin_uname = var.postgreserver_admin_uname
  postgreserver_admin_password = var.postgreserver_admin_password
  postgreserver_version = var.postgreserver_version
  postgreserver_public_network_access = var.postgreserver_public_network_access
  postgreserver_zone = var.postgreserver_zone
  postdb = var.postdb
  subnet_id = module.network.subnet_id
  privdnszone_id = module.network.privdnszone_id
}

module "network" {
  depends_on = [ azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static ]
  source = "../modules/network"
  rg_name_static = var.rg_name_static
  rg_location_static = var.rg_location_static
  nsg_name = var.nsg_name
  vnet_name = var.vnet_name
  vnet_addresspace = var.vnet_addresspace
  subnet_name = var.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
  subnet_service_endpoint = var.subnet_service_endpoint
  subnet_delegation_name = var.subnet_delegation_name
  subnet_service_delegation_name = var.subnet_service_delegation_name
  subnet_service_delegation_actions = var.subnet_service_delegation_actions
  privdnszone_name = var.privdnszone_name
  privdnslink_name = var.privdnslink_name
}