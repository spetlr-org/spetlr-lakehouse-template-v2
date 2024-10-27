data "azurerm_key_vault" "key_vault" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "workspace_url" {
  name         = module.global_variables.az_kv_db_ws_url
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_id" {
  name         = module.global_variables.az_kv_db_workspace_spn_app_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_password" {
  name         = module.global_variables.az_kv_db_workspace_spn_app_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name         = module.global_variables.az_kv_tenant_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

# Databricks workspace compute data --------------------------------------------
data "databricks_node_type" "default" {
  provider   = databricks.workspace
  local_disk = true
}

# data "databricks_cluster_policy" "ml_policy" {
#   provider = databricks.workspace
#   name     = "Personal Compute"
# }

data "databricks_spark_version" "ml_3_5" {
  provider          = databricks.workspace
  spark_version     = "3.5"
  long_term_support = true
  ml                = true
}
