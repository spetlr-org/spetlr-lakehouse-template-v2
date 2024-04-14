data "databricks_group" "admins" {
  provider = databricks.workspace
  display_name = "admins"
}

data "databricks_storage_credential" "ex_storage_cred" {
  provider = databricks.workspace
  name = local.resource_name
}