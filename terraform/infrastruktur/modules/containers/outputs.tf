output "postgreserver_admin_password" {
  description = "Admin password to db server"
  value       = azurerm_key_vault_secret.db_admin_serversecret.value
  sensitive   = true
}

output "capp_with_db_ids" {
  value = { for k, v in azurerm_container_app.capp_with_db : k => v.id }
}

output "capp_without_db_ids" {
  value = { for k, v in azurerm_container_app.capp_without_db : k => v.id }
}
