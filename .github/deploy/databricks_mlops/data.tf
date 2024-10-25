data "azurerm_key_vault" "key_vault" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "workspace_url" {
  name         = module.global_variables.az_kv_db_ws_url
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_id" {
  name         = module.global_variables.az_kv_db_workspace_spn_app_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_password" {
  name         = module.global_variables.az_kv_db_workspace_spn_app_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name         = module.global_variables.az_kv_tenant_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}