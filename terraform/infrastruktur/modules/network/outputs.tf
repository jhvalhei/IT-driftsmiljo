output "subnet_id" {
  description = "The id of the subnet"
  value       = azurerm_subnet.subnet.id
}

output "privdnszone_id" {
  description = "The id of the provate dns zone"
  value       = azurerm_private_dns_zone.privdnszone.id
}

output "subnetcEnv_id" {
  description = "The id of the cenv subnet"
  value       = azurerm_subnet.subnetEnv.id
}