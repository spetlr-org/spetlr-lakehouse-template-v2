module "global_variables" {
  source = "../global_variables"
}

variable "db_account_id" {
  type        = string
  description = "The databricks Account Id for Spetlr subscription."
}