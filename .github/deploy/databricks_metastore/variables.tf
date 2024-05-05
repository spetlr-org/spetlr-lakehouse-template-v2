variable "location" {
  type        = string
  default     = "northeurope"
  description = "The location where the Azure resource group will be deployed"
}

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

variable "databricks_account_id" {
  type        = string
  default     = "939f40ff-6952-42dc-9aca-3830070d18d3"
  description = "The databricks Account Id for Spetlr subscription"
}