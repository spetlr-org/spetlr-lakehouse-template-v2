## This module is create secret scope and secrets for the Databricks workspace ##

# Secret scope for keyvault backed secrets -------------------------------------
resource "databricks_secret_scope" "keyvault_backed_scope" {
  provider = databricks.workspace
  name     = "secrets"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.key_vault.id
    dns_name    = data.azurerm_key_vault.key_vault.vault_uri
  }
  depends_on = [azurerm_key_vault_access_policy.ws_admin_spn_access]
}
