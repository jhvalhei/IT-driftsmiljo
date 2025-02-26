resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  name                       = var.cae_name
  location                   = var.rg_location
  resource_group_name        = var.rg_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "capp" {
  name                         = var.capp_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.rg_name
  revision_mode                = var.capp_revmode

  template {
    container {
      name   = var.capp_name
      image  = var.capp_image
      cpu    = var.capp_cpu
      memory = var.capp_memory
    }
  }
}
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  name                       = var.cae_name
  location                   = var.rg_location
  resource_group_name        = var.rg_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "capp" {
  name                         = var.capp_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.rg_name
  revision_mode                = var.capp_revmode

  template {
    container {
      name   = var.capp_name
      image  = var.capp_image
      cpu    = var.capp_cpu
      memory = var.capp_memory
    }
  }
}