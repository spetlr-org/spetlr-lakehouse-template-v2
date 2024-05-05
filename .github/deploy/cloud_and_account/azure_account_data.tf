# Required data fields for azure cloud

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "cicd_spn" {
  display_name = var.cicdSpnName
}

data "azuread_client_config" "current" {}

data "databricks_metastore" "db_metastore" {
  provider     = databricks.account
  name         = var.db_metastore_name
}

data "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = var.db_metastore_admin_group
}