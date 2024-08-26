## This module is responsible for creating the necessary resources for ##
## Databricks account and workspace access control ##

# Extrenal location for medallion data components ------------------------------
resource "databricks_external_location" "ex_data_catalog_location" {
  provider        = databricks.workspace
  name            = "${var.environment}-${module.global_variables.az_data_container}"
  url             = "abfss://${module.global_variables.az_data_container}@${local.resource_name}.dfs.core.windows.net/"
  credential_name = data.databricks_storage_credential.ex_storage_cred.name
  comment         = "Databricks external location for data catalog"
  depends_on      = [
    data.databricks_storage_credential.ex_storage_cred
  ]
}

resource "databricks_grants" "ex_data_catalog_location_grants" {
  provider          = databricks.workspace
  external_location = databricks_external_location.ex_data_catalog_location.id
  grant {
    principal       = data.databricks_group.db_ws_admin_group.display_name
    privileges      = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_external_location.ex_data_catalog_location]
}

# Catalog permissions ---------------------------------------------------------
resource "databricks_grants" "data_catalog_grants" {
  provider     = databricks.workspace
  catalog      = databricks_catalog.db_data_catalog.name
  grant {
    principal  = data.databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on   = [
    databricks_catalog.db_data_catalog,
    ]
}

