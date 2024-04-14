# This module is for manaing groups and users in the databricks workspace

resource "databricks_group" "db_table_user_group" {
  provider     = databricks.workspace
  display_name               = var.db_table_user_group
}
