# Assign the workspace to the created Metastore
resource "databricks_metastore_assignment" "db_metastore_assign_workspace" {
  provider      = databricks.account
  metastore_id = databricks_metastore.db_metastore.id
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  depends_on = [
    databricks_metastore.db_metastore,
    azurerm_databricks_workspace.db_workspace
  ]
}

# Add metastore admin group in the workspace as workspace admin
resource "databricks_mws_permission_assignment" "add_metastore_admin_group_to_workspace" {
  provider      = databricks.account
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  principal_id = databricks_group.db_metastore_admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    azurerm_databricks_workspace.db_workspace,
    databricks_group.db_metastore_admin_group
  ]
}

# Add workspace admin group in the workspace as workspace admin
resource "databricks_mws_permission_assignment" "add_workspace_group_to_workspace" {
  provider      = databricks.account
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  principal_id = databricks_group.db_ws_admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    azurerm_databricks_workspace.db_workspace,
    databricks_group.db_ws_admin_group
  ]
}

# Grant metastore privilages to metastore admin group
resource "databricks_grants" "metastore_admin_grants" {
  provider = databricks.workspace
  metastore = databricks_metastore.db_metastore.id
  grant {
    principal  = databricks_group.db_metastore_admin_group.display_name
    privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
  }
  depends_on = [
    databricks_metastore.db_metastore,
    databricks_group.db_metastore_admin_group,
    databricks_metastore_assignment.db_metastore_assign_workspace
  ]
}

# External storage assignments
resource "databricks_storage_credential" "ex_storage_cred" {
  provider = databricks.workspace
  name = azurerm_databricks_access_connector.ext_access_connector.name
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector.id
  }
  comment = "Datrabricks external storage credentials"
  depends_on = [
    databricks_metastore_assignment.db_metastore_assign_workspace
  ]
}

resource "databricks_grants" "ex_creds" {
  provider = databricks.workspace
  storage_credential = databricks_storage_credential.ex_storage_cred.id
  grant {
    principal  = var.db_workspace_admin_group
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = var.db_metastore_admin_group
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_storage_credential.ex_storage_cred]
}

# Extrenal location for infrastructure components

## External location for infrastructure volume / libraries
resource "databricks_external_location" "ex_infrastructure_libraries_volume_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.infrastructure_libraries_folder}"
  url = "abfss://${var.infrastructure_volume_container}@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/${var.infrastructure_libraries_folder}"

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for infrastructure catalog"
  depends_on = [
    databricks_grants.ex_creds
  ]
}

resource "databricks_grants" "ex_infrastructure_libraries_volume_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_infrastructure_libraries_volume_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_external_location.ex_infrastructure_libraries_volume_location]
}

## External location for infrastructure volume / tests
resource "databricks_external_location" "ex_infrastructure_tests_volume_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.infrastructure_tests_folder}"
  url = "abfss://${var.infrastructure_volume_container}@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/${var.infrastructure_tests_folder}"

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for infrastructure catalog"
  depends_on = [
    databricks_grants.ex_creds
  ]
}

resource "databricks_grants" "ex_infrastructure_tests_volume_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_infrastructure_tests_volume_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_external_location.ex_infrastructure_tests_volume_location]
}

## Extrenal location for medallion data components 
resource "databricks_external_location" "ex_data_catalog_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.data_catalog_container}"
  url = format("abfss://%s@%s.dfs.core.windows.net/",
    var.data_catalog_container,
  azurerm_storage_account.storage_account.name)

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for data catalog"
  depends_on = [
    databricks_grants.ex_creds
  ]
}

resource "databricks_grants" "ex_data_catalog_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_data_catalog_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_external_location.ex_data_catalog_location]
}

## Extrenal location for landing data components 
resource "databricks_external_location" "ex_landing_data_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.landing_storage_container}"
  url = "abfss://${var.landing_storage_container}@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for landing data"
  depends_on = [
    databricks_grants.ex_creds
  ]
}

resource "databricks_grants" "ex_landing_data_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_landing_data_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [databricks_external_location.ex_landing_data_location]
}

# Catalog permissions
resource "databricks_grants" "data_catalog_grants" {
  provider     = databricks.workspace
  catalog = databricks_catalog.db_data_catalog.name
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
   grant {
    principal  = databricks_group.db_metastore_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [
    databricks_catalog.db_data_catalog,
    databricks_mws_permission_assignment.add_metastore_admin_group_to_workspace,
    databricks_mws_permission_assignment.add_workspace_group_to_workspace,
    databricks_group.db_ws_admin_group,
    databricks_group.db_metastore_admin_group
    ]
}

