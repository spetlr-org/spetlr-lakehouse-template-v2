data "databricks_group" "admins" {
  display_name = "admins"
}

data "databricks_storage_credential" "ex_storage_cred" {
  name = local.resource_name
}