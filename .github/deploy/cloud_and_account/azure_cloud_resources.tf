## This module is for deploying all the azure cloud resources needed for the databricks lakehouse ##

# Provision resource group -----------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = module.global_variables.location
  tags     = module.global_variables.tags
}

# Provision storage accounts -----------------------------------------------------
resource "azurerm_storage_account" "storage_account_ingestion" {
  name                     = local.datalake_ingestion_resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = module.global_variables.tags
  depends_on               = [azurerm_resource_group.rg]
}

resource "azurerm_storage_account" "storage_account" {
  name                     = local.resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = module.global_variables.tags
  depends_on               = [azurerm_resource_group.rg]
}

# Provision keyvault -----------------------------------------------------------
resource "azurerm_key_vault" "key_vault" {
  name                       = local.resource_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  depends_on                 = [azurerm_resource_group.rg]
}

# Provision access connector and setting its roles ------------------------------
resource "azurerm_databricks_access_connector" "ext_access_connector" {
  name                = local.resource_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_role_assignment" "ext_storage_role_ingestion_data_reader" {
  scope                = azurerm_storage_account.storage_account_ingestion.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_databricks_access_connector.ext_access_connector.identity[0].principal_id
  depends_on = [
    azurerm_databricks_access_connector.ext_access_connector,
    azurerm_storage_account.storage_account_ingestion
  ]
}

resource "azurerm_role_assignment" "ext_storage_role" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.ext_access_connector.identity[0].principal_id
  depends_on = [
    azurerm_databricks_access_connector.ext_access_connector,
    azurerm_storage_account.storage_account
  ]
}

# Provision containers ---------------------------------------------------------

## Ingestion container
resource "azurerm_storage_container" "ingestion" {
  name                  = module.global_variables.az_ingestion_container
  storage_account_name  = azurerm_storage_account.storage_account_ingestion.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account_ingestion]
}

## Landing container
resource "azurerm_storage_container" "landing" {
  name                  = module.global_variables.az_landing_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

## Data container
resource "azurerm_storage_container" "data" {
  name                  = module.global_variables.az_data_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

## Infrastructure container
resource "azurerm_storage_container" "infrastructure" {
  name                  = module.global_variables.az_infrastructure_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

# Provision databricks service ------------------------------------------------
resource "azurerm_databricks_workspace" "db_workspace" {
  name                = local.resource_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "premium"
  tags                = module.global_variables.tags
  depends_on          = [azurerm_resource_group.rg]
}
