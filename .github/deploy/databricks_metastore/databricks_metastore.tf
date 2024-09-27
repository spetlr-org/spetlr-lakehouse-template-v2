# Provision Databricks Metastore and set the owner
resource "databricks_metastore" "db_metastore" {
  provider      = databricks.account
  name          = module.global_variables.db_metastore_name
  owner         = databricks_group.db_metastore_admin_group.display_name
  force_destroy = true
  region        = module.global_variables.location
  depends_on = [
    databricks_group.db_metastore_admin_group,
  ]
}
