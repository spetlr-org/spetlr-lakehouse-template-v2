# This module is for creating keyvault secrets

# Create a secret for our azure subscription tenant id
resource "azurerm_key_vault_secret" "azure_tenant_id" {
  name         = var.azure_tenant_id
  value        = "${data.azurerm_client_config.current.tenant_id}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azurerm_key_vault_access_policy.spn_access
  ]
}

# Create a secret for the created databricks workspace url
resource "azurerm_key_vault_secret" "db_ws_url" {
  name         = var.db_ws_url
  value        = "https://${azurerm_databricks_workspace.db_workspace.workspace_url}/"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azurerm_databricks_workspace.db_workspace,
    azurerm_key_vault_access_policy.spn_access
  ]
}

# Create a secret for the created databricks workspace id
resource "azurerm_key_vault_secret" "db_ws_id" {
  name         = var.db_ws_id
  value        = "${azurerm_databricks_workspace.db_workspace.workspace_id}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azurerm_databricks_workspace.db_workspace,
    azurerm_key_vault_access_policy.spn_access
  ]
}

# Create secrets for the created metasore admin spn credentials
resource "azurerm_key_vault_secret" "db_meta_admin_spn_app_id" {
  name         = var.db_metastore_spn_app_id
  value        = "${azuread_service_principal.db_meta_spn.client_id}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azuread_service_principal.db_meta_spn,
    azurerm_key_vault_access_policy.spn_access
  ]
}

resource "azurerm_key_vault_secret" "db_meta_admin_spn_app_password" {
  name         = var.db_metastore_spn_app_password
  value        = "${azuread_service_principal_password.db_meta_spn_password.value}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azuread_service_principal_password.db_meta_spn_password,
    azurerm_key_vault_access_policy.spn_access
  ]
}

# Create secrets for the created workspace admin spn credentials
resource "azurerm_key_vault_secret" "db_ws_admin_spn_app_id" {
  name         = var.db_workspace_spn_app_id
  value        = "${azuread_service_principal.db_ws_spn.client_id}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azuread_service_principal.db_ws_spn,
    azurerm_key_vault_access_policy.spn_access
  ]
}

resource "azurerm_key_vault_secret" "db_ws_admin_spn_app_password" {
  name         = var.db_workspace_spn_app_password
  value        = "${azuread_service_principal_password.db_ws_spn_password.value}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault.key_vault,
    azuread_service_principal_password.db_ws_spn_password,
    azurerm_key_vault_access_policy.spn_access
  ]
}
