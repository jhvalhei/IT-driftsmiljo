resource "azurerm_postgresql_server" "postgreserver" {
  name                = var.postgreserver_name
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static

  sku_name = var.postgreserver_skuname

  storage_mb                   = var.postgreserver_storage_mb
  backup_retention_days        = var.postgreserver_backup_retention
  geo_redundant_backup_enabled = var.postgreserver_redundant_backup
  auto_grow_enabled            = var.postgreserver_auto_grow

  administrator_login          = var.postgreserver_admin_uname
  administrator_login_password = var.postgreserver_admin_password
  version                      = var.postgreserver_version
  ssl_enforcement_enabled      = var.postgreserver_ssl
}

resource "azurerm_postgresql_database" "postdb" {
  depends_on = [ azurerm_postgresql_server.postgreserver ]
  for_each = var.postdb

  name                = "${each.value.name}-${var.rg_name_static}-${each.key}"
  resource_group_name = var.rg_name_static
  server_name         = var.postgreserver_name
  charset             = each.value.charset
  collation           = each.value.collation
  
  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}