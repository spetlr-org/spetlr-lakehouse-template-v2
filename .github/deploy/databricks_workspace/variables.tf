variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

variable "company_abbreviation" {
  type = string
  default = "spetlr"
  description = "Used in creating resources name. Better to use the abbreviation of your organization"
}

variable "system_abbreviation" {
  type = string
  default = "lhv2"
  description = "Used in creating resources name. lh here stands for LakeHouse"
}

variable "data_catalog_container" {
  type = string
  default = "data-catalog"
  description = "Container in the storage account for databricks data catalog external location"
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

variable "infrastructure_libraries_folder" {
  type = string
  default = "libraries"
  description = "The name of a folder inside infrastructure container to store library files (like python wheels)"
}

variable "db_ws_url" {
  type = string
  default = "Databricks--Workspace-URL"
  description = "The URL of the created Databricks workspace "
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

locals {
  resource_group_name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"
  resource_name = "${var.company_abbreviation}${var.system_abbreviation}${var.environment}"
  default_catalog = "data_${var.environment}"
  infrastructure_catalog = "infrastructure_${var.environment}"
}
