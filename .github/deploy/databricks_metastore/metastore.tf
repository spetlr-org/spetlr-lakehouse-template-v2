# Metastore admin group
resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = var.db_metastore_admin_group
}

# Provision Databricks Metastore and set the owner
resource "databricks_metastore" "db_metastore" {
  provider      = databricks.account
  name          = var.db_metastore_name
  owner         = var.db_metastore_admin_group
  force_destroy = true
  region        = var.location
  depends_on    = [
    databricks_group.db_metastore_admin_group,
  ]
}