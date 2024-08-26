## This module is to create the unity catalog 3-levels namespace components (catalog.schema.volume) ##
## Data componenets like tables and views will not be created here. as they will be handled during ETL ##

# Create catalogs ---------------------------------------------------------------------------------
resource "databricks_catalog" "db_infrastructure_catalog" {
  provider       = databricks.workspace
  name           = local.infrastructure_catalog
  comment        = "Catalog to encapsulate all data schema under this workspace"
  isolation_mode = "ISOLATED"
  storage_root   = databricks_external_location.infrastructure.url
  owner = data.databricks_group.db_metastore_admin_group.display_name
  depends_on     = [
    databricks_external_location.infrastructure,
    data.databricks_group.db_metastore_admin_group
  ]
}

# Create schemas ----------------------------------------------------------------------------------

resource "databricks_schema" "db_infrastructure_schema" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.db_infrastructure_catalog.name
  name         = local.infrastructure_schema
  comment      = "this schema is for infrastructure volume"
  properties   = {
    kind = "various"
  }
  owner        = data.databricks_group.db_metastore_admin_group.display_name
  storage_root = "${databricks_external_location.infrastructure.url}${local.infrastructure_schema}/"
  force_destroy = true
  depends_on   = [
    databricks_catalog.db_infrastructure_catalog,
    databricks_grants.infrastructure_catalog
  ]
}

# Create volumes ----------------------------------------------------------------------------------

resource "databricks_volume" "db_infrastructure_libraries_volume" {
  provider         = databricks.workspace
  name             = module.global_variables.az_infrastructure_libraries_folder
  catalog_name     = databricks_catalog.db_infrastructure_catalog.name
  schema_name      = databricks_schema.db_infrastructure_schema.name
  volume_type      = "EXTERNAL"
  storage_location = "${databricks_external_location.infrastructure.url}${module.global_variables.az_infrastructure_libraries_folder}/"
  comment          = "External volume to store infrastructure library files"
  owner            = data.databricks_group.db_metastore_admin_group.display_name
  depends_on       = [
    databricks_schema.db_infrastructure_schema,
    # databricks_grants.infrastructure_libraries_volume
  ]
}