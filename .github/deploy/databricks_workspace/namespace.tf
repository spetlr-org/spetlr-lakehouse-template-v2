resource "databricks_default_namespace_setting" "default_catalog" {
  provider     = databricks.workspace
  namespace {
    value = local.default_catalog
  }
}