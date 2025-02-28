resource "azurerm_postgresql_server" "postgreserver" {
  name                = var.postgreserver_name
  location            = var.rg_location
  resource_group_name = var.rg_name

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
  name                = var.postdb_name
  resource_group_name = var.rg_name
  server_name         = azurerm_postgresql_server.postgreserver.name
  charset             = var.postdb_charset
  collation           = var.postdb_collation

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = var.postdb_prevent_destroy
  }
}