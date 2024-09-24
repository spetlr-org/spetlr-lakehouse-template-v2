## This module is responsible for creating the necessary resources for ##
## Databricks account and workspace access control ##

# Access control for metastore and workspace ---------------------------------------------------------------

## Assign the workspace to the created Metastore
resource "databricks_metastore_assignment" "db_metastore_assign_workspace" {
  provider     = databricks.account
  metastore_id = data.databricks_metastore.db_metastore.id
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  depends_on = [
    data.databricks_metastore.db_metastore,
    azurerm_databricks_workspace.db_workspace
  ]
}

resource "time_sleep" "wait_for_metastore_assign" {
  create_duration = "10s"
  depends_on = [
    databricks_metastore_assignment.db_metastore_assign_workspace
  ]
}

# Access control for users, groups and principals ---------------------------------------------------------

## Add metastore admin group to the workspace as the workspace admin
resource "databricks_mws_permission_assignment" "add_metastore_admin_group_to_workspace" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  principal_id = data.databricks_group.db_metastore_admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    azurerm_databricks_workspace.db_workspace,
    data.databricks_group.db_metastore_admin_group,
    time_sleep.wait_for_metastore_assign
  ]
}

## Add workspace admin group to the workspace as the workspace admin
resource "databricks_mws_permission_assignment" "add_workspace_group_to_workspace" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  principal_id = databricks_group.db_ws_admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    azurerm_databricks_workspace.db_workspace,
    databricks_group.db_ws_admin_group,
    time_sleep.wait_for_metastore_assign
  ]
}

## Add table user group to the workspace as the workspace user
resource "databricks_mws_permission_assignment" "add_table_user_group_to_workspace" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
  principal_id = databricks_group.db_table_user_group.id
  permissions  = ["USER"]
  depends_on = [
    azurerm_databricks_workspace.db_workspace,
    databricks_group.db_table_user_group,
    time_sleep.wait_for_metastore_assign
  ]
}

## Wait for syncing groups from account to the workspace
resource "time_sleep" "wait_for_groups_sync" {
  create_duration = "10s"
  depends_on = [
    databricks_mws_permission_assignment.add_metastore_admin_group_to_workspace,
    databricks_mws_permission_assignment.add_workspace_group_to_workspace,
    databricks_mws_permission_assignment.add_table_user_group_to_workspace
  ]
}

# Access control for External location --------------------------------------------------------------------

## Create storage credential and grant privileges
resource "databricks_storage_credential" "ex_storage_cred" {
  provider = databricks.workspace
  name     = local.resource_name
  comment  = "Datrabricks external storage credentials"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector.id
  }
  depends_on = [
    databricks_metastore_assignment.db_metastore_assign_workspace,
    time_sleep.wait_for_groups_sync
  ]
}

resource "time_sleep" "wait_for_ex_storage_cred" {
  create_duration = "15s"
  depends_on = [
    databricks_storage_credential.ex_storage_cred
  ]
}

resource "databricks_grants" "ex_creds" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.ex_storage_cred.id
  grant {
    principal  = local.db_workspace_admin_group_env
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [
    databricks_storage_credential.ex_storage_cred,
    time_sleep.wait_for_ex_storage_cred
  ]
}

resource "time_sleep" "wait_for_ex_storage_cred_grants" {
  create_duration = "15s"
  depends_on = [
    databricks_grants.ex_creds
  ]
}

## Create external location and grant privilages for infrastructure catalog data storage ---------------
resource "databricks_external_location" "infrastructure" {
  provider = databricks.workspace
  name     = "${var.environment}-${module.global_variables.az_infrastructure_container}"
  url = join(
    "",
    [
      "abfss://${module.global_variables.az_infrastructure_container}",
      "@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/"
    ]
  )
  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for infrastructure catalog"
  depends_on = [
    databricks_grants.ex_creds,
    time_sleep.wait_for_ex_storage_cred_grants
  ]
}

resource "time_sleep" "wait_for_infrastructure_ext_location" {
  create_duration = "5s"
  depends_on = [
    databricks_external_location.infrastructure
  ]
}

resource "databricks_grants" "infrastructure" {
  provider          = databricks.workspace
  external_location = databricks_external_location.infrastructure.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.db_metastore_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [
    databricks_external_location.infrastructure,
    time_sleep.wait_for_infrastructure_ext_location
  ]
}

## Create external location and grant privilages for landing data storage 
resource "databricks_external_location" "landing" {
  provider = databricks.workspace
  name     = "${var.environment}-${var.az_landing_storage_container}"
  url = join(
    "",
    [
      "abfss://${var.az_landing_storage_container}",
      "@${azurerm_storage_account.storage_account.name}.dfs.core.windows.net/"
    ]
  )
  credential_name = databricks_storage_credential.ex_storage_cred.id
  comment         = "Databricks external location for landing data"
  depends_on = [
    databricks_grants.ex_creds,
    time_sleep.wait_for_ex_storage_cred_grants
  ]
}

resource "time_sleep" "wait_for_landing_ext_location" {
  create_duration = "5s"
  depends_on = [
    databricks_external_location.landing
  ]
}

resource "databricks_grants" "landing" {
  provider          = databricks.workspace
  external_location = databricks_external_location.landing.id
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.db_metastore_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [
    databricks_external_location.landing,
    time_sleep.wait_for_landing_ext_location
  ]
}

# Access control for catalogs -------------------------------------------------------------------------

## Grant privilages for the infrastructure catalog
resource "databricks_grants" "infrastructure_catalog" {
  provider = databricks.workspace
  catalog  = databricks_catalog.db_infrastructure_catalog.name
  grant {
    principal  = databricks_group.db_ws_admin_group.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [
    databricks_catalog.db_infrastructure_catalog,
    databricks_mws_permission_assignment.add_metastore_admin_group_to_workspace,
    databricks_mws_permission_assignment.add_workspace_group_to_workspace,
    databricks_group.db_ws_admin_group,
    data.databricks_group.db_metastore_admin_group
  ]
}
