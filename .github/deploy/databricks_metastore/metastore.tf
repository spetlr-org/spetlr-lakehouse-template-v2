# Metastore admin group
resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = var.db_metastore_admin_group
}

# Wait for the group to complete. This might not be necessary.
resource "time_sleep" "wait_for_group_creation" {
  create_duration = "5s"
  depends_on      = [
    databricks_group.db_metastore_admin_group
    ]
}

# Provision Databricks Metastore and set the owner
resource "databricks_metastore" "db_metastore" {
  provider      = databricks.account
  name          = var.db_metastore_name
  owner         = databricks_group.db_metastore_admin_group.display_name
  force_destroy = true
  region        = var.location
  depends_on    = [
    databricks_group.db_metastore_admin_group,
    time_sleep.wait_for_group_creation
  ]
}