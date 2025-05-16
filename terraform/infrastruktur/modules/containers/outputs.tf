output "postgreserver_admin_password" {
  description = "Admin password to db server"
  value       = azurerm_key_vault_secret.db_admin_serversecret.value
  sensitive   = true
}

output "capp_ids" {
  value = concat(
      values(azurerm_container_app.capp_without_db)[*].id,
      values(azurerm_container_app.capp_with_db)[*].id
    )
}
