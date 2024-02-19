variable "company_abbreviation" {
  type = string
  default = "spetlr"
  description = "Used in creating resources name. Better to use the abbreviation of your organization"
}

variable "system_abbreviation" {
  type = string
  default = "lh2"
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
  default     = "westeurope"
  description = "The location where the Azure resource group will be deployed"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
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

locals {
  resource_group_name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"
  resource_name = "${var.company_abbreviation}${var.system_abbreviation}${var.environment}"
}
