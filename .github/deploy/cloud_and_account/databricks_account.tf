# This module is for managing the databricks account like metastore, groups, users, service pronicpals, ...

# Metastore admin spn and admin group
resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = local.db_metastore_admin_group
}

resource "databricks_service_principal" "db_meta_spn" {
  provider       = databricks.account
  application_id = azuread_service_principal.db_meta_spn.application_id
  display_name   = local.db_metastore_spn_name
  depends_on     = [
    azuread_service_principal.db_meta_spn
  ]
}

resource "databricks_service_principal_role" "db_meta_spn_role" {
  provider             = databricks.account
  service_principal_id = databricks_service_principal.db_meta_spn.id
  role                 = "account_admin"
  depends_on           = [
    databricks_service_principal.db_meta_spn
  ]
}

resource "databricks_group_member" "metastore_admin_member" {
  provider   = databricks.account
  group_id   = databricks_group.db_metastore_admin_group.id
  member_id  = databricks_service_principal.db_meta_spn.id
  depends_on = [
    databricks_group.db_metastore_admin_group,
    databricks_service_principal_role.db_meta_spn_role
  ]
}

# Workspace admin spn and admin group
resource "databricks_group" "db_ws_admin_group" {
  provider     = databricks.account
  display_name = local.db_workspace_admin_group
}

resource "databricks_service_principal" "db_ws_spn" {
  provider       = databricks.account
  application_id = azuread_service_principal.db_ws_spn.application_id
  display_name   = local.db_workspace_spn_name
  depends_on     = [
    azuread_service_principal.db_ws_spn
  ]
}

resource "databricks_group_member" "ws_admin_member" {
  provider   = databricks.account
  group_id   = databricks_group.db_ws_admin_group.id
  member_id  = databricks_service_principal.db_ws_spn.id
  depends_on = [
    databricks_group.db_ws_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

# We want the workspace admin spn also the role of metastore admin, so adding it to meta admin group
resource "databricks_group_member" "metastore_admin_member_ws" {
  provider   = databricks.account
  group_id   = databricks_group.db_metastore_admin_group.id
  member_id  = databricks_service_principal.db_ws_spn.id
  depends_on = [
    databricks_group.db_metastore_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}


# Here, we add environment-based metastore admin group to the metastore admin group
resource "databricks_group_member" "metastore_admin_member_env" {
  provider   = databricks.account
  group_id   = data.databricks_group.db_metastore_admin_group.id
  member_id = databricks_group.db_metastore_admin_group.id
  depends_on = [
    data.databricks_group.db_metastore_admin_group,
    databricks_group.db_metastore_admin_group
  ]
}

resource "databricks_group" "db_table_user_group" {
  provider     = databricks.account
  display_name = local.db_table_user_group
}

