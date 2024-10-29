
# Giving necessary keyvault access to the workspace admin spn --------------------------------
resource "azurerm_key_vault_access_policy" "ws_admin_spn_access" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.db_workspace_admin_spn.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Purge",
    "Recover",
    "Restore",
  ]
}

# Create token for workspace admin -----------------------------------------------------------
resource "databricks_token" "ws_admin_token" {
  provider = databricks.workspace
  comment  = "Worspace admin token"
  // 365 day token
  lifetime_seconds = 31536000
}

# Store the Databricks token in Azure Key Vault
resource "azurerm_key_vault_secret" "ws_admin_oauth_token_secret" {
  name         = "Workspace--Admin-OAuth-Token"
  value        = databricks_token.ws_admin_token.token_value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}