## Required data for azure and databricks account components ##

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "cicd_spn" {
  display_name = module.global_variables.cicdSpnName
}

data "azuread_service_principal" "db_meta_spn" {
  display_name = module.global_variables.db_metastore_spn_name
}

data "azuread_client_config" "current" {}

data "databricks_metastore" "db_metastore" {
  provider = databricks.account
  name     = module.global_variables.db_metastore_name
}

data "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = module.global_variables.db_metastore_admin_group
}

data "databricks_service_principal" "cicd_pipeline_spn" {
  provider       = databricks.account
  application_id = data.azuread_service_principal.cicd_spn.client_id
}
