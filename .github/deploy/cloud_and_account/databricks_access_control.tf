# Assign the workspace to the created Metastore
resource "databricks_metastore_assignment" "db_metastore_assign_workspace" {
  provider      = databricks.account
  metastore_id = databricks_metastore.db_metastore.id
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
}


resource "databricks_permission_assignment" "db_ws_admins_assign" {
  provider     = databricks.workspace
  principal_id = databricks_group.db_ws_admin_group.id
  permissions  = ["ADMIN"]
}

# Grant metastore privilages to metastore admin group
resource "databricks_grants" "metastore_grants" {
  provider = databricks.workspace
  metastore = databricks_metastore.db_metastore.id
  grant {
    principal  = databricks_group.db_metastore_admin_group.display_name
    privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION"]
  }
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
}

# Extrenal location for infrastructure components

## External location for infrastructure volume
resource "databricks_external_location" "ex_infrastructure_volume_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.infrastructure_volume_container}"
  url = "abfss://${var.infrastructure_volume_container}@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/${var.infrastructure_volume_container}"

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for infrastructure catalog"
  depends_on = [
    databricks_metastore_assignment.db_metastore_assign_workspace
  ]
}

resource "databricks_grants" "ex_infrastructure_volume_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_infrastructure_volume_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}


## Extrenal location for data components 
resource "databricks_external_location" "ex_data_catalog_location" {
  provider = databricks.workspace
  name = "${var.environment}-${var.data_catalog_container}"
  url = format("abfss://%s@%s.dfs.core.windows.net/",
    var.data_catalog_container,
  azurerm_storage_account.storage_account.name)

  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for data catalog"
  depends_on = [
    databricks_metastore_assignment.db_metastore_assign_workspace
  ]
}

resource "databricks_grants" "ex_data_catalog_grants" {
  provider = databricks.workspace
  external_location = databricks_external_location.ex_data_catalog_location.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}