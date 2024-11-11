## This module is for deploying all the azure cloud resources needed for the databricks lakehouse ##

# Provision resource group -----------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = module.global_variables.location
  tags     = module.global_variables.tags
}

# Provision virtual network ----------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = local.resource_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.resource_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.26.1.0/24"] # This should be aligned with organizations network

  subnet {
    name             = module.global_variables.vnet_public_subnet_name
    address_prefixes = ["10.26.1.0/25"]
    delegation {
      name = "delegation-to-databricks-public"
      service_delegation {
        name    = "Microsoft.Databricks/workspaces"
      }
    }
  }

  subnet {
    name             = module.global_variables.vnet_private_subnet_name
    address_prefixes = ["10.26.1.128/25"] # Should not overlap with the public subnet
    delegation {
      name = "delegation-to-databricks-private"
      service_delegation {
        name    = "Microsoft.Databricks/workspaces"
      }
    }
  }
  tags               = module.global_variables.tags
  depends_on         = [azurerm_resource_group.rg]
}

data "azurerm_subnet" "public_subnet" {
  name                 = module.global_variables.vnet_public_subnet_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.vnet]
}

data "azurerm_subnet" "private_subnet" {
  name                 = module.global_variables.vnet_private_subnet_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = data.azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = data.azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
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

## Landing container
resource "azurerm_storage_container" "landing" {
  name                  = module.global_variables.az_landing_container
  storage_account_name  = azurerm_storage_account.storage_account_ingestion.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.storage_account_ingestion]
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
  network_security_group_rules_required = "AllRules"
  custom_parameters {
    virtual_network_id = azurerm_virtual_network.vnet.id
    public_subnet_name = module.global_variables.vnet_public_subnet_name
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.public.id
    private_subnet_name = module.global_variables.vnet_private_subnet_name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }
  tags                = module.global_variables.tags
  depends_on          = [azurerm_resource_group.rg]
}
