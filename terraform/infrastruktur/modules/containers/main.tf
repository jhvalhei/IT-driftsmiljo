data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  depends_on = [azurerm_log_analytics_workspace.law]

  name                       = var.cae_name
  location                   = var.rg_location_static
  resource_group_name        = var.rg_name_static
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id   = var.cenv_subnet_id
  infrastructure_resource_group_name = "container-env-infra"

    workload_profile {
    name = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count = 0
    minimum_count = 0
  }  
}

# Identity for container app
resource "azurerm_user_assigned_identity" "ca_identity" {
  location            = var.rg_location_static
  name                = "ca_identity"
  resource_group_name = var.rg_name_static
}
# Role assignment so identity can access key vault
resource "azurerm_role_assignment" "principal_rbac" {
  scope                = var.keyVaultId
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
# Role assignment so identity can use secrets
resource "azurerm_role_assignment" "azurewaysecret_reader" {
  scope                = azurerm_key_vault_secret.dbserversecret.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
}

resource "random_password" "randomsdbsecret" {
  length  = 20
  special = false
}

# Database admin password generated with random_string
resource "azurerm_key_vault_secret" "dbserversecret" {
  name         = "db-server-admin-secret"
  value        = random_password.randomsdbsecret.result
  key_vault_id = var.keyVaultId
  depends_on   = [azurerm_role_assignment.principal_rbac]
}


resource "azurerm_container_app" "capp" {
  depends_on = [azurerm_container_app_environment.cae]
  for_each   = var.container

  name                         = lower(each.value.name)
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = each.value.rg
  revision_mode                = each.value.revmode

  # Password for github container registry, stored in github secrets
  secret {
    name  = lower(each.key)
    value = var.regtoken
  }

  # Github registry credentials
  registry {
    server               = each.value.regserver
    username             = var.reguname
    password_secret_name = lower(each.key)
  }

  # Password to database, stored in key vault
  secret {
    name                = "dbsecret"
    key_vault_secret_id = azurerm_key_vault_secret.dbserversecret.id
    identity            = azurerm_user_assigned_identity.ca_identity.id
  }

  ingress {
    traffic_weight {
      percentage      = each.value.trafficweight
      latest_revision = each.value.latestrevision
    }
    target_port      = each.value.targetport
    external_enabled = each.value.external
  }
  # Identity to access key vault secrets (service principle)

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }


  template {
    container {
      name   = lower(each.value.name)
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
      env {
        name        = "DBSECRET"
        secret_name = "dbsecret"
      }
    }
    revision_suffix = "v1"
  }

}