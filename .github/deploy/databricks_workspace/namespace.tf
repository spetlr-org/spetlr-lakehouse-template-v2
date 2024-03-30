resource "databricks_default_namespace_setting" "default_catalog" {
  namespace {
    value = "data_${var.environment}"
  }
}