# Output for naming convention and global variables
output "company_abbreviation" {
  value = var.company_abbreviation
}

output "system_abbreviation" {
  value = var.system_abbreviation
}

output "system_name" {
  value = var.system_name
}

output "service_name" {
  value = var.service_name
}

output "location" {
  value = var.location
}

output "service_tag" {
  value = var.service_tag
}

output "system_tag" {
  value = var.system_tag
}

output "creator_tag" {
  value = var.creator_tag
}

# Output for Azure variables
output "cicdSpnName" {
  value = var.cicdSpnName
}

output "db_metastore_spn_name" {
  value = var.db_metastore_spn_name
}

output "az_kv_tenant_id" {
  value = var.az_kv_tenant_id
}

output "az_kv_db_ws_url" {
  value = var.az_kv_db_ws_url
}

output "az_kv_db_workspace_spn_app_id" {
  value = var.az_kv_db_workspace_spn_app_id
}

output "az_kv_db_workspace_spn_app_password" {
  value = var.az_kv_db_workspace_spn_app_password
}

output "az_infrastructure_container" {
  value = var.az_infrastructure_container
}

output "az_infrastructure_libraries_folder" {
  value = var.az_infrastructure_libraries_folder
}

output "az_landing_container" {
  value = var.az_landing_container
}

output "az_data_container" {
  value = var.az_data_container
}

# Output for Databricks variables
output "db_metastore_name" {
  value = var.db_metastore_name
}

output "db_metastore_admin_group" {
  value = var.db_metastore_admin_group
}

output "db_workspace_admin_group" {
  value = var.db_workspace_admin_group
}
