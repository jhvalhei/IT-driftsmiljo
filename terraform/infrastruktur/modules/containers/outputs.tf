output "postgreserver_admin_password" {
  description = "Admin password to db server"
  value       = azurerm_key_vault_secret.dbserversecret.value
  sensitive   = true
}