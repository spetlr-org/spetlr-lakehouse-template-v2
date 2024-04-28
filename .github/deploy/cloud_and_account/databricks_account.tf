# This module is for managing the databricks account like metastore, groups, users, service pronicpals, ...

# Metastore admin spn and admin group
resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name               = var.db_metastore_admin_group
}

resource "databricks_service_principal" "db_meta_spn" {
  provider     = databricks.account
  application_id = azuread_service_principal.db_meta_spn.application_id
  display_name = var.db_metastore_spn_name
  depends_on = [
    azuread_service_principal.db_meta_spn
  ]
}

resource "databricks_service_principal_role" "db_meta_spn_role" {
  provider             = databricks.account
  service_principal_id = databricks_service_principal.db_meta_spn.id
  role                 = "account_admin"
  depends_on = [
    databricks_service_principal.db_meta_spn
  ]
}

resource "databricks_group_member" "metastore_admin_member" {
  provider     = databricks.account
  group_id  = databricks_group.db_metastore_admin_group.id
  member_id = databricks_service_principal.db_meta_spn.id
  depends_on = [
    databricks_group.db_metastore_admin_group,
    databricks_service_principal_role.db_meta_spn_role
  ]
}

# Provision Databricks Metastore and set the owner
resource "databricks_metastore" "db_metastore" {
  provider      = databricks.account
  name          = var.db_metastore_name
  owner = var.db_metastore_admin_group
  force_destroy = true
  region        = azurerm_resource_group.rg.location
  depends_on = [
    databricks_group.db_metastore_admin_group
  ]
}

# Workspace admin spn and admin group
resource "databricks_group" "db_ws_admin_group" {
  provider     = databricks.account
  display_name               = var.db_workspace_admin_group
}

resource "databricks_service_principal" "db_ws_spn" {
  provider     = databricks.account
  application_id = azuread_service_principal.db_ws_spn.application_id
  display_name = var.db_workspace_spn_name
  depends_on = [
    azuread_service_principal.db_ws_spn
  ]
}

resource "databricks_group_member" "ws_admin_member" {
  provider     = databricks.account
  group_id  = databricks_group.db_ws_admin_group.id
  member_id = databricks_service_principal.db_ws_spn.id
  depends_on = [
    databricks_group.db_ws_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

# We want the workspace admin spn also the role of metastore admin, so adding it to meta admin group
resource "databricks_group_member" "metastore_admin_member_ws" {
  provider     = databricks.account
  group_id  = databricks_group.db_metastore_admin_group.id
  member_id = databricks_service_principal.db_ws_spn.id
  depends_on = [
    databricks_group.db_metastore_admin_group,
    databricks_service_principal.db_ws_spn
  ]
}

resource "databricks_group" "db_table_user_group" {
  provider     = databricks.account
  display_name               = var.db_table_user_group
}
