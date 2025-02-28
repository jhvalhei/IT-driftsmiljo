resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  name                       = var.cae_name
  location                   = var.rg_location_static
  resource_group_name        = var.rg_name_static
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "capp" {
  for_each = var.container

  name                         = lower(each.value.name)
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.rg_name_dynamic
  revision_mode                = each.value.revmode

  template {
    container {
      name   = lower(each.value.name)
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
    }
  }
}