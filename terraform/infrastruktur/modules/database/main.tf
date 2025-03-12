resource "azurerm_postgresql_flexible_server" "postgreserver" {
  name                          = "${var.postgreserver_name}-${var.rg_name_static}"
  resource_group_name           = var.rg_name_static
  location                      = var.rg_location_static
  version                       = var.postgreserver_version
  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = var.privdnszone_id
  public_network_access_enabled = var.postgreserver_public_network_access
  administrator_login           = var.postgreserver_admin_uname
  administrator_password        = var.postgreserver_admin_password
  zone                          = var.postgreserver_zone

  storage_mb   = var.postgreserver_storage_mb
  storage_tier = var.postgreserver_storage_tier
  backup_retention_days        = var.postgreserver_backup_retention
  geo_redundant_backup_enabled = var.postgreserver_redundant_backup
  auto_grow_enabled            = var.postgreserver_auto_grow

  sku_name   = var.postgreserver_skuname
}

resource "azurerm_postgresql_flexible_server_database" "postdb" {
  depends_on = [ azurerm_postgresql_flexible_server.postgreserver ]
  for_each = var.postdb

  name      = "${each.value.name}-${var.rg_name_static}-${each.key}"
  server_id = azurerm_postgresql_flexible_server.postgreserver.id
  collation = each.value.collation
  charset   = each.value.charset

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}