resource "databricks_default_namespace_setting" "default_catalog" {
  namespace {
    value = local.default_catalog
  }
}