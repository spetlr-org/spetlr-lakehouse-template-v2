
## This module is for managing the databricks account like metastore, groups, users, SPNs, ... ##

# Manage Workspace admin groups, SPNs and members ----------------------------------------------
resource "databricks_group" "db_ws_admin_group" {
  provider     = databricks.account
  display_name = local.db_workspace_admin_group_env
}

resource "databricks_service_principal" "db_ws_spn" {
  provider       = databricks.account
  application_id = azuread_service_principal.db_ws_spn.client_id
  display_name   = local.db_workspace_spn_name
  depends_on = [
    azuread_service_principal.db_ws_spn
  ]
}
resource "databricks_service_principal_secret" "db_ws_spn_secret" {
  provider = databricks.account
  service_principal_id = databricks_service_principal.db_ws_spn.id
}

resource "databricks_group_member" "ws_admin_member" {
  provider  = databricks.account
  group_id  = databricks_group.db_ws_admin_group.id
  member_id = databricks_service_principal.db_ws_spn.id
  depends_on = [
    databricks_group.db_ws_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

## For spetlr test purposes, we need to add cicd spn to the workspace admin group
resource "databricks_group_member" "ws_admin_member_cicd" {
  provider  = databricks.account
  group_id  = databricks_group.db_ws_admin_group.id
  member_id = data.databricks_service_principal.cicd_pipeline_spn.id
  depends_on = [
    databricks_group.db_ws_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

## We want the workspace admin spn also the role of metastore admin, so adding it to meta admin group
resource "databricks_group_member" "metastore_admin_member_ws" {
  provider  = databricks.account
  group_id  = data.databricks_group.db_metastore_admin_group.id
  member_id = databricks_service_principal.db_ws_spn.id
  depends_on = [
    data.databricks_group.db_metastore_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

# Manage Workspace user groups, SPNs and members ----------------------------------------------
resource "databricks_group" "db_table_user_group" {
  provider     = databricks.account
  display_name = local.db_table_user_group_env
}
