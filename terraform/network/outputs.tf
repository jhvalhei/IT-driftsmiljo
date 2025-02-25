output "resource_group_name" {
  description = "Navnet av resource group."
  value       = azurerm_resource_group.tf.name
}

output "virtual_network_name" {
  description = "Navnet for virtuellt nettverk."
  value       = azurerm_virtual_network.tf-vnet.name
}

output "subnet_name_1" {
  description = "Navnet for subnet 1."
  value       = azurerm_subnet.tf-subnet1.name
}

output "subnet_name_2" {
  description = "Navnet for subnet 2."
  value       = azurerm_subnet.tf-subnet2.name
}