data "azurerm_client_config" "current" {}


resource "random_string" "randomkvname" {
  length  = 10
  special = false
  upper   = false
}

# Key vault for storage of sensitive values.
resource "azurerm_key_vault" "kv" {
  name                       = "keyvault${random_string.randomkvname.result}"
  location                   = var.rg_location_storage
  resource_group_name        = var.rg_name_storage
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "Delete",
      "Purge"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "random_password" "db_admin_serversecret" {
  length  = 20
  special = false
}



# Database admin password generated with random_string
resource "azurerm_key_vault_secret" "db_admin_serversecret" {
  name         = "db-server-admin-secret"
  value        = random_password.db_admin_serversecret.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.principal_rbac]
}




resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location_global
  resource_group_name = var.rg_name_global
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  depends_on = [azurerm_log_analytics_workspace.law]

  name                               = var.cae_name
  location                           = var.rg_location_global
  resource_group_name                = var.rg_name_global
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id           = var.cenv_subnet_id
  infrastructure_resource_group_name = "rg-container-env-infra"

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}

# Grant key vault management access to service principle
resource "azurerm_role_assignment" "principal_rbac" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "random_password" "db_capp_secret" {
  for_each = azurerm_user_assigned_identity.capp_identity

  length  = 20
  special = false
}

# DB password for each container which needs database access
resource "azurerm_key_vault_secret" "db_capp_secret" {
  for_each = azurerm_user_assigned_identity.capp_identity

  name         = "${lower(each.key)}-dbsecret"
  value        = random_password.db_capp_secret[each.key].result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.principal_rbac]
}

# Identity for each container app with database access
resource "azurerm_user_assigned_identity" "capp_identity" {
  for_each = var.capp_identity

  name                = lower(each.value.name)
  location            = var.rg_dynamic[each.key].location
  resource_group_name = var.rg_dynamic[each.key].name
}

# Grant secret accss to each identity
resource "azurerm_role_assignment" "azurewaysecret_reader" {
  for_each = azurerm_user_assigned_identity.capp_identity

  scope                = azurerm_key_vault_secret.db_capp_secret[each.key].resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value.principal_id
}


resource "azurerm_container_app" "capp_with_db" {
  for_each   = var.capp_with_db
  depends_on = [azurerm_role_assignment.azurewaysecret_reader]

  name                         = lower(each.value.name)
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.rg_dynamic[each.key].name
  revision_mode                = each.value.revmode

  # Password for github container registry, stored in github secrets
  secret {
    name  = "ghcr-password"
    value = var.regtoken
  }

  # Github registry credentials
  registry {
    server               = each.value.regserver
    username             = var.reguname
    password_secret_name = "ghcr-password"
  }

  # Password to database, stored in key vault
  secret {
    name                = "dbsecret"
    key_vault_secret_id = azurerm_key_vault_secret.db_capp_secret[each.key].id
    identity            = azurerm_user_assigned_identity.capp_identity[each.key].id
  }

  ingress {
    traffic_weight {
      percentage      = each.value.trafficweight
      latest_revision = each.value.latestrevision
    }
    target_port      = each.value.targetport
    external_enabled = each.value.external
    ip_security_restriction {
      name             = "Container app IP restriction allow"
      action           = "Allow"
      ip_address_range = each.value.ip_restriction_range
    }
  }

  # Identity used to access key vault secrets (service principle)
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.capp_identity[each.key].id]
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
  }
}

resource "azurerm_container_app" "capp_without_db" {
  for_each   = var.capp_without_db
  depends_on = [azurerm_container_app_environment.cae]

  name                         = lower(each.value.name)
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.rg_dynamic[each.key].name
  revision_mode                = each.value.revmode

  # Password for github container registry, stored in github secrets
  secret {
    name  = "ghcr-password"
    value = var.regtoken
  }

  # Github registry credentials
  registry {
    server               = each.value.regserver
    username             = var.reguname
    password_secret_name = "ghcr-password"
  }

  ingress {
    traffic_weight {
      percentage      = each.value.trafficweight
      latest_revision = each.value.latestrevision
    }
    target_port      = each.value.targetport
    external_enabled = each.value.external
    ip_security_restriction {
      name             = "Container app IP restriction allow"
      action           = "Allow"
      ip_address_range = each.value.ip_restriction_range
    }
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

