# This module is to create containers of the unity catalog 3-levels namespace (catalog.schema)
# We do not create components under schema here as they are controled by spetlr python library

# Create catalog for data. We suffix this catalog with environment name
resource "databricks_catalog" "db_data_catalog" {
  provider     = databricks.workspace
  name    = "data-${var.environment}"
  comment = "Catalog to encapsulate all data schema under this workspace"
  isolation_mode = "ISOLATED"
  storage_root = databricks_external_location.ex_data_catalog_location.url
  owner = databricks_group.db_metastore_admin_group.display_name
  depends_on = [
    databricks_external_location.ex_data_catalog_location,
    databricks_group.db_metastore_admin_group
  ]
}

resource "databricks_schema" "db_infrastructure_schema" {
  provider = databricks.workspace
  catalog_name = databricks_catalog.db_data_catalog.name
  name         = "${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}"
  comment      = "this schema is for infrustructure volume"
  properties = {
    kind = "various"
  }
  owner = databricks_group.db_metastore_admin_group.display_name
  storage_root = databricks_external_location.ex_data_catalog_location.url
  depends_on = [
    databricks_catalog.db_data_catalog,
    databricks_grants.ex_data_catalog_grants
  ]
}

resource "databricks_volume" "db_infrastructure_volume" {
  provider = databricks.workspace
  name             = var.infrastructure_volume_container
  catalog_name     = databricks_catalog.db_data_catalog.name
  schema_name      = databricks_schema.db_infrastructure_schema.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.ex_infrastructure_volume_location.url
  comment          = "External volume to store infrastructure files"
  owner = databricks_group.db_metastore_admin_group.display_name
  depends_on = [
    databricks_schema.db_infrastructure_schema,
    databricks_grants.ex_infrastructure_volume_grants
  ]
}
