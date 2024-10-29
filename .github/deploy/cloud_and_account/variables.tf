module "global_variables" {
  source = "../global_variables"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

variable "az_kv_db_metastore_spn_app_id" {
  type        = string
  default     = "Databricks--Metastore--SPN-ID"
  description = "The Azure Keyvault secret for Application ID of the metastore admin SPN"
}

variable "az_kv_db_metastore_spn_app_password" {
  type        = string
  default     = "Databricks--Metastore--SPN-Password"
  description = "The Azure Keyvault secret for Application password of the metastore admin SPN"
}

variable "db_account_id" {
  type        = string
  description = "The databricks Account Id for Spetlr subscription."
}

# Some of the variables need to be suffixed with the environment name or other unique identifier
locals {
  # Azure resources
  resource_group_name = "${module.global_variables.system_name}-${upper(var.environment)}-${module.global_variables.service_name}"
  resource_name       = "${module.global_variables.company_abbreviation}${module.global_variables.system_abbreviation}${var.environment}"

  # Specific name for datalake used for ingestion with only read access
  datalake_ingestion_resource_name = "${module.global_variables.company_abbreviation}${module.global_variables.system_abbreviation}ingestion${var.environment}"

  # Databricks groups
  db_workspace_admin_group_env = "${module.global_variables.db_workspace_admin_group}-${var.environment}"
  db_table_user_group_env      = "${module.global_variables.db_table_user_group}-${var.environment}"

  # Databricks catalog and schema for infrastructure
  infrastructure_catalog = "${module.global_variables.az_infrastructure_container}_${var.environment}"
  infrastructure_schema = join(
    "",
    [
      module.global_variables.company_abbreviation,
      module.global_variables.system_abbreviation,
      "_",
      module.global_variables.az_infrastructure_container
    ]
  )

  # SPN names
  db_workspace_spn_name = "${module.global_variables.db_workspace_spn_name}-${var.environment}"
}
