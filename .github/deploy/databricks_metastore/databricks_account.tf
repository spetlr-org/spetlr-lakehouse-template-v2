## This module is for managing the databricks account like metastore, groups, users, SPNs, ... ##

# Metastore admin group -------------------------------------------------------------------------
resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name = module.global_variables.db_metastore_admin_group
}

# Manage metastore admin groups, SPNs and members ----------------------------------------------
resource "databricks_service_principal" "db_meta_spn" {
  provider       = databricks.account
  application_id = azuread_service_principal.db_meta_spn.client_id
  display_name   = module.global_variables.db_metastore_spn_name
  depends_on     = [
    azuread_service_principal.db_meta_spn
  ]
}

resource "databricks_service_principal_role" "db_meta_spn_role" {
  provider             = databricks.account
  service_principal_id = databricks_service_principal.db_meta_spn.id
  role                 = "account_admin"
  depends_on           = [
    databricks_service_principal.db_meta_spn
  ]
}

resource "databricks_group_member" "metastore_admin_member" {
  provider   = databricks.account
  group_id   = databricks_group.db_metastore_admin_group.id
  member_id  = databricks_service_principal.db_meta_spn.id
  depends_on = [
    databricks_group.db_metastore_admin_group,
    databricks_service_principal_role.db_meta_spn_role
  ]
}