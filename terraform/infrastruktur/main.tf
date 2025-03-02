terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
  subscription_id = "b03b0d6e-32d0-4c8b-a3df-e5054df8ed86"
}

module "deployments" {
  source = "./deployments"

  # To use in deployments
  rg_dynamic = var.rg_dynamic
  rg_name_static = var.rg_name_static
  rg_location_static = var.rg_location_static

  # To use in containers
  law_name = var.law_name
  law_sku = var.law_sku
  law_retention = var.law_retention
  cae_name = var.cae_name

  /**
  capp_name = var.capp_name
  capp_revmode = var.capp_revmode
  capp_image = var.capp_image
  capp_cpu = var.capp_cpu
  capp_memory = var.capp_memory
  **/

  # To use in database
  postgreserver_name = var.postgreserver_name
  postgreserver_skuname = var.postgreserver_skuname
  postgreserver_storage_mb = var.postgreserver_storage_mb
  postgreserver_backup_retention = var.postgreserver_backup_retention
  postgreserver_redundant_backup = var.postgreserver_redundant_backup
  postgreserver_auto_grow = var.postgreserver_auto_grow
  postgreserver_admin_uname = var.postgreserver_admin_uname
  postgreserver_admin_password = var.postgreserver_admin_password
  postgreserver_version = var.postgreserver_version
  postgreserver_ssl = var.postgreserver_ssl

  /**
  postdb_name = var.postdb_name
  postdb_charset = var.postdb_charset
  postdb_collation = var.postdb_collation
  postdb_prevent_destroy = var.postdb_prevent_destroy
  **/
}