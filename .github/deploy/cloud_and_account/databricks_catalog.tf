# This module is to create containers of the unity catalog 3-levels namespace (catalog.schema.volume)

# Create catalog for infrustructure. We suffix this catalog with environment name
resource "databricks_catalog" "db_infrastructure_catalog" {
  provider       = databricks.workspace
  name           = local.infrastructure_catalog
  comment        = "Catalog to encapsulate all data schema under this workspace"
  isolation_mode = "ISOLATED"
  storage_root   = databricks_external_location.ex_infrastructure_catalog_location.url
  owner = data.databricks_group.db_metastore_admin_group.display_name
  depends_on     = [
    databricks_external_location.ex_infrastructure_catalog_location,
    databricks_group.db_metastore_admin_group
  ]
}

resource "databricks_schema" "db_infrastructure_schema" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.db_infrastructure_catalog.name
  name         = "${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}"
  comment      = "this schema is for infrustructure volume"
  properties   = {
    kind = "various"
  }
  owner        = data.databricks_group.db_metastore_admin_group.display_name
  storage_root = databricks_external_location.ex_infrastructure_catalog_location.url
  depends_on   = [
    databricks_catalog.db_infrastructure_catalog,
    databricks_grants.ex_infrastructure_catalog_grants
  ]
}

resource "databricks_volume" "db_infrastructure_libraries_volume" {
  provider         = databricks.workspace
  name             = var.infrastructure_libraries_folder
  catalog_name     = databricks_catalog.db_infrastructure_catalog.name
  schema_name      = databricks_schema.db_infrastructure_schema.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.ex_infrastructure_libraries_volume_location.url
  comment          = "External volume to store infrastructure library files"
  owner            = data.databricks_group.db_metastore_admin_group.display_name
  depends_on       = [
    databricks_schema.db_infrastructure_schema,
    databricks_grants.ex_infrastructure_libraries_volume_grants
  ]
}

resource "databricks_volume" "db_infrastructure_tests_volume" {
  provider         = databricks.workspace
  name             = var.infrastructure_tests_folder
  catalog_name     = databricks_catalog.db_infrastructure_catalog.name
  schema_name      = databricks_schema.db_infrastructure_schema.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.ex_infrastructure_tests_volume_location.url
  comment          = "External volume to store infrastructure test files"
  owner            = data.databricks_group.db_metastore_admin_group.display_name
  depends_on       = [
    databricks_schema.db_infrastructure_schema,
    databricks_grants.ex_infrastructure_tests_volume_grants
  ]
}
