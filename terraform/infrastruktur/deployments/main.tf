resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location
}

module "containers" {
  for_each = azurerm_resource_group.rg

  source = "../modules/containers"
  rg_name = each.value.name
  rg_location = each.value.location
  law_name = var.law_name
  law_sku = var.law_sku
  law_retention = var.law_retention
  cae_name = var.cae_name
  capp_name = var.capp_name
  capp_revmode = var.capp_revmode
  capp_image = var.capp_image
  capp_cpu = var.capp_cpu
  capp_memory = var.capp_memory
}

module "database" {
  for_each = azurerm_resource_group.rg

  source = "../modules/database"
  rg_name = each.value.name
  rg_location = each.value.location
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
  postdb_name = var.postdb_name
  postdb_charset = var.postdb_charset
  postdb_collation = var.postdb_collation
  postdb_prevent_destroy = var.postdb_prevent_destroy
}