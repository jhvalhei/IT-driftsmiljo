output "postdb_ids" {
  value = { for k, v in azurerm_postgresql_flexible_server_database.postdb : k => v.id }
}