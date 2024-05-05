data "databricks_group" "db_ws_admin_group" {
  provider     = databricks.workspace
  display_name = var.db_workspace_admin_group
}

data "databricks_storage_credential" "ex_storage_cred" {
  provider = databricks.workspace
  name     = local.resource_name
}

data "azurerm_key_vault" "key_vault" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "workspace_url" {
  name                = var.db_ws_url
  key_vault_id        = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_id" {
  name                = var.db_workspace_spn_app_id
  key_vault_id        = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_password" {
  name                = var.db_workspace_spn_app_password
  key_vault_id        = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name                = var.azure_tenant_id
  key_vault_id        = data.azurerm_key_vault.key_vault.id
}