# Storage of terraform variables
resource "azurerm_storage_account" "sa" {
  name                      = "envstoragegjovik246"
  resource_group_name       = var.rg_name_storage
  location                  = var.rg_location_storage
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "sc" {
  name                  = "variables"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

locals {
  tfvarsPath = "/terraform/infrastruktur/terraform.tfvars.json"
}

# Uploads the local file "terraform.tvars.json" to Azure Blob Storage
resource "azurerm_storage_blob" "tfvariables" {
  name                   = "terraform.tfvars.json"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${var.rootPath}${local.tfvarsPath}"
  content_md5            = md5(file("${var.rootPath}${local.tfvarsPath}")) // Forces upload of new file upon changes in file
}