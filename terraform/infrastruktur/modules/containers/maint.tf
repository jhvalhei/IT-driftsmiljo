resource "azurerm_container_app" "container_app" {
  name                         = var.containerapp-name
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = var.containerName
      image  = var.containerImage
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}