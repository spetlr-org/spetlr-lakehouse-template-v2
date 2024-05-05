variable "company_abbreviation" {
  type        = string
  default     = "spetlr"
  description = "Used in creating resources name. Better to use the abbreviation of your organization"
}

variable "system_abbreviation" {
  type = string
  default = "lhv2"
  description = "Used in creating resources name. lh here stands for LakeHouse"
}

variable "system_name" {
  type = string
  default = "Demo"
  description = "Used in creating the resource group name"
}

variable "service_name" {
  type = string
  default = "LakeHouse-V2"
  description = "Used in creating the resource group name"
}

variable "location" {
  type        = string
  default     = "northeurope"
  description = "The location where the Azure resource group will be deployed"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

variable "cicdSpnName" {
  type        = string
  default     = "SpetlrLakehouseV2Pipe"
  description = "The Azure service principal for CI/CD pipeline"
}


variable "service_tag" {
  type        = string
  default     = "LakeHouse"
  description = "Use for tagging"
}

variable "system_tag" {
  type        = string
  default     = "SPETLR-ORG"
  description = "Use for tagging"
}

variable "creator_tag" {
  type        = string
  default     = "Cloud Deployment"
  description = "Use for tagging"
}

variable "data_catalog_container" {
  type = string
  default = "data-catalog"
  description = "Container in the storage account for databricks data catalog external location"
}

variable "landing_storage_container" {
  type = string
  default = "landing"
  description = "Containers in the storage account as the external location for corresponding data layers"
}

variable "infrastructure_catalog_container" {
  type = string
  default = "infrastructure-catalog"
  description = "Container in the storage account for databricks infrastructure catalog external location"
}

variable "vault_sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.vault_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value."
  default     = null
}

variable "db_metastore_spn_name" {
  type = string
  default = "SpetlrLhV2DbMeta"
  description = "SPN to be added as a Databricks Metastore Admin"
}

variable "db_metastore_spn_app_id" {
  type = string
  default = "Databricks--Metastore--SPN-ID"
  description = "Application ID of the metastore admin SPN"
}

variable "db_metastore_spn_app_password" {
  type = string
  default = "Databricks--Metastore--SPN-Password"
  description = "Application password of the metastore admin SPN"
}

variable "db_metastore_admin_group" {
  type = string
  default = "SpetlrLhV2-metastore-admins"
  description = "Databricks group with Databricks Metastore Admin privilages"
}

variable "databricks_account_id" {
  type = string
  default = "939f40ff-6952-42dc-9aca-3830070d18d3"
  description = "The databricks Account Id for Spetlr subscription"
}

variable "db_metastore_name" {
  type = string
  default = "spetlrlhv2-metastore"
  description = "The name of the Databricks Metastore"
}

variable "db_workspace_spn_name" {
  type = string
  default = "SpetlrLhV2DbWs"
  description = "SPN to be added as a Databricks workspace Admin"
}

variable "db_workspace_spn_app_id" {
  type = string
  default = "Databricks--Workspace--SPN-ID"
  description = "Application ID of the workspace admin SPN"
}

variable "db_workspace_spn_app_password" {
  type = string
  default = "Databricks--Workspace--SPN-Password"
  description = "Application password of the workspace admin SPN"
}

variable "db_workspace_admin_group" {
  type = string
  default = "SpetlrLhV2-workspace-admins"
  description = "An Azure Databricks group with Databricks workspace Admin privilages"
}

variable "db_table_user_group" {
  type = string
  default = "SpetlrLhV2-table-users"
  description = "A Databricks workspace group with table usage privilages"
}

variable "db_ws_url" {
  type = string
  default = "Databricks--Workspace-URL"
  description = "The URL of the created Databricks workspace "
}

variable "azure_tenant_id" {
  type = string
  default = "Azure--Tenant-ID"
  description = "The tenant id of the Azure subscription "
}

variable "infrastructure_volume_container" {
  type = string
  default = "infrastructure"
  description = "The name of volume to store files for infrastructure purposes"
}

variable "infrastructure_tests_folder" {
  type = string
  default = "tests"
  description = "The name of a folder inside infrastructure container to tests files (like cluster tests)"
}

variable "infrastructure_libraries_folder" {
  type = string
  default = "libraries"
  description = "The name of a folder inside infrastructure container to store library files (like python wheels)"
}

# Some of the variables need to be suffixed with the environment name or other unique identifier
locals {
  # Resource group name is a combination of system name, environment and service name 
  resource_group_name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"

  # All resources under the resource group have the same name with the following combination
  resource_name = "${var.company_abbreviation}${var.system_abbreviation}${var.environment}"

  # Databricks catalog for infrastructure
  infrastructure_catalog = "infrastructure_${var.environment}"

  # Databricks groups
  db_metastore_admin_group = "${var.db_metastore_admin_group}-${var.environment}"
  db_workspace_admin_group = "${var.db_workspace_admin_group}-${var.environment}"
  db_table_user_group = "${var.db_table_user_group}-${var.environment}"

  # SPN names
  db_metastore_spn_name = "${var.db_metastore_spn_name}-${var.environment}"
  db_workspace_spn_name = "${var.db_workspace_spn_name}-${var.environment}"

  # Keyvault secrets
  azure_tenant_id = "${var.azure_tenant_id}-${var.environment}"
  db_ws_url = "${var.db_ws_url}-${var.environment}"
  db_metastore_spn_app_id = "${var.db_metastore_spn_app_id}-${var.environment}"
  db_metastore_spn_app_password = "${var.db_metastore_spn_app_password}-${var.environment}"
  db_workspace_spn_app_id = "${var.db_workspace_spn_app_id}-${var.environment}"
  db_workspace_spn_app_password = "${var.db_workspace_spn_app_password}-${var.environment}"
}
