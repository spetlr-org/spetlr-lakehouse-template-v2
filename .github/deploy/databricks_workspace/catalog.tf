## This module is to create containers of the unity catalog 3-levels namespace (catalog.schema) ##
## We do not create components under schema here as they are controled by spetlr python library ##

# Create default catalog for ETL data  --------------------------------------
resource "databricks_catalog" "db_data_catalog" {
  provider       = databricks.workspace
  name           = local.default_catalog
  comment        = "Catalog to encapsulate all data schemas/ databases"
  isolation_mode = "ISOLATED"
  force_destroy = true
  storage_root   = databricks_external_location.ex_data_catalog_location.url
  owner          = data.databricks_group.db_ws_admin_group.display_name
  depends_on     = [
    databricks_external_location.ex_data_catalog_location,
  ]
}

# Create schema for the DLT pipeline of NYC TLC ETL -------------------------
resource "databricks_schema" "db_dlt_nyc_tlc_schema" {
  provider     = databricks.workspace
  catalog_name = local.default_catalog
  name         = var.db_dlt_nyc_tlc_schema
  comment      = "this schema is for the dlt pipeline of nyc_tlc ETL"
  force_destroy = true
  properties   = {
    kind = "various"
  }
  owner        = data.databricks_group.db_ws_admin_group.display_name
  depends_on   = [
    databricks_catalog.db_data_catalog
  ]
}