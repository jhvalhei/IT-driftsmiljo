resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  depends_on = [ azurerm_log_analytics_workspace.law ]

  name                       = var.cae_name
  location                   = var.rg_location_static
  resource_group_name        = var.rg_name_static
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

data "azurerm_container_app_environment" "containerappenvdata" {
  depends_on = [ azurerm_container_app_environment.cae ]
  name                = azurerm_container_app_environment.cae.name
  resource_group_name = azurerm_container_app_environment.cae.resource_group_name
  #id = azurerm_container_app_environment.cae.id
}

resource "azurerm_container_app_secret" "ghcr" {
  for_each = var.container
  name                         = "ghcr_token"
  container_app_environment_id = data.azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  secret_name                  = "ghcr-token"
  value                        = each.value.regtoken  # Your GitHub PAT
}

resource "azurerm_container_app" "capp" {
  depends_on = [ data.azurerm_container_app_environment.containerappenvdata ]
  for_each = var.container

  name                         = lower("${each.value.name}-${each.value.rg}-${each.key}")
  container_app_environment_id = data.azurerm_container_app_environment.containerappenvdata.id
  resource_group_name          = each.value.rg
  revision_mode                = each.value.revmode

  registry {
    server   = each.value.regserver
    username = each.value.reguname
    password_secret_name = each.value.regtoken
  }

  template {
    container {
      name   = lower(each.value.name)
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
    }
  }
}