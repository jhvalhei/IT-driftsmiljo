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
  depends_on = [ azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static ]
  source = "../modules/database"
  rg_name_static = var.rg_name_static
  rg_location_static = var.rg_location_static
  postgreserver_name = var.postgreserver_name
  postgreserver_skuname = var.postgreserver_skuname
  postgreserver_storage_mb = var.postgreserver_storage_mb
  postgreserver_backup_retention = var.postgreserver_backup_retention
  postgreserver_redundant_backup = var.postgreserver_redundant_backup
  postgreserver_auto_grow = var.postgreserver_auto_grow
  postgreserver_admin_uname = var.postgreserver_admin_uname
  postgreserver_admin_password = var.postgreserver_admin_password
  postgreserver_version = var.postgreserver_version
  postgreserver_ssl = var.postgreserver_ssl
  postdb = var.postdb
}