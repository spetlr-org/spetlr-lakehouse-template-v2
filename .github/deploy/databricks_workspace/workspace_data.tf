data "databricks_group" "db_ws_admin_group" {
  provider = databricks.workspace
  display_name = var.db_workspace_admin_group
}

data "databricks_storage_credential" "ex_storage_cred" {
  provider = databricks.workspace
  name = local.resource_name
}