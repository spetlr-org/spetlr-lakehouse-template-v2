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

variable "storage_containers" {
  type = list
  default = ["landing", "bronze", "silver", "gold"]
  description = "Containers to be cretaed in the storage account"
}

variable "catalog_container" {
  type = string
  default = "catalog"
  description = "Container to be cretaed in the storage account for unity catalog storage"
}

variable "volume_container" {
  type = string
  default = "volume"
  description = "Container to be cretaed in the storage account as external volume storage"
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
  default = "SpetlrLhV2DbMetaSpn"
  description = "SPN to be added as a Databricks Metastore Admin"
}

# variable "az_metastore_admin_group" {
#   type = string
#   default = "SpetlrLhV2-db-metastore-admins"
#   description = "An Azure group with Databricks Metastore Admin privilages"
# }

variable "db_metastore_admin_group" {
  type = string
  default = "SpetlrLhV2-metastore-admins"
  description = "An Azure Databricks group with Databricks Metastore Admin privilages"
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
  default = "SpetlrLhV2DbWsSpn"
  description = "SPN to be added as a Databricks workspace Admin"
}

variable "db_workspace_admin_group" {
  type = string
  default = "SpetlrLhV2-workspace-admins"
  description = "An Azure Databricks group with Databricks workspace Admin privilages"
}

variable "db_ws_url" {
  type = string
  default = "Databricks--Workspace--URL"
  description = "The URL of the created Databricks workspace "
}

locals {
  resource_group_name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"
  resource_name = "${var.company_abbreviation}${var.system_abbreviation}${var.environment}"
}
