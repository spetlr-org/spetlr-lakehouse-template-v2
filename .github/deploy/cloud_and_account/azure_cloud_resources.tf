# This module is for deploying all the azure cloud resources needed for our databricks lakehouse

# Provision resource group
resource "azurerm_resource_group" "rg" {
  name      = local.resource_group_name
  location  = var.location  # Change this as needed
  tags = {
    creator = var.creator_tag
    system  = var.system_tag
    service = var.service_tag
  }
}

# Provision keyvault
resource "azurerm_key_vault" "key_vault" {
  name                       = local.resource_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.vault_sku_name
  soft_delete_retention_days = 7
  depends_on = [azurerm_resource_group.rg]
}

# Provision access connector and setting its role
resource "azurerm_databricks_access_connector" "ext_access_connector" {
  name                = local.resource_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_role_assignment" "ext_storage_role" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.ext_access_connector.identity[0].principal_id
  depends_on = [azurerm_databricks_access_connector.ext_access_connector]
}

# Provision storage account 
resource "azurerm_storage_account" "storage_account" {
  name                     = local.resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled = true

  tags = {
    creator = var.creator_tag
    system  = var.system_tag
    service = var.service_tag
  }
  depends_on = [azurerm_resource_group.rg]
}

# Provision containers

## Landing container
resource "azurerm_storage_container" "landing_storage_containers" {
  name  = var.landing_storage_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

## Data catalog container
resource "azurerm_storage_container" "data_catalog_container" {
  name  = var.data_catalog_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

## Infrastructure catalog container
resource "azurerm_storage_container" "infrastructure_volume_container" {
  name                  = var.infrastructure_volume_container
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account]
}

# Provision databricks service
resource "azurerm_databricks_workspace" "db_workspace" {
  name                        = local.resource_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku                         = "premium"
  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
  depends_on                  = [azurerm_resource_group.rg]
}