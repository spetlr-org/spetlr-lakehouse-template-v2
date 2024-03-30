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

locals {
  resource_group_name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"
  resource_name = "${var.company_abbreviation}${var.system_abbreviation}${var.environment}"
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

variable "db_ws_url" {
  type = string
  default = "Databricks--Workspace-URL"
  description = "The URL of the created Databricks workspace "
}

locals {
  default_catalog = "data_${var.environment}"
}