# Provision azure spn for databricks metastore admin, and setting its role
resource "azuread_application" "db_application" {
  display_name = module.global_variables.db_metastore_spn_name
  owners       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azuread_service_principal" "db_meta_spn" {
  client_id                    = azuread_application.db_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azurerm_role_assignment" "db_meta_spn_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.db_meta_spn.object_id
}
