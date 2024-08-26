module "global_variables" {
  source = "../global_variables"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

variable "default_catalog" {
  type        = string
  default     = "data"
  description = "The default catalog name, where all ETL data will reside in"
}

variable "db_dlt_nyc_tlc_schema" {
  type        = string
  default     = "nyc_tlc_dlt"
  description = "The schema name for the DLT pipeline of NYC TLC ETL"
}

locals {
  resource_group_name = "${module.global_variables.system_name}-${upper(var.environment)}-${module.global_variables.service_name}"
  resource_name = "${module.global_variables.company_abbreviation}${module.global_variables.system_abbreviation}${var.environment}"

  db_workspace_admin_group_env = "${module.global_variables.db_workspace_admin_group}-${var.environment}"
  default_catalog        = "${var.default_catalog}_${var.environment}"
  infrastructure_catalog = "${module.global_variables.az_infrastructure_container}_${var.environment}"
}