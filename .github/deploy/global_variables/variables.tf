# Naming convention and global variables
variable "company_abbreviation" {
  type        = string
  default     = "spetlr"
  description = "Used in creating resources name. Better to use the abbreviation of your organization"
}

variable "system_abbreviation" {
  type        = string
  default     = "lhv2"
  description = "Used in creating resources name. lh here stands for LakeHouse"
}

variable "system_name" {
  type        = string
  default     = "Demo"
  description = "Used in creating the resource group name"
}

variable "service_name" {
  type        = string
  default     = "LakeHouse-V2"
  description = "Used in creating the resource group name"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "The location where the Azure resource group to be deployed"
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

locals {
  tags = {
    creator = var.creator_tag
    system  = var.system_tag
    service = var.service_tag
  }
}

# Azure variables
variable "cicdSpnName" {
  type        = string
  default     = "SpetlrLakehouseV2Pipe"
  description = "The Azure service principal for CI/CD pipeline and Databricks accouunt admin"
}

variable "db_metastore_spn_name" {
  type        = string
  default     = "SpetlrLhV2DbMeta"
  description = "SPN to be added as a Databricks Metastore Admin"
}

variable "db_workspace_spn_name" {
  type        = string
  default     = "SpetlrLhV2DbWs"
  description = "SPN to be added as a Databricks workspace Admin"
}

variable "az_kv_tenant_id" {
  type        = string
  default     = "Azure--Tenant-ID"
  description = "The Azure KeyVault secret for the Azure tenant id"
}

variable "az_kv_db_ws_url" {
  type        = string
  default     = "Databricks--Workspace-URL"
  description = "The Azure KeyVault secret for the URL of the created Databricks workspace"
}

variable "az_kv_db_workspace_spn_app_id" {
  type        = string
  default     = "Databricks--Workspace--SPN-ID"
  description = "The Azure KeyVault secret for Application ID of the workspace admin SPN"
}

variable "az_kv_db_workspace_spn_app_password" {
  type        = string
  default     = "Databricks--Workspace--SPN-Password"
  description = "The Azure KeyVault secret for Application password of the workspace admin SPN"
}

variable "az_infrastructure_container" {
  type        = string
  default     = "infrastructure"
  description = "The name of volume to store files for infrastructure purposes"
}

variable "az_infrastructure_libraries_folder" {
  type        = string
  default     = "libraries"
  description = "The name of a folder inside infrastructure container to store library files (like python wheels)"
}

variable "az_landing_container" {
  type        = string
  default     = "landing"
  description = "Container in the storage account for raw data"
}

variable "az_data_container" {
  type        = string
  default     = "data"
  description = "Container in the storage account for databricks data catalog external location"
}

variable "vnet_public_subnet_name" {
  type        = string
  default     = "public-subnet"
  description = "The name of the public subnet for VNet"
}

variable "vnet_private_subnet_name" {
  type        = string
  default     = "private-subnet"
  description = "The name of the public subnet for VNet"
}

# Databricks variables
variable "db_metastore_name" {
  type        = string
  default     = "spetlrlhv2-metastore"
  description = "The name of the Databricks Metastore"
}

variable "db_metastore_admin_group" {
  type        = string
  default     = "SpetlrLhV2-metastore-admins"
  description = "Databricks group with Databricks Metastore Admin privilages"
}

variable "db_workspace_admin_group" {
  type        = string
  default     = "SpetlrLhV2-workspace-admins"
  description = "Databricks group with Databricks workspace Admin privilages"
}

variable "db_table_user_group" {
  type        = string
  default     = "SpetlrLhV2-table-users"
  description = "A Databricks workspace group with table usage privilages"
}
