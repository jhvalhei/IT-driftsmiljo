resource "azurerm_resource_group" "container_apps" {
  name     = "test"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "log_test" {
  name                = "acctest-01"
  location            = azurerm_resource_group.container_apps.location
  resource_group_name = azurerm_resource_group.container_apps.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "c_a_env" {
  name                       = "test-Environment"
  location                   = azurerm_resource_group.container_apps.location
  resource_group_name        = azurerm_resource_group.container_apps.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_test.id
}

//Container for testEks
module "container_app" {
    source = "../modules/containers"
    containerapp-name = var.testEks-containerapp-name
    }


//Container for testEks
