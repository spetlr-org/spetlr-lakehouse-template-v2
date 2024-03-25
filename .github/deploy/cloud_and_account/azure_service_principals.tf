# This module is for creating and managing needed service principals

# Giving necessary keyvault access to the cicd service principal 
resource "azurerm_key_vault_access_policy" "spn_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.cicd_spn.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]
}

# Provision azure spn for databricks metastore admin, and setting its role
resource "azuread_application" "db_application" {
  display_name = var.db_metastore_spn_name
  owners       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azuread_service_principal" "db_meta_spn" {
  client_id                    = azuread_application.db_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azuread_service_principal_password" "db_meta_spn_password" {
  service_principal_id = azuread_service_principal.db_meta_spn.object_id
}

resource "azurerm_role_assignment" "db_meta_spn_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.db_meta_spn.id
}

# Provision Azure SPN for Databricks workspace admin, and setting its role
resource "azuread_application" "db_ws_application" {
  display_name = var.db_workspace_spn_name
  owners       = [azuread_service_principal.db_meta_spn.object_id]
}

resource "azuread_service_principal" "db_ws_spn" {
  client_id                    = azuread_application.db_ws_application.client_id
  app_role_assignment_required = false
  owners                       = [azuread_service_principal.db_meta_spn.object_id]
}

resource "azuread_service_principal_password" "db_ws_spn_password" {
  service_principal_id = azuread_service_principal.db_ws_spn.object_id
}

resource "azurerm_role_assignment" "db_ws_spn_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.db_ws_spn.id
}