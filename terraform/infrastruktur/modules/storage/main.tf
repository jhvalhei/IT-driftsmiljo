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