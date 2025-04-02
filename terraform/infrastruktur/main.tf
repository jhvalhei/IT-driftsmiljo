terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-backend"
    storage_account_name = "sabackendsfbgel2py5"
    container_name       = "backend-container"
    key                  = "infragjovik.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  storage_use_azuread = true
  subscription_id     = "b03b0d6e-32d0-4c8b-a3df-e5054df8ed86"
}





resource "azurerm_resource_group" "rgstorage" {
  name     = "rg-variablestorage"
  location = var.rg_location_static
}




# Storage of terraform variables


resource "azurerm_storage_account" "sa" {
  name                      = "envstoragegjovik246"
  resource_group_name       = azurerm_resource_group.rgstorage.name
  location                  = azurerm_resource_group.rgstorage.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "sc" {
  name                  = "variables"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ctemplate" {
  name                   = "containerObj.json"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${var.rootPath}${var.ctemplatePath}"
  content_md5            = md5(file("${var.rootPath}${var.ctemplatePath}")) // Forces upload of new file upon changes in file
}

resource "azurerm_storage_blob" "dbtemplate" {
  name                   = "databaseObj.json"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${var.rootPath}${var.dbtemplatePath}"
  content_md5            = md5(file("${var.rootPath}${var.dbtemplatePath}")) // Forces upload of new file upon changes in file
}

resource "azurerm_storage_blob" "tfvariables" {
  name                   = "terraform.tfvars.json"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${var.rootPath}${var.tfvarsPath}"
  content_md5            = md5(file("${var.rootPath}${var.tfvarsPath}")) // Forces upload of new file upon changes in file
}

resource "random_string" "randomkvname" {
  length  = 10
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

# Key vault for storage of sensitive values.
resource "azurerm_key_vault" "kv" {
  name                       = "keyvault${random_string.randomkvname.result}"
  location                   = azurerm_resource_group.rgstorage.location
  resource_group_name        = azurerm_resource_group.rgstorage.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7

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





module "deployments" {
  source = "./deployments"

  # To use in deployments
  rg_dynamic         = var.rg_dynamic
  rg_name_static     = var.rg_name_static
  rg_location_static = var.rg_location_static

  # To use in containers
  law_name      = var.law_name
  law_sku       = var.law_sku
  law_retention = var.law_retention
  cae_name      = var.cae_name
  container     = var.container
  //dbserversecretId = azurerm_key_vault_secret.dbserversecret.id
  reguname   = var.reguname
  regtoken   = var.regtoken
  keyVaultId = azurerm_key_vault.kv.id

  # To use in database
  postgreserver_name             = var.postgreserver_name
  postgreserver_skuname          = var.postgreserver_skuname
  postgreserver_storage_mb       = var.postgreserver_storage_mb
  postgreserver_storage_tier     = var.postgreserver_storage_tier
  postgreserver_backup_retention = var.postgreserver_backup_retention
  postgreserver_redundant_backup = var.postgreserver_redundant_backup
  postgreserver_auto_grow        = var.postgreserver_auto_grow
  postgreserver_admin_uname      = var.postgreserver_admin_uname
  //postgreserver_admin_password        = azurerm_key_vault_secret.dbserversecret.value
  postgreserver_version               = var.postgreserver_version
  postgreserver_public_network_access = var.postgreserver_public_network_access
  postgreserver_zone                  = var.postgreserver_zone
  postdb                              = var.postdb

  #To use in network
  subnet_service_delegation_name    = var.subnet_service_delegation_name
  subnet_service_delegation_actions = var.subnet_service_delegation_actions
  nsg_name_db                            = var.nsg_name_db
  nsg_name_capp                          = var.nsg_name_capp
  vnet_name                              = var.vnet_name
  vnet_addresspace                       = var.vnet_addresspace
  subnet_db_name                         = var.subnet_db_name
  subnet_capp_name                       = var.subnet_capp_name
  subnet_db_address_prefixes             = var.subnet_db_address_prefixes
  subnet_capp_address_prefixes           = var.subnet_capp_address_prefixes
  subnet_service_endpoint                = var.subnet_service_endpoint
  subnet_db_delegation_name              = var.subnet_db_delegation_name
  subnet_capp_delegation_name            = var.subnet_capp_delegation_name
  subnet_db_service_delegation_name      = var.subnet_db_service_delegation_name
  subnet_capp_service_delegation_name    = var.subnet_capp_service_delegation_name
  subnet_db_service_delegation_actions   = var.subnet_db_service_delegation_actions
  subnet_capp_service_delegation_actions = var.subnet_capp_service_delegation_actions
  privdnszone_name                       = var.privdnszone_name
  privdnslink_name                       = var.privdnslink_name
}